#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
[[ $# -eq 0 ]] || fail 'Uso: access.sh (Ctrl+C para cerrar conexiones)'
need kubectl; need curl
evidence access
forward api http; echo "API: $FORWARD_URL"; request "$FORWARD_URL/actuator/health"
forward prometheus http; echo "Prometheus: $FORWARD_URL"; request "$FORWARD_URL/-/ready"
forward grafana http; echo "Grafana: $FORWARD_URL/d/l4-observabilidad"; request "$FORWARD_URL/api/health"
echo 'Conexiones en loopback. Ctrl+C cierra solo los túneles de este script.'
wait
