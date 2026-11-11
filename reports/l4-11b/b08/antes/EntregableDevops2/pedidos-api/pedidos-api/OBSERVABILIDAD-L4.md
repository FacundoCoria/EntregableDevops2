# L4-04 — Observabilidad local

El chart 0.2.1 provisiona Prometheus y Grafana desde archivos. No requiere
importar el dashboard ni crear el datasource manualmente. La instrumentación
de `PedidoMetricsService` en main cubre la métrica de negocio; no se integró
la rama `métricas-nuevas` ni se reconstruyó la imagen `pedidos-api:l4-01`.

## Componentes y fuentes

- API: `/actuator/prometheus`, scrape cada 5 s a su Service. Las etiquetas
  `namespace` y `release` distinguen esta instalación de la anterior en `default`.
- Pods: kubelet `/metrics/resource`, mediante proxy HTTPS del API server,
  verificando su CA y usando un token rotativo de ServiceAccount. Se conservan
  solo `pod_cpu_usage_seconds_total` y `pod_memory_working_set_bytes`, del
  namespace y prefijo del release. Son métricas del pod completo.
- Grafana: datasource `l4-prometheus`, URL interna del Service Prometheus,
  proveedor de archivos y dashboard `l4-observabilidad`. Los ConfigMaps y sus
  montajes son reproducibles; el checksum provoca rollout al cambiar archivos.
- Archivo de entrega: `grafana/dashboard.json`, desde la raíz del repositorio.
  Copia para empaquetado Helm: `helm-chart/files/dashboard.json`. Mantenerlas
  sincronizadas al editar el dashboard; los valores de namespace/release de la
  copia se adaptan al renderizar el chart, sin evaluar las leyendas como plantillas.

El chart contiene 16 recursos: tres Deployments, tres Services, tres PVC,
cuatro ConfigMaps, ServiceAccount, ClusterRole y ClusterRoleBinding.
`observability.nodeName` configura el único nodo observado; Minikube usa `minikube`.
La cuenta Prometheus recibe solamente GET de `nodes/proxy` para ese nodo; no tiene
listado de nodos, Secrets, pods ni escritura en la API. La autorización de proxy
no puede restringirse a una ruta de métricas concreta mediante RBAC: ese GET
también alcanza otras rutas del proxy del nodo. Es una concesión explícita del
laboratorio de un nodo; no equivale a un permiso exclusivamente de lectura de
métricas. API y Grafana siguen sin token montado. El filtro de ingestión limita
las series guardadas, no los permisos del token. Un entorno multinodo requiere
otro diseño y validación de acceso a kubelets.

## Paneles e interpretación

| Panel | Medida |
|---|---|
| Solicitudes HTTP por segundo | Suma de `rate(http_server_requests_seconds_count)` de `/api/*`; excluye salud y scrapes |
| Latencia HTTP promedio | `sum(rate(..._sum)) / sum(rate(..._count))`, segundos; ponderada por solicitud |
| CPU por pod | `rate(pod_cpu_usage_seconds_total)`, núcleos utilizados |
| Memoria por pod | `pod_memory_working_set_bytes`, bytes de working set |
| Pedidos creados por producto | `pedidos_creados_total`, desde el arranque del proceso |
| Pedidos creados por segundo | `rate(pedidos_creados_total)`, por producto |

Se usa `$__rate_interval` con intervalo de scrape 5 s. `rate` contempla reinicios
de contadores y se aplica antes de sumar series. La latencia sin solicitudes puede
no tener valor; no se convierte una división 0/0 en una latencia ficticia de cero.
El contador de negocio se reinicia al reiniciar Java y no cuenta los pedidos
históricos recuperados de H2. `estado` es el estado inicial registrado al crear
el pedido; no mide transiciones. Los minutos de espera del negocio no se usan
como latencia HTTP. Evitar nombres de producto dinámicos sin límite en uso continuo,
porque cada etiqueta nueva crea otra serie.

## Despliegue y verificación

Grafana solicita 512 MiB y tiene límite de 1 GiB, tanto en Helm como en el
manifiesto base. El límite inicial de 256 MiB produjo `OOMKilled` (salida 137)
durante la revisión visual del 10/11, aunque las primeras consultas habían pasado.
Se conservó ese diagnóstico y se elevó la memoria en la revisión 4 del release;
el nuevo dimensionamiento se comprueba con los seis paneles actualizándose.
La documentación de [instalación de Grafana](https://grafana.com/docs/grafana/latest/setup-grafana/installation/)
recomienda un mínimo de 512 MB para evaluación; el margen elegido aquí responde
también a la caída observada. No es un dimensionamiento productivo.

Si el contenedor de destino reinicia, el port-forward puede cerrarse; que el pod
vuelva a Ready no restablece automáticamente la conexión local. El agente debe
abrirla de nuevo antes de pedir a Bruno que recargue la página.

Desde la raíz de la aplicación:

```powershell
helm lint ./helm-chart -f ./helm-chart/values-dev.yaml --strict
helm upgrade l4 ./helm-chart --kube-context minikube -n laboratorio4 -f ./helm-chart/values-dev.yaml --wait --timeout 6m
./scripts/verify-observability.ps1 -EvidenceDir ./observability-evidence
```

El verificador abre conexiones solo en loopback en 18080/19090/13000 y las cierra
al terminar. `-KeepForwarding` las deja disponibles tras un resultado exitoso y
registra sus procesos. Requiere esos puertos libres. Usa el acceso inicial local
de Grafana; si se cambió, admite `L4_GRAFANA_USER` y `L4_GRAFANA_PASSWORD` sin escribir
credenciales ni cookies en las evidencias. No reinicia contraseñas.

Genera tráfico acotado durante 90 s, crea un producto y pedidos de prueba que
permanecen en H2, comprueba ambos targets UP, ejecuta las seis consultas en
Prometheus y a través del datasource de Grafana, exige valores válidos y series
de CPU/memoria para todos los pods del release, y correlaciona el contador del
producto con los pedidos realmente creados. Guarda respuestas, exportación real
del dashboard, métricas, tráfico y resultado final; un error no genera PASS.
No mide capacidad ni constituye una prueba de carga.

Para revisión visual, con las conexiones activas, Bruno abre
`http://127.0.0.1:13000/d/l4-observabilidad`. El dashboard consulta los últimos
15 minutos y refresca cada 5 s. Después de finalizar el tráfico, RPS puede caer a
cero y latencia puede quedar sin valor; seleccionar el intervalo de prueba
para revisar lo ocurrido. Los paneles de negocio se inicializan al crear pedidos.

Las evidencias de esta etapa se guardan fuera del repositorio, en
`handoffs/evidencias_l4_04_2026-11-10/` desde la carpeta general del proyecto.
No se modifican los reportes de seguridad anteriores ni el Word de E3.

Referencias oficiales: [provisionamiento Grafana](https://grafana.com/docs/grafana/latest/administration/provisioning/),
[métricas Kubernetes](https://kubernetes.io/docs/reference/instrumentation/metrics/),
[fuentes kubelet](https://kubernetes.io/docs/reference/instrumentation/node-metrics/),
[funciones PromQL](https://prometheus.io/docs/prometheus/latest/querying/functions/).
