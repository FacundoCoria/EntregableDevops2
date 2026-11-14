"""Collect only an already executed preflight #2; never starts a build."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

controller = 'l4-c01-c03-restore-controller-1'
base = 'job/L4-C01-preflight/2/'


def get(endpoint):
    p = subprocess.run(['docker', 'exec', controller, 'sh', '-c',
        'curl -gfsS --user "bruno:$(cat /run/secrets/admin_password)" "http://localhost:8080/' + endpoint + '"'], capture_output=True)
    if p.returncode:
        raise RuntimeError('Build not available or read failed; no build was started')
    return p.stdout


result = json.loads(get(base + 'api/json?tree=number,result,building,duration,artifacts[fileName,relativePath]'))
if result['building']:
    print('BUILD_2_RUNNING')
    sys.exit(2)
assert result['result'] == 'SUCCESS', result['result']
assert len(result['artifacts']) == 9
out = Path(__file__).resolve().parent / 'restored-preflight-2'
out.mkdir(exist_ok=True)
(out / 'result.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
(out / 'console.txt').write_bytes(get(base + 'consoleText'))
for artifact in result['artifacts']:
    relative = artifact['relativePath']
    assert relative.startswith('evidence/') and '..' not in relative
    p = out / relative
    p.parent.mkdir(exist_ok=True)
    p.write_bytes(get(base + 'artifact/' + relative))
assert (out / 'evidence/commit.txt').read_text().strip() == '50a0eb53e7a1152fbe0e4f26252fac2380403fc3'
assert 'uid=1000' in (out / 'evidence/identity.txt').read_text()
assert (out / 'evidence/persistence.txt').read_text().startswith('PERSISTENCE_REUSED\n')
hashes = {str(p.relative_to(out)).replace('\\', '/'): hashlib.sha256(p.read_bytes()).hexdigest()
          for p in out.rglob('*') if p.is_file() and p.name != 'sha256.json'}
(out / 'sha256.json').write_text(json.dumps(hashes, indent=2), encoding='utf-8')
print(json.dumps({'result': 'SUCCESS', 'number': result['number'], 'durationMs': result['duration'],
                  'artifacts': len(result['artifacts']), 'persistence': 'PERSISTENCE_REUSED',
                  'startedBy': 'Bruno in UI; collection read only'}, indent=2))
