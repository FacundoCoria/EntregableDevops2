# B05 — consolidación y fuente de entrega

Fecha: 11/11/2026, Uruguay. Rama: `lab4/b05-consolidacion-entrega`.
Este registro describe la entrega técnica; el informe integrador sigue en B06.

## Contenido y evidencia

- [Jenkinsfile](../Jenkinsfile), [herramientas y gate](../ci/),
  [scripts operativos](../scripts/l4/GUIA.md),
  [chart Helm 0.3.0](../pedidos-api/pedidos-api/helm-chart/README.md).
- [Índice vigente de evidencias](../reports/ESTADO-EVIDENCIAS-L4.md),
  [dashboard](../grafana/dashboard.json), resultados iniciales y posteriores.
- Los logs de Falco/Kyverno y demás evidencias se versionan con bytes originales.
  Los scripts y el wrapper Maven se entregan con permisos de ejecución y LF.
  Los handoffs administrativos externos al repositorio se conservan en la carpeta
  general del proyecto; sus referencias históricas no implican archivos publicados.

## Reconciliación con main

Se incorpora el commit remoto
[`ee6bc93`](https://github.com/FacundoCoria/EntregableDevops2/commit/ee6bc93).
La integración se realiza en esta rama de entrega; `main` no se modifica.
Las tres divergencias de Deployment se resuelven conservando la configuración
probada de L4: API local `pedidos-api:l4-01`, Prometheus v3.16.0 y Grafana 13.0.12
fijados por digest, recursos, PVC y estrategia Recreate. La API publicada #7 se
selecciona mediante Helm y sus overrides, como documentan las guías.

El cambio remoto de API a `facundocoria/pedidos-api:1.0`, las versiones anteriores
de monitoreo y sus límites de 256 MiB quedan en el historial original de main;
no se combinan con resultados de versiones L4 diferentes. Grafana conserva 1 GiB
por la corrección OOM comprobada. Se conserva el renombrado remoto de
`monitoring/prometheus/prometheus.yml` a `prometheus.yaml` y se actualiza la ruta
de Kustomize; la clave montada dentro del contenedor sigue siendo `prometheus.yml`.

## Conexión Jenkins prevista

Repositorio: `https://github.com/FacundoCoria/EntregableDevops2.git`.
Rama: `lab4/b05-consolidacion-entrega`. Script Path: `Jenkinsfile`.
Configurar el trabajo existente `L4-09-pedidos-api` como **Pipeline script from SCM**,
SCM Git, URL anterior, Branch Specifier `*/lab4/b05-consolidacion-entrega`.
Bruno realiza ese cambio de interfaz después de comprobar la publicación.

El Jenkinsfile toma esa URL/rama como defaults y resuelve ramas de `origin` tras
clonar. Las credenciales `l4-snyk-token` y `l4-dockerhub`, herramientas y conexión
Kubernetes siguen siendo prerrequisitos del entorno Jenkins existente.
Si aparecen parámetros guardados del job anterior, reemplazar SOURCE_URL y
SOURCE_REF por los anteriores antes de una ejecución integral.

La conexión SCM y una clonación remota nueva no equivalen a repetir las seis
etapas. El SUCCESS #7 corresponde al snapshot local `0f47780`; el chart 0.3.0
posterior se probó separadamente en B03/B04. Un nuevo build integral publica otra
imagen y actualiza el release principal: registrar sus resultados por separado.

## Límites de la entrega

B02 literal y B04 global/Jenkins desde cero siguen parciales. B06 es el informe;
B07/B09 conservan hallazgos y límites de seguridad. Snyk #7 mantiene una alta y
nueve hallazgos de otros niveles; Trivy B01 mantiene dos altos Ubuntu.
No se afirma conformidad global ni un análisis nuevo por consolidar estos archivos.
La publicación y la conexión SCM deben comprobarse antes de marcar B05 completa.
