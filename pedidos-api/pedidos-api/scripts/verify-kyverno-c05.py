"""Admission tests for the dedicated C05 cluster; Python standard library only.

The cluster and policies must already exist. Fixtures are unscheduled and cannot
pull images. This tests API admission, not container execution or image content.
"""
import argparse
import copy
import json
from pathlib import Path
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--context', default='minikube-l4-c05')
    parser.add_argument('--report-dir', type=Path, required=True)
    parser.add_argument('--suite', choices=['all', 'subresources', 'resize'], default='all')
    args = parser.parse_args()
    if args.context != 'minikube-l4-c05':
        parser.error('This verifier only operates the dedicated minikube-l4-c05 profile.')
    args.report_dir.mkdir(parents=True, exist_ok=False)
    log = (args.report_dir / 'kyverno-validation.log').open('x', encoding='utf-8')
    fixtures = args.report_dir / 'fixtures'
    fixtures.mkdir()
    results = []
    cleanup = []
    base_cmd = ['kubectl', '--context', args.context, '--request-timeout=30s']

    def run(label, command, obj=None, policy=None, expected='ACCEPT', record=True):
        if record and args.suite == 'subresources' and '-ephemeral-' not in label and '-resize-' not in label:
            return True
        if record and args.suite == 'resize' and '-resize-' not in label:
            return True
        if obj is not None:
            payload = json.dumps(obj, indent=2)
            fixture_path = fixtures / (label + '.json')
            fixture_path.write_text(payload, encoding='utf-8')
            if '--patch-file' in command:
                command = list(command)
                command[command.index('--patch-file') + 1] = str(fixture_path.resolve())
        else:
            payload = None
        completed = subprocess.run(base_cmd + command, input=payload, text=True,
                                   stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                   encoding='utf-8', errors='replace', timeout=65)
        output = completed.stdout
        if expected == 'DENY':
            passed = completed.returncode != 0 and policy in output and 'denied' in output.lower()
        elif expected == 'API_REJECT':
            passed = completed.returncode != 0 and 'resources' in output and 'Forbidden' in output
        elif expected == 'API_REJECT_LIMITS':
            passed = completed.returncode != 0 and 'resource limits cannot be removed' in output
        else:
            passed = completed.returncode == 0
        log.write(f'\nCASE: {label}\nCOMMAND: {json.dumps(base_cmd + command)}\n'
                  f'EXPECTED: {expected} {policy or ""}\nEXIT: {completed.returncode}\n'
                  f'{output}\nPASS: {passed}\n')
        log.flush()
        if record:
            results.append(dict(case=label, expected=expected, policy=policy,
                                exitCode=completed.returncode, passed=passed))
        return passed

    resources = dict(requests=dict(cpu='10m', memory='16Mi'), limits=dict(cpu='100m', memory='64Mi'))
    container = dict(name='main', image='busybox:1.36', imagePullPolicy='Never',
                     resources=resources, securityContext=dict(runAsNonRoot=True, runAsUser=10001))
    pod = dict(apiVersion='v1', kind='Pod', metadata=dict(name='c05-test', namespace='laboratorio4'),
               spec=dict(nodeName='c05-no-execution', restartPolicy='Never',
                         automountServiceAccountToken=False, containers=[container]))
    image_policy = 'l4-deny-latest-images'
    resource_policy = 'l4-require-container-resources'
    root_policy = 'l4-disallow-root-containers'
    privileged_policy = 'l4-disallow-privileged-containers'
    digest = 'sha256:' + 'a' * 64

    def create_case(label, obj, policy=None, dry=True):
        obj = copy.deepcopy(obj)
        obj['metadata']['name'] = 'c05-' + label
        cmd = ['create'] + (['--dry-run=server'] if dry else []) + ['-f', '-']
        return run(label, cmd, obj, policy=policy, expected='DENY' if policy else 'ACCEPT')

    try:
        if not run('connection', ['get', 'nodes'], record=False):
            raise RuntimeError('Cluster unavailable; no admission result can be inferred.')
        # Preserve all 16 prior scenarios, exercising the corrected implementation.
        old_tests = Path(__file__).resolve().parents[1] / 'security/kyverno/tests'
        for case in json.loads((old_tests / 'cases.json').read_text(encoding='utf-8-sig')):
            fixture = json.loads((old_tests / case['file']).read_text(encoding='utf-8-sig'))
            fixture['spec']['nodeName'] = 'c05-no-execution'
            create_case('regression-' + Path(case['file']).stem, fixture, case['policy'])

        for where in ['containers', 'initContainers', 'sidecar']:
            for label, image, deny in [
                ('latest-digest', 'busybox:latest@' + digest, True),
                ('digest', 'busybox@' + digest, False),
                ('tag-digest', 'busybox:1.36@' + digest, False),
                ('repo-named-latest', 'registry.example/latest@' + digest, False),
                ('port-no-tag', 'registry.example:5000/busybox', True),
                ('malformed-digest', 'busybox@sha256:abc', True),
            ]:
                obj = copy.deepcopy(pod)
                if where == 'containers':
                    target = obj['spec']['containers'][0]
                else:
                    target = copy.deepcopy(container)
                    target['name'] = 'init'
                    obj['spec']['initContainers'] = [target]
                    if where == 'sidecar':
                        target['restartPolicy'] = 'Always'
                target['image'] = image
                create_case(where.lower() + '-' + label, obj, image_policy if deny else None)

        # Namespace reach: no opt-in label is required for a new application namespace.
        for ns in ['laboratorio4', 'default', 'c05-second']:
            for field, policy in [('latest', image_policy), ('resources', resource_policy),
                                  ('root', root_policy), ('privileged', privileged_policy)]:
                obj = copy.deepcopy(pod)
                obj['metadata']['namespace'] = ns
                c = obj['spec']['containers'][0]
                if field == 'latest':
                    c['image'] = 'busybox:latest@' + digest
                elif field == 'resources':
                    del c['resources']['limits']['memory']
                elif field == 'root':
                    c['securityContext'].update(runAsNonRoot=False, runAsUser=0)
                else:
                    c['securityContext']['privileged'] = True
                create_case(ns + '-' + field, obj, policy)
        for ns in ['kube-system', 'kube-public', 'kube-node-lease', 'kyverno', 'falco']:
            obj = copy.deepcopy(pod)
            obj['metadata']['namespace'] = ns
            c = obj['spec']['containers'][0]
            c.update(image='busybox:latest', resources={}, securityContext=dict(runAsUser=0, privileged=True))
            create_case('exception-' + ns, obj)

        # Controller autogeneration is tested separately from Pod admission.
        for label, policy in [('conforme', None), ('latest-digest', image_policy),
                              ('resources', resource_policy), ('root', root_policy),
                              ('privileged', privileged_policy)]:
            template = copy.deepcopy(pod['spec'])
            c = template['containers'][0]
            if label == 'latest-digest':
                c['image'] = 'busybox:latest@' + digest
            elif label == 'resources':
                c['resources'] = {}
            elif label == 'root':
                c['securityContext']['runAsUser'] = 0
            elif label == 'privileged':
                c['securityContext']['privileged'] = True
            template.pop('restartPolicy')
            deployment = dict(apiVersion='apps/v1', kind='Deployment',
                metadata=dict(name='unused', namespace='default'),
                spec=dict(replicas=1, selector=dict(matchLabels=dict(app='c05')),
                          template=dict(metadata=dict(labels=dict(app='c05')), spec=template)))
            create_case('deployment-' + label, deployment, policy)

        # A real unscheduled fixture permits real subresource requests without execution.
        for ns in ['laboratorio4', 'default', 'c05-second']:
            obj = copy.deepcopy(pod)
            obj['metadata'].update(name='c05-subresources', namespace=ns)
            obj['spec'].pop('nodeName')
            obj['spec']['schedulingGates'] = [dict(name='laboratorio4.test/no-execution')]
            if not run('fixture-' + ns, ['create', '-f', '-'], obj, record=False):
                raise RuntimeError('Unable to create isolated subresource fixture.')
            cleanup.append((ns, 'c05-subresources'))
            for field, policy in [
                ('conforme', None), ('latest-digest', 'l4-ephemeral-images'),
                ('no-tag', 'l4-ephemeral-images'), ('root', 'l4-ephemeral-nonroot'),
                ('uid-zero', 'l4-ephemeral-nonroot'), ('privileged', 'l4-ephemeral-privileged'),
            ]:
                c = copy.deepcopy(container)
                c.pop('resources')
                c['name'] = 'debug-' + field
                if field == 'latest-digest':
                    c['image'] = 'busybox:latest@' + digest
                elif field == 'no-tag':
                    c['image'] = 'busybox'
                elif field == 'root':
                    c['securityContext'].update(runAsNonRoot=False, runAsUser=0)
                elif field == 'uid-zero':
                    c['securityContext']['runAsUser'] = 0
                elif field == 'privileged':
                    c['securityContext']['privileged'] = True
                patch = dict(spec=dict(ephemeralContainers=[c]))
                run(ns + '-ephemeral-' + field,
                    ['patch', 'pod', 'c05-subresources', '-n', ns, '--subresource=ephemeralcontainers',
                     '--type=merge', '--dry-run=server', '--patch-file', '-'], patch,
                    policy=policy, expected='DENY' if policy else 'ACCEPT')
            # The API itself must reject resource assignments to ephemeral containers.
            c = copy.deepcopy(container)
            c['name'] = 'debug-resources'
            run(ns + '-ephemeral-resources-api',
                ['patch', 'pod', 'c05-subresources', '-n', ns, '--subresource=ephemeralcontainers',
                 '--type=merge', '--dry-run=server', '--patch-file', '-'],
                dict(spec=dict(ephemeralContainers=[c])), expected='API_REJECT')

            c = copy.deepcopy(container)
            c.pop('resources')
            c.update(name='debug-real-denied', image='busybox:latest@' + digest)
            run(ns + '-ephemeral-real-denied',
                ['patch', 'pod', 'c05-subresources', '-n', ns, '--subresource=ephemeralcontainers',
                 '--type=merge', '--patch-file', '-'], dict(spec=dict(ephemeralContainers=[c])),
                policy='l4-ephemeral-images', expected='DENY')

            for label, cpu, memory in [('conforme', '150m', '80Mi'),
                                       ('missing-memory', '150m', None)]:
                limits = dict(cpu=cpu)
                if memory:
                    limits['memory'] = memory
                else:
                    limits['memory'] = None  # strategic merge must remove the old key
                patch = dict(spec=dict(containers=[dict(name='main', resources=dict(
                    requests=dict(cpu='10m', memory='16Mi'), limits=limits))]))
                run(ns + '-resize-' + label,
                    ['patch', 'pod', 'c05-subresources', '-n', ns, '--subresource=resize',
                     '--type=strategic', '--dry-run=server', '--patch-file', '-'], patch,
                    expected='API_REJECT_LIMITS' if memory is None else 'ACCEPT')

        # Actual create requests must be denied too, without creating invalid Pods.
        for field, policy in [('latest', image_policy), ('resources', resource_policy),
                              ('root', root_policy), ('privileged', privileged_policy)]:
            obj = copy.deepcopy(pod)
            obj['metadata']['namespace'] = 'default'
            c = obj['spec']['containers'][0]
            if field == 'latest':
                c['image'] = 'busybox:latest@' + digest
            elif field == 'resources':
                c['resources'] = {}
            elif field == 'root':
                c['securityContext']['runAsUser'] = 0
            else:
                c['securityContext']['privileged'] = True
            cleanup.append(('default', 'c05-real-' + field))
            create_case('real-' + field, obj, policy, dry=False)
    finally:
        cleanup_ok = True
        for ns, name in cleanup:
            cleanup_ok &= run('cleanup-' + ns + '-' + name,
                              ['delete', 'pod', name, '-n', ns, '--ignore-not-found', '--wait=false'], record=False)
        summary = dict(context=args.context, suite=args.suite, results=results, cleanup=cleanup_ok,
                       passed=sum(x['passed'] for x in results), total=len(results))
        (args.report_dir / 'results.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
        log.close()
    print(f'{summary["passed"]}/{summary["total"]} PASS; cleanup={cleanup_ok}')
    return 0 if cleanup_ok and all(x['passed'] for x in results) else 1


if __name__ == '__main__':
    sys.exit(main())
