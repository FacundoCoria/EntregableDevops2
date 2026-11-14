"""Verificación documental C02; no inicia servicios, jobs ni solicitudes HTTP."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
FILES = [ROOT / p for p in (
    'docs/INSTALACION-L4.md', 'scripts/l4/GUIA.md',
    'scripts/l4/B04-REPRODUCCION.md', 'ci/jenkins/README.md')]
checks = []
links = []
blocks = []
bash = Path('C:/Program Files/Git/bin/bash.exe')
bash_cmd = str(bash) if bash.exists() else 'bash'
for path in FILES:
    content = path.read_text(encoding='utf-8')
    for target in re.findall(r'(?<!!)\[[^\]]*\]\(([^)]+)\)', content):
        if re.match(r'https?://', target):
            continue
        resolved = (path.parent / target.split('#')[0]).resolve()
        assert resolved.exists(), (path, target)
        assert resolved.is_relative_to(ROOT), (path, target)
        links.append({'file': str(path.relative_to(ROOT)), 'target': target})
    for index, code in enumerate(re.findall(r'```(?:bash|sh)\n(.*?)```', content, re.S), 1):
        with tempfile.NamedTemporaryFile(suffix='.sh', mode='w', encoding='utf-8',
                                         newline='\n', delete=False) as tmp:
            tmp.write(code)
            name = tmp.name
        try:
            result = subprocess.run([bash_cmd, '-n', name], capture_output=True, text=True)
            assert result.returncode == 0, (path, index, result.stderr)
            blocks.append({'file': str(path.relative_to(ROOT)), 'block': index})
        finally:
            Path(name).unlink()

guide = FILES[0].read_text(encoding='utf-8')
api_root = ROOT / 'pedidos-api/pedidos-api/src/main/java/com/pedidos/pedidos_api'
for route, controller in (('/api/productos', 'ProductoController.java'),
                           ('/api/pedidos', 'PedidoController.java')):
    source = (api_root / 'controller' / controller).read_text(encoding='utf-8')
    assert f'@RequestMapping("{route}")' in source and '@PostMapping' in source
    assert route in guide
checks.append('Rutas GET/POST del ejemplo cotejadas con controladores Java')
for payload in re.findall(r"-d '(\{[^\n]*\})'", guide):
    parsed = json.loads(payload)
    assert parsed['nombre'] == 'ejemplo-c02' and parsed['precio'] == 42.5
checks.append('JSON de producto del ejemplo valido')
for version in ('3.9.16', '1.1308.4', '4.3.1', '1.37.0', '1.184.0'):
    assert version in guide and version in (ROOT / 'ci/bootstrap-tools.sh').read_text()
checks.append('Cinco versiones del agente coinciden con bootstrap entregado')
assert '../.tools/' not in FILES[1].read_text() and '\n+y' not in FILES[1].read_text()
checks.append('Guia operativa sin dependencia ../.tools ni errata +y')
for token in ('SOURCE_URL', 'SOURCE_REF', 'IMAGE_REPOSITORY', 'l4-snyk-token', 'l4-dockerhub'):
    assert token in guide and token in (ROOT / 'Jenkinsfile').read_text()
checks.append('Parametros e IDs de credenciales coinciden con Jenkinsfile')
result = subprocess.run(['git', '-C', str(ROOT), 'diff', '--exit-code', '--',
                         'reports', 'Jenkinsfile', 'pedidos-api', 'README.md'],
                        capture_output=True, text=True)
assert result.returncode == 0, result.stdout
checks.append('Sin cambios tracked en reportes anteriores, aplicacion/chart, Jenkinsfile o informe README')
protected = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
             for p in (ROOT / 'reports').rglob('*')
             if p.is_file() and 'l4-c02' not in p.relative_to(ROOT).parts}
output = {'result': 'PASS', 'scope': 'Solo verificacion documental; sin ejecucion de ejemplos',
          'local_links': links, 'bash_syntax': blocks, 'checks': checks,
          'previous_evidence_sha256': protected,
          'documents_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
                               for p in FILES}}
(Path(__file__).parent / 'verificacion.json').write_text(
    json.dumps(output, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
print(json.dumps({'result': 'PASS', 'local_links': len(links),
                  'bash_blocks': len(blocks), 'checks': len(checks),
                  'previous_evidence_inventoried': len(protected)}, ensure_ascii=False))
