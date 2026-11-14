#!/bin/sh
# Ejecutar dentro de la imagen agente. Fixture propio; no altera herramientas reales.
set -eu
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin"
ln -s /opt/l4-tools/apache-maven-3.9.16 "$fixture/apache-maven-3.9.16"
ln -s /opt/l4-tools/semgrep-venv "$fixture/semgrep-venv"
ln -s /opt/l4-tools/bin/helm "$fixture/bin/helm"
ln -s /opt/l4-tools/bin/kubectl "$fixture/bin/kubectl"
printf '#!/bin/sh\necho 0.0.0\n' > "$fixture/bin/snyk"
chmod 755 "$fixture/bin/snyk"
if L4_TOOLS_ROOT="$fixture" sh /opt/l4/bootstrap-tools.sh > "$fixture/result.txt" 2>&1; then
    echo 'FAIL: acepto Snyk incorrecto' >&2
    exit 1
fi
grep -F 'ERROR version Snyk: esperado 1.1308.4, encontrado 0.0.0' "$fixture/result.txt"
echo VERSION_MISMATCH_REJECTED
