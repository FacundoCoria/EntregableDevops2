# Falco — Laboratorio 4

Prueba L4-08 verificada localmente el 11/11/2026. Resultado y límites en
[`reports/falco-event.md`](../../../../reports/falco-event.md), registro requerido
en [`reports/falco-event.log`](../../../../reports/falco-event.log).

## Instalación reproducible en el entorno utilizado

Requiere perfil Minikube/containerd existente, Helm, kubectl y acceso a imágenes
oficiales. Ejecutar desde la raíz de EntregableDevops2. El namespace `falco`
está fuera del selector de políticas L4; el Pod de prueba cumple esas políticas.
El chart instala un DaemonSet de detección syscall; no necesita un operador.

```bash
helm pull falco --repo https://falcosecurity.github.io/charts --version 9.2.2
# Verificar SHA256 del tgz:
# b8a1aa984c3d513ab1639be760e6a07a9eb203d4da77a45a1512d382b6d3687d
helm upgrade --install falco ./falco-9.2.2.tgz --kube-context minikube --namespace falco --create-namespace \
  -f pedidos-api/pedidos-api/security/falco/values-minikube.yaml --wait --timeout 6m
kubectl --context minikube -n falco rollout status daemonset/falco --timeout=60s
kubectl --context minikube -n falco logs -l app.kubernetes.io/name=falco -c falco
```

En esta sesión se usó el tgz verificado guardado fuera del repo, en
`.tools/helm/falco-9.2.2.tgz` de la carpeta general. El SHA se cotejó con el
índice oficial; `reports/l4-08/chart-source.json` identifica versiones/digests.
Valores configurados: modern eBPF con capacidades específicas, JSON sin buffer,
UTC/ISO 8601, socket containerd y seguimiento de reglas deshabilitado. Se conservan
defaults, render, configuración, reglas y valores efectivos en `reports/l4-08/`.
El modo de capacidades aún necesita permisos y montajes del host; no equivale
a un contenedor de aplicación sin privilegios de observación.

## Verificación de evento y limpieza

En PowerShell, desde la raíz del repo:

```powershell
& ./pedidos-api/pedidos-api/scripts/verify-falco.ps1 -Context minikube
```

El script rechaza sobrescribir el log existente. Antes de repetir, conservar
íntegra la evidencia y elegir explícitamente otro destino en una nueva ejecución.
Crea solo el Pod/ConfigMap de `test-sensitive-read.yaml`, comprueba UID 10001,
lee `/etc/hostname` como control y después el `/etc/shadow` ficticio mediante
`kubectl exec ... -- cat /etc/shadow`. No ejecuta shell ni lee el shadow del host.
Verifica regla, container ID, ruta, proceso, UID y ventana UTC; conserva evento
JSON, identidad del Pod y correlación. Elimina sus dos recursos al terminar.

Resultados esperados: exit 0, RESULT PASS, una alerta Warning correlacionada,
cero alertas de esa regla en el control, Pod y ConfigMap retirados. Ante un fallo
se conserva RESULT FAIL; no interpretar falta de alerta como prueba exitosa.
Falco quedó instalado al cerrar L4-08. Los scripts de ciclo de vida ya se
consolidaron en L4-10/B04: [guía](../../../../scripts/l4/GUIA.md) y
[reproducción/limpieza aislada](../../../../scripts/l4/B04-REPRODUCCION.md).
B04 retiró realmente seguridad y perfil temporal; conservó el principal.

Fuentes consultadas el 11/11/2026:
- https://falco.org/docs/getting-started/learning-environments/
- https://falco.org/docs/reference/rules/default-rules/
- https://github.com/falcosecurity/charts/tree/falco-9.2.2/charts/falco

Tags de imagen y `falco-rules:5` pueden resolver a contenido nuevo al reinstalar;
esta ejecución conserva imageIDs, digest OCI de reglas, verificación de firma
y copia efectiva. No se modificaron las reglas oficiales para forzar la alerta.
