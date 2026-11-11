"""Gate cerrado ante errores; solo un analisis valido sin criticos permite seguir."""
import json
import sys
from collections import Counter
from pathlib import Path


def main():
    if len(sys.argv) != 3:
        raise ValueError('Se requieren ruta JSON y codigo de salida Snyk')
    result = int(sys.argv[2])
    if result not in (0, 1):
        raise ValueError(f'Snyk no completo el analisis: exit {result}')
    data = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
    if not isinstance(data, dict) or data.get('error') or data.get('success') is False:
        raise ValueError('Respuesta Snyk de error o formato inesperado')
    findings = data.get('vulnerabilities')
    if not isinstance(findings, list):
        raise ValueError('No hay lista vulnerabilities: analisis no acreditado')
    levels = {'low', 'medium', 'high', 'critical'}
    if any(not isinstance(v, dict) or v.get('severity') not in levels for v in findings):
        raise ValueError('Severidad Snyk ausente o desconocida')
    if (result == 0 and findings) or (result == 1 and not findings):
        raise ValueError('Inconsistencia entre salida Snyk y hallazgos')
    counts = Counter(v['severity'] for v in findings)
    summary = {
        'scan_exit_code': result,
        'findings_by_severity': {s: counts[s] for s in sorted(levels)},
        'critical_ids': sorted({v['id'] for v in findings if v['severity'] == 'critical'}),
        'gate': 'BLOCKED_CRITICAL' if counts['critical'] else 'PASS',
    }
    Path(sys.argv[1]).with_name('gate-summary.json').write_text(
        json.dumps(summary, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(summary, indent=2))
    return 1 if counts['critical'] else 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError, KeyError, TypeError) as exc:
        print(f'BLOCKED_SCAN_ERROR: {exc}', file=sys.stderr)
        sys.exit(2)
