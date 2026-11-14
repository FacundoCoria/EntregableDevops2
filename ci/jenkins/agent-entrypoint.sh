#!/bin/sh
set -eu
test "$(id -u)" = 1000
test ! -S /var/run/docker.sock
if [ ! -e /var/jenkins_home/l4-tools ]; then
    ln -s /opt/l4-tools /var/jenkins_home/l4-tools
fi
test "$(readlink /var/jenkins_home/l4-tools)" = /opt/l4-tools
attempt=0
until [ -s /run/l4-agent/secret ] && curl -fsS http://controller:8080/jnlpJars/agent.jar -o /var/jenkins_home/agent.jar; do
    attempt=$((attempt + 1))
    [ "$attempt" -lt 180 ] || exit 1
    sleep 2
done
exec java -jar /var/jenkins_home/agent.jar -url http://controller:8080 \
    -secret @/run/l4-agent/secret -name l4-agent -webSocket -workDir /var/jenkins_home
