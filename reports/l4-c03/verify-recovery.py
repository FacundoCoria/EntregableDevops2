"""Read-only C03 evidence; never prints credentials or invokes a Jenkins build."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time

parser = argparse.ArgumentParser()
parser.add_argument('--project', required=True)
parser.add_argument('--output', required=True)
args = parser.parse_args()
out = Path(args.output)
out.mkdir(parents=True, exist_ok=True)
root = Path(__file__).resolve().parent


def docker(*a):
    p = subprocess.run(['docker', *a], text=True, capture_output=True)
    if p.returncode:
        raise RuntimeError('Docker verification failed (output suppressed)')
    return p.stdout.strip()


controller = args.project + '-controller-1'
agent = args.project + '-agent-1'


def api(endpoint):
    return json.loads(docker('exec', controller, 'sh', '-c',
        'curl -gfsS --user "bruno:$(cat /run/secrets/admin_password)" "http://localhost:8080/' + endpoint + '"'))


state = json.loads(docker('exec', controller, 'cat', '/var/jenkins_home/c01-configured.json'))
lock = json.loads((root.parents[1] / 'ci/jenkins/plugins.lock.json').read_text(encoding='utf-8'))
assert state['core'] == '2.580.2' and state['controllerExecutors'] == 0
assert state['agentExecutors'] == 1 and state['integralDisabled']
assert all(state['plugins'].get(k) == v['version'] for k, v in lock['plugins'].items())
for _ in range(30):
    online = not api('computer/l4-agent/api/json?tree=offline')['offline']
    if online:
        break
    time.sleep(2)
assert online, 'Agent offline'
for container in [controller, agent]:
    assert docker('exec', container, 'id', '-u') == '1000'

build = api('job/L4-C01-preflight/1/api/json?tree=number,result,building,duration,artifacts[fileName,relativePath]')
assert build['result'] == 'SUCCESS' and not build['building']
assert len(build['artifacts']) == 9
integral = api('job/L4-integral/api/json?tree=buildable')
assert not integral['buildable']
files = docker('exec', controller, 'sh', '-c',
               'find /var/jenkins_home/jobs /var/jenkins_home/users -type f -print0 | sort -z | xargs -0 sha256sum')
(out / 'controller-files.txt').write_text(files + '\n', encoding='utf-8')
before = (root / 'controller-before.txt').read_text(encoding='utf-8').strip()
assert files == before, 'Jobs/users content changed before new manual build'
marker = docker('exec', agent, 'sha256sum', '/var/jenkins_home/c01-persistence.txt')
assert marker == (root / 'agent-before.txt').read_text(encoding='utf-8').strip()
tls = docker('exec', agent, 'sh', '-c',
             'test "$DOCKER_TLS_VERIFY" = 1 && test -r /certs/client/key.pem && test ! -S /var/run/docker.sock && echo TLS_PASS')
assert tls == 'TLS_PASS'
host = docker('info', '--format', '{{.ID}}')
engine = docker('exec', agent, 'docker', 'info', '--format', '{{.ID}}')
assert host != engine
tools = docker('exec', agent, 'sh', '/opt/l4/bootstrap-tools.sh')
(out / 'tools.txt').write_text(tools + '\n', encoding='utf-8')
images = docker('exec', agent, 'docker', 'images', '--format', '{{.Repository}}:{{.Tag}} {{.ID}}')
result = {'result': 'PASS', 'project': args.project, 'core': state['core'],
          'pluginsChecked': len(lock['plugins']), 'controllerAndAgentUid': 1000,
          'agentOnline': online, 'integralDisabled': True, 'build1': build,
          'jobsUsersHashesMatchBefore': True, 'markerHashMatchesBefore': True,
          'tls': True, 'hostDockerId': host, 'dedicatedDockerId': engine,
          'dedicatedImages': images.splitlines()}
(out / 'result.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
print(json.dumps(result, indent=2))
