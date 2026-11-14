#!/usr/bin/env python3
"""Cold recovery of C01 homes. Docker cache/TLS/agent transport are disposable."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
from datetime import datetime, timezone

HERE = Path(__file__).resolve().parent
LOCAL = HERE / '.local'
VOLUMES = ('controller-home', 'agent-home', 'agent-secret', 'docker-data', 'docker-client-certs')
NETWORKS = ('control', 'builds')
SERVICES = ('controller', 'agent', 'docker')
FILES = ('compose.yaml', 'images.env', 'plugins.txt', 'plugins.sha256', 'plugins.lock.json',
         'init.groovy', 'Jenkinsfile.preflight', 'Dockerfile.controller', 'Dockerfile.agent',
         'agent-entrypoint.sh', 'test-versions.sh', 'lifecycle.py', 'compose.c07.yaml', '../bootstrap-tools.sh')


def run(*args):
    p = subprocess.run(['docker', *args], cwd=HERE, text=True, capture_output=True)
    if p.returncode:
        # Never echo container output: a failed command may have read private files.
        raise RuntimeError('Docker fallo: ' + ' '.join(args[:3]) + ' (verificar motor/permisos/estado)')
    return p.stdout.strip()


def objects(kind, names):
    found = []
    for name in names:
        p = subprocess.run(['docker', kind, 'inspect', name], text=True, capture_output=True)
        if p.returncode == 0:
            found.extend(json.loads(p.stdout))
        elif 'no such' not in p.stderr.lower() and f'network {name} not found' not in p.stderr.lower():
            raise RuntimeError('No se pudo inspeccionar ' + kind + ': ' + name)
    return found


def sha(path):
    with path.open('rb') as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()


def private_dir(path):
    path.mkdir(parents=True, exist_ok=False, mode=0o700)
    if os.name == 'nt':
        sid = subprocess.check_output(['whoami', '/user', '/fo', 'csv', '/nh'], text=True).strip().split(',')[-1].strip('"')
        subprocess.run(['icacls', str(path), '/inheritance:r', '/grant:r', f'*{sid}:(OI)(CI)F'],
                       check=True, capture_output=True)
    else:
        path.chmod(0o700)


def compose(project, *args, port=None):
    # Set port only in this child process; no ambient Compose/project overrides.
    env = os.environ.copy()
    for key in list(env):
        if key.startswith('COMPOSE_') or key in ('JENKINS_BASE', 'DOCKER_CLI_BASE', 'DOCKER_DIND_IMAGE'):
            env.pop(key)
    if port is not None:
        env['JENKINS_HTTP_PORT'] = str(port)
    config_files = ['-f', 'compose.yaml'] + (['-f', 'compose.c07.yaml'] if project == 'l4-c07' else [])
    p = subprocess.run(['docker', 'compose', '--env-file', 'images.env', *config_files,
                        '-p', project, *args], cwd=HERE, env=env, text=True, capture_output=True)
    if p.returncode:
        raise RuntimeError('Compose fallo: ' + ' '.join(args) + '; revisar logs locales')
    return p.stdout


def inventory(project):
    """Validate exact names AND Compose ownership, including all project resources."""
    run('info', '--format', '{{.ServerVersion}}')
    containers = objects('container', [f'{project}-{s}-1' for s in SERVICES])
    volumes = objects('volume', [f'{project}_{v}' for v in VOLUMES])
    networks = objects('network', [f'{project}_{n}' for n in NETWORKS])
    for kind, items, expected in [('container', containers, {f'{project}-{s}-1' for s in SERVICES}),
                                  ('volume', volumes, {f'{project}_{v}' for v in VOLUMES}),
                                  ('network', networks, {f'{project}_{n}' for n in NETWORKS})]:
        for item in items:
            name = item['Name'].lstrip('/')
            labels = item.get('Config', {}).get('Labels', {}) if kind == 'container' else item.get('Labels', {})
            if name not in expected or labels.get('com.docker.compose.project') != project:
                raise RuntimeError('Propiedad no valida: ' + name)
        command = ('ps', '-aq') if kind == 'container' else (kind, 'ls', '-q')
        actual = set(run(*command, '--filter', f'label=com.docker.compose.project={project}').split())
        identifiers = {i['Id'] if kind != 'volume' else i['Name'] for i in items}
        # docker ps/network ls may return shortened IDs.
        if any(not any(full.startswith(short) for full in identifiers) for short in actual):
            raise RuntimeError('Hay recursos adicionales del proyecto; revisar manualmente')
    allowed = {c['Id'] for c in containers}
    for v in volumes:
        users = run('ps', '-aq', '--filter', 'volume=' + v['Name']).split()
        if any(not any(full.startswith(short) for full in allowed) for short in users):
            raise RuntimeError('Volumen compartido con otro contenedor: ' + v['Name'])
    for n in networks:
        if set((n.get('Containers') or {}).keys()) - allowed:
            raise RuntimeError('Red compartida: ' + n['Name'])
    for c in containers:
        service = c['Config']['Labels'].get('com.docker.compose.service')
        if service not in SERVICES or c['Name'] != f'/{project}-{service}-1':
            raise RuntimeError('Servicio inesperado')
        expected_mounts = {
            'controller': {'/var/jenkins_home': 'controller-home', '/run/l4-agent': 'agent-secret'},
            'agent': {'/var/jenkins_home': 'agent-home', '/run/l4-agent': 'agent-secret', '/certs/client': 'docker-client-certs'},
            'docker': {'/var/lib/docker': 'docker-data', '/certs/client': 'docker-client-certs'},
        }[service]
        mounts = {m['Destination']: m for m in c['Mounts']}
        if set(mounts) != set(expected_mounts) | ({'/run/secrets/admin_password'} if service == 'controller' else set()):
            raise RuntimeError('Montajes adicionales/no previstos')
        for destination, volume in expected_mounts.items():
            m = mounts[destination]
            if m['Type'] != 'volume' or m['Name'] != f'{project}_{volume}':
                raise RuntimeError('Montaje ajeno al proyecto')
        if service == 'controller':
            m = mounts['/run/secrets/admin_password']
            if m['Type'] != 'bind' or Path(m['Source']).resolve() != (LOCAL / 'admin-password.txt').resolve() or m['RW']:
                raise RuntimeError('Archivo de inicializacion inesperado')
    return {'containers': containers, 'volumes': volumes, 'networks': networks}


def idle(project, data):
    controller = next((c for c in data['containers'] if c['Name'] == f'/{project}-controller-1'), None)
    if controller and controller['State']['Running']:
        def api(endpoint):
            return json.loads(run('exec', controller['Id'], 'sh', '-c',
                'curl -gfsS --user "bruno:$(cat /run/secrets/admin_password)" '
                '"http://localhost:8080/' + endpoint + '"'))
        queue = api('queue/api/json?tree=items[id]')
        computers = api('computer/api/json?tree=computer[executors[currentExecutable[url]],oneOffExecutors[currentExecutable[url]]]')
        if 'items' not in queue or 'computer' not in computers:
            raise RuntimeError('Respuesta Jenkins incompleta; no se confirma estado inactivo')
        if queue['items'] or any(
            e.get('currentExecutable') for c in computers['computer']
            for e in c.get('executors', []) + c.get('oneOffExecutors', [])):
            raise RuntimeError('Hay builds activos/en cola; esperar a que terminen')


def stop(project, data):
    idle(project, data)
    # Agent first prevents new execution while the controller finishes shutting down.
    for service in SERVICES[1:2] + SERVICES[:1] + SERVICES[2:]:
        name = f'{project}-{service}-1'
        if any(c['Name'] == '/' + name for c in data['containers']):
            run('stop', '--time', '60', name)
    stopped = inventory(project)
    if any(c['State']['Running'] for c in stopped['containers']):
        raise RuntimeError('No se logro parada en frio')
    return stopped


def helper(image, volume, directory, script, readonly=False):
    return run('run', '--rm', '--network', 'none', '--user', '0:0', '--entrypoint', 'sh',
               '--mount', f'type=volume,src={volume},dst=/data,volume-nocopy' + (',readonly' if readonly else ''),
               '--mount', f'type=bind,src={directory},dst=/backup', image, '-c', script)


def load_backup(backup_id):
    folder = LOCAL / 'backups' / backup_id
    keys = LOCAL / 'recovery-keys' / backup_id
    manifest = json.loads((folder / 'manifest.json').read_text(encoding='utf-8'))
    if manifest['format'] != 1 or manifest['id'] != backup_id:
        raise RuntimeError('Manifiesto no compatible')
    for directory in (folder, keys):
        hashes = json.loads((directory / 'sha256.json').read_text(encoding='utf-8'))
        expected = {'controller-home.tar.gz', 'agent-home.tar.gz', 'manifest.json', 'source.tar.gz'} if directory == folder else {'master-key.tar.gz', 'admin-password.txt'}
        if set(hashes) != expected:
            raise RuntimeError('Lista de archivos inesperada')
        for name, digest in hashes.items():
            if sha(directory / name) != digest:
                raise RuntimeError('Copia corrupta: ' + name)
    if manifest['sourceHashes'] != {f: sha(HERE / f) for f in FILES}:
        raise RuntimeError('Fuente C01 distinta; recuperar/revisar primero source.tar.gz, sin extraer a ciegas')
    for image in manifest['images'].values():
        run('image', 'inspect', image, '--format', '{{.Id}}')
    return folder, keys, manifest


def backup(project, data, backup_id):
    if len(data['containers']) != 3 or len(data['volumes']) != 5:
        raise RuntimeError('La copia requiere la instalacion C01 completa')
    folder = LOCAL / 'backups' / backup_id
    keys = LOCAL / 'recovery-keys' / backup_id
    if folder.exists() or keys.exists():
        raise RuntimeError('ID ya existente; elegir otro sin sobrescribir')
    private_dir(folder)
    private_dir(keys)
    data = stop(project, data)
    images = {c['Config']['Labels']['com.docker.compose.service']: c['Image'] for c in data['containers']}
    image = images['controller']
    helper(image, project + '_controller-home', folder,
           'tar --numeric-owner --exclude=./secrets/master.key -czf /backup/controller-home.tar.gz -C /data .', True)
    helper(image, project + '_controller-home', keys,
           'test -s /data/secrets/master.key && tar --numeric-owner -czf /backup/master-key.tar.gz -C /data secrets/master.key', True)
    helper(image, project + '_agent-home', folder,
           'tar --numeric-owner -czf /backup/agent-home.tar.gz -C /data .', True)
    shutil.copyfile(LOCAL / 'admin-password.txt', keys / 'admin-password.txt')
    import tarfile
    with tarfile.open(folder / 'source.tar.gz', 'w:gz') as archive:
        for f in FILES:
            archive.add(HERE / f, arcname=('ci/bootstrap-tools.sh' if f.startswith('../') else 'ci/jenkins/' + f))
    manifest = {'format': 1, 'id': backup_id, 'sourceProject': project,
                'timestamp': datetime.now(timezone.utc).isoformat(), 'images': images,
                'sourceHashes': {f: sha(HERE / f) for f in FILES},
                'preserved': ['controller-home except master.key', 'agent-home'],
                'separate': ['master.key', 'admin initialization password'],
                'regenerated': ['agent-secret', 'docker-client-certs', 'docker-data'],
                'note': 'No Docker images/cache from DinD; no Kubernetes network/RBAC recreation; private local backup'}
    (folder / 'manifest.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    for directory, names in [(folder, ['controller-home.tar.gz', 'agent-home.tar.gz', 'source.tar.gz', 'manifest.json']),
                             (keys, ['master-key.tar.gz', 'admin-password.txt'])]:
        (directory / 'sha256.json').write_text(json.dumps({n: sha(directory / n) for n in names}, indent=2), encoding='utf-8')
    print(json.dumps({'result': 'BACKUP_PASS', 'id': backup_id, 'project': project, 'state': 'stopped',
                      'sizes': {p.name: p.stat().st_size for p in folder.iterdir()}}, indent=2))


def restore(project, data, backup_id):
    if any(data.values()):
        raise RuntimeError('Restauracion exige destino completamente nuevo (sin contenedores/redes/volumenes)')
    folder, keys, manifest = load_backup(backup_id)
    # The init password is only needed by Compose. Existing Jenkins credentials live in the restored home.
    password = LOCAL / 'admin-password.txt'
    if password.exists() and sha(password) != sha(keys / password.name):
        raise RuntimeError('Clave local de inicializacion distinta; no se sobrescribe')
    if not password.exists():
        shutil.copyfile(keys / password.name, password)
        password.chmod(0o600)
    for volume in ('controller-home', 'agent-home'):
        name = f'{project}_{volume}'
        run('volume', 'create', '--label', f'com.docker.compose.project={project}',
            '--label', f'com.docker.compose.volume={volume}', name)
        helper(manifest['images']['controller'], name, folder,
               f'tar --numeric-owner -xzf /backup/{volume}.tar.gz -C /data && tar --compare -zf /backup/{volume}.tar.gz -C /data')
    helper(manifest['images']['controller'], project + '_controller-home', keys,
           'tar --numeric-owner -xzf /backup/master-key.tar.gz -C /data && tar --compare -zf /backup/master-key.tar.gz -C /data')
    records = LOCAL / 'restores'
    records.mkdir(exist_ok=True, mode=0o700)
    (records / (project + '.json')).write_text(json.dumps({'backup': backup_id, 'images': manifest['images']}), encoding='utf-8')
    print(json.dumps({'result': 'RESTORE_PASS', 'project': project, 'backup': backup_id,
                      'state': 'homes restored; start separately with a free loopback port'}, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['status', 'stop', 'start', 'backup', 'check-backup', 'restore', 'purge'])
    parser.add_argument('--project', default='l4-c01')
    parser.add_argument('--backup-id')
    parser.add_argument('--confirm', help='Required for purge: exact project name')
    parser.add_argument('--port', type=int, default=18080)
    args = parser.parse_args()
    if not re.fullmatch(r'(?:l4-c01(?:-[a-z0-9]+(?:-[a-z0-9]+)*)?|l4-c07)', args.project):
        raise RuntimeError('Solo proyectos dedicados l4-c01[-sufijo]; nunca curso/default')
    if args.backup_id and not re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9-]{0,79}', args.backup_id):
        raise RuntimeError('ID de copia invalido')
    if args.action in ('restore', 'check-backup') and not args.backup_id:
        raise RuntimeError('Falta --backup-id')
    if not 1024 <= args.port <= 65535:
        raise RuntimeError('Puerto fuera de rango')
    if args.action == 'check-backup':
        load_backup(args.backup_id)
        print('BACKUP_INTEGRITY_PASS')
        return
    if args.action == 'purge' and args.confirm != args.project:
        raise RuntimeError('Purga requiere --confirm con el nombre exacto del proyecto')
    data = inventory(args.project)
    if args.action == 'status':
        print(json.dumps({k: [i['Name'] for i in v] for k, v in data.items()}, indent=2))
    elif args.action == 'stop':
        stop(args.project, data)
        print('STOP_PASS: cinco volumenes conservados')
    elif args.action == 'start':
        # Do not silently rebuild changed images over existing recovery data.
        record = LOCAL / 'restores' / (args.project + '.json')
        if record.exists():
            expected = json.loads(record.read_text(encoding='utf-8'))['images']
            current = json.loads(compose(args.project, 'config', '--format', 'json', port=args.port))
            for service in SERVICES:
                actual = run('image', 'inspect', current['services'][service]['image'], '--format', '{{.Id}}')
                if actual != expected[service]:
                    raise RuntimeError('Imagen distinta a la copia: ' + service)
        compose(args.project, 'up', '-d', '--no-build', '--pull', 'never', '--wait', '--wait-timeout', '240', port=args.port)
        inventory(args.project)
        print(f'START_PASS: http://localhost:{args.port}')
    elif args.action == 'backup':
        backup(args.project, data, args.backup_id or datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ'))
    elif args.action == 'restore':
        restore(args.project, data, args.backup_id)
    elif args.action == 'purge':
        stop(args.project, data)
        # Recheck everything before any removal. No compose down/prune or shared image deletion.
        data = inventory(args.project)
        for c in data['containers']:
            run('rm', c['Id'])
        for n in data['networks']:
            run('network', 'rm', n['Id'])
        for v in data['volumes']:
            run('volume', 'rm', v['Name'])
        if any(inventory(args.project).values()):
            raise RuntimeError('Recursos residuales; revisar')
        print('PURGE_PASS: solo tres contenedores/dos redes/cinco volumenes propios; copias/imagenes/clave local conservadas')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, OSError, ValueError, KeyError, subprocess.SubprocessError) as exc:
        print('ERROR: ' + str(exc), file=sys.stderr)
        sys.exit(1)
