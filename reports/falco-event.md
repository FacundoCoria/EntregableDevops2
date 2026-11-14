# L4-08 — Evento Falco

Prueba local del 11/11/2026. **PASS**, una alerta correlacionada. El registro
exigido es [falco-event.log](falco-event.log); datos estructurados y configuración
en [l4-08/](l4-08/). Esta descripción técnica no es el informe integrador.

## Acción y resultado

Se creó `l4-08-falco-read` en `laboratorio4`, imagen `busybox:1.36.1`,
UID/GID 10001, sin privilegios, sin token de servicio, raíz de solo lectura y
requests/limits. Kyverno admitió el manifiesto mediante dry-run y create real.
Un ConfigMap montó en `/etc/shadow` el texto público
`l4_falco_fixture:!:20000:0:99999:7:::`. No se accedió a contraseñas reales.

Se ejecutó directamente, sin shell, `-it` ni TTY:

```bash
kubectl --context minikube -n laboratorio4 exec l4-08-falco-read -c reader -- cat /etc/shadow
```

La apertura del archivo por `cat` disparó la regla oficial estable
`Read sensitive file untrusted`, prioridad **Warning**, fuente `syscall`,
evento `openat`. La regla considera sensible la ruta `/etc/shadow` y exceptúa
programas conocidos; `cat` no quedó exceptuado en las reglas cargadas.
La lectura previa `cat /etc/hostname` no generó esa alerta para este contenedor
durante ocho segundos de observación; no es una afirmación sobre otras reglas.

| Campo | Evidencia |
|---|---|
| Acción UTC | 2026-11-11T14:40:57.6847494Z → 2026-11-11T14:40:58.0173882Z |
| Evento UTC | 2026-11-11T14:40:58.000012516Z |
| Hora Uruguay | 11/11/2026, 11:40:58 (UTC−03) |
| Pod / namespace | l4-08-falco-read / laboratorio4 |
| Container ID Falco | e3770cf0a5d3 |
| Container ID Kubernetes | e3770cf0a5d3cff6e0e46d28e4a2f8152d392f208683492734c309351400042f |
| Proceso / archivo / UID | cat / /etc/shadow / 10001 |
| Imagen resuelta | docker.io/library/busybox@sha256:73aaf090f3d85aa34ee199857f03fa3a95c8ede2ffd4cc2cdb5b94e566b11662 |

La coincidencia de identidad, ruta, proceso, usuario y tiempo acredita que
el evento corresponde a la acción deliberada. `proc.tty=0` y
`proc.pname=containerd-shim` acompañan la ejecución directa; no se usa una alerta
de shell para cumplir L4. El Pod y el ConfigMap fueron eliminados después de
guardar la evidencia; `cleanup-state.json` no contiene recursos de prueba.

## Entorno y alcance

Falco 0.45.2, chart oficial 9.2.2, release `falco` revisión 1, namespace `falco`.
Minikube v1.39.0, Kubernetes 1.37.0, containerd 2.3.4, kernel WSL2
6.6.87.2-microsoft-standard-WSL2. Modern eBPF operativo, plugin container 0.7.6.
Modo de capacidades BPF/SYS_RESOURCE/PERFMON/SYS_PTRACE, sin privileged=true;
AppArmor Unconfined y acceso a rutas/socket del host según el chart.
Falco tiene 1/1 agente Ready, cero reinicios al cierre. API/Prometheus/Grafana
siguen Ready; cuatro políticas Kyverno Ready. No hubo upgrade de la aplicación.

Esto demuestra detección, no bloqueo: Falco permitió terminar la lectura.
La prueba usa un archivo ficticio con ruta sensible; no demuestra robo de
credenciales, intrusión real ni cobertura de todos los eventos del clúster.
Es un laboratorio de un nodo, sin envío externo de alertas ni prueba de carga.
El chart avisa de una anotación AppArmor obsoleta, pero el Pod efectivo incluye
`appArmorProfile: Unconfined`; el arranque eBPF y la detección fueron exitosos.
Los iteradores BPF quedaron deshabilitados automáticamente; no impidió la captura.

La referencia de reglas `falco-rules:5` puede cambiar al reiniciar el agente;
seguimiento automático desactivado, digest OCI, firma verificada y reglas
efectivas archivadas en esta ejecución. Ver `chart-source.json` y
`artifact-install.log`. Las imágenes con tag tienen imageID registrado.

Fuentes: [reglas oficiales](https://falco.org/docs/reference/rules/default-rules/),
[chart oficial](https://github.com/falcosecurity/charts/tree/falco-9.2.2/charts/falco),
[Falco en Minikube](https://falco.org/docs/getting-started/learning-environments/).
La evidencia nueva es local; el log histórico E3 `.txt` permanece intacto.
No se publicó ni se modificó Word. Los hallazgos Snyk/Trivy siguen abiertos.
