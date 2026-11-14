FROM jenkins/jenkins:lts-jdk21

USER root

# Herramientas base (Maven lo necesita Snyk para resolver las dependencias del pom.xml)
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg maven python3 python3-venv \
 && rm -rf /var/lib/apt/lists/*

# Docker CLI (el daemon es el del host, vía /var/run/docker.sock)
RUN install -m 0755 -d /etc/apt/keyrings \
 && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce-cli \
 && rm -rf /var/lib/apt/lists/*

# Semgrep
RUN python3 -m venv /opt/semgrep \
 && /opt/semgrep/bin/pip install --no-cache-dir semgrep \
 && ln -s /opt/semgrep/bin/semgrep /usr/local/bin/semgrep

# Snyk CLI
RUN ARCH=$(dpkg --print-architecture) \
 && if [ "$ARCH" = "arm64" ]; then F=snyk-linux-arm64; else F=snyk-linux; fi \
 && curl -fsSL "https://static.snyk.io/cli/latest/$F" -o /usr/local/bin/snyk \
 && chmod +x /usr/local/bin/snyk

# kubectl
RUN ARCH=$(dpkg --print-architecture) \
 && curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

USER jenkins
