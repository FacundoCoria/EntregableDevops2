#!/bin/sh
# Herramientas aisladas en el volumen Jenkins; no modifica /usr/bin ni otros jobs.
set -eu
ROOT="${JENKINS_HOME:-/var/jenkins_home}/l4-tools"
mkdir -p "$ROOT/bin" "$ROOT/downloads"
cd "$ROOT/downloads"
fetch() { curl --fail --location --retry 3 --connect-timeout 20 --max-time 300 "$1" -o "$2"; }
verify() {
    expected=$(awk '{print $1}' "$2")
    printf '%s  %s\n' "$expected" "$1" | "$3" -c -
}

echo '== Maven 3.9.16 =='
if [ ! -x "$ROOT/apache-maven-3.9.16/bin/mvn" ]; then
    base=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.16
    fetch "$base/apache-maven-3.9.16-bin.tar.gz" maven.tar.gz
    fetch "$base/apache-maven-3.9.16-bin.tar.gz.sha512" maven.sha512
    verify maven.tar.gz maven.sha512 sha512sum
    tar -xzf maven.tar.gz -C "$ROOT"
fi
ln -sf "$ROOT/apache-maven-3.9.16/bin/mvn" "$ROOT/bin/mvn"

echo '== Snyk 1.1308.4 =='
if [ ! -x "$ROOT/bin/snyk" ]; then
    fetch https://downloads.snyk.io/cli/v1.1308.4/snyk-linux snyk-linux
    echo '979172ee128903f50e43fff221f22a0689579f22c086dabaa0d1a5416485b9ba  snyk-linux' | sha256sum -c -
    cp snyk-linux "$ROOT/bin/snyk"
    chmod 755 "$ROOT/bin/snyk"
fi

echo '== Helm 4.3.1 =='
if [ ! -x "$ROOT/bin/helm" ]; then
    fetch https://get.helm.sh/helm-v4.3.1-linux-amd64.tar.gz helm.tar.gz
    fetch https://get.helm.sh/helm-v4.3.1-linux-amd64.tar.gz.sha256sum helm.sha256
    verify helm.tar.gz helm.sha256 sha256sum
    tar -xzf helm.tar.gz
    cp linux-amd64/helm "$ROOT/bin/helm"
fi

echo '== kubectl 1.37.0 =='
if [ ! -x "$ROOT/bin/kubectl" ]; then
    fetch https://dl.k8s.io/release/v1.37.0/bin/linux/amd64/kubectl kubectl
    fetch https://dl.k8s.io/release/v1.37.0/bin/linux/amd64/kubectl.sha256 kubectl.sha256
    verify kubectl kubectl.sha256 sha256sum
    cp kubectl "$ROOT/bin/kubectl"
    chmod 755 "$ROOT/bin/kubectl"
fi

echo '== Semgrep 1.184.0 =='
if [ ! -x "$ROOT/semgrep-venv/bin/semgrep" ]; then
    python3 -m venv "$ROOT/semgrep-venv"
    "$ROOT/semgrep-venv/bin/python" -m pip install --disable-pip-version-check 'semgrep==1.184.0'
fi
ln -sf "$ROOT/semgrep-venv/bin/semgrep" "$ROOT/bin/semgrep"
"$ROOT/semgrep-venv/bin/python" -m pip freeze > "$ROOT/python-packages.txt"

export PATH="$ROOT/bin:$PATH"
export SEMGREP_SEND_METRICS=off SEMGREP_ENABLE_VERSION_CHECK=0
mvn --version
snyk --version
helm version --short
kubectl version --client
semgrep --version
echo 'L4_TOOLS_READY'
