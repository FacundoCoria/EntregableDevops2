# B03 — parametrización Helm segura

11/11/2026, Uruguay. Implementación y verificación local completas, chart 0.3.0.

## Decisión y cambios

`components.api/prometheus/grafana.port` acepta enteros 1024–65535. El puerto
configura el proceso (SERVER_PORT, --web.listen-address, GF_SERVER_HTTP_PORT),
containerPort y Service. Sondas usan `http`; scrape de API y datasource Grafana
usan los valores del Service. ConfigMaps mantienen checksum para recreación.

`components.<nombre>.replicas` acepta 0 (pausa) o 1 (activo, predeterminado).
Recreate y PVC únicos preservados. H2 embebida, TSDB y SQLite no se convierten
en servicios HA por permitir más Pods. Dos o más réplicas se rechazan por
esquema; ampliar el rango requiere rediseñar almacenamiento/arquitectura.
La pausa retiene Service/PVC e interrumpe disponibilidad. Rutas de datos fijas.
No se ofrece escalado horizontal libre ni un entorno productivo acreditado.

Scripts Bash de acceso/tráfico/inicio y verificador PowerShell ahora conectan
por puerto de Service nombrado `http`; Jenkins localhost:8080 queda igual.
Guía del chart actualizada en el alcance de B03 y antecedentes contextualizados;
B08 global sigue pendiente. appVersion l4-01 es metadato histórico, separado de
la imagen efectiva configurada en cada release.

## Evidencia comprobada

En [b03/](b03/):

- Tres `helm lint --strict` exitosos: común, dev y variante.
- Cuatro renders: común, dev, alternativo y pausa (tres Deployments en 0).
  16 recursos por render; coherencia de puertos/procesos/sondas/scrape/datasource
  comprobada. `local-result.json` y YAML completos conservados.
- 15 rechazos esperados: por componente réplicas 2/-1 y puertos 80/65536/texto.
- Dry-run de servidor de render común y alternativo: 16 recursos aceptados,
  con políticas Kyverno existentes. No se modificó la política.
- Instalación temporal `l4-b03-check` en `laboratorio4`: API 18081, Prometheus
  19091, Grafana 13001; imagen API publicada #7 fijada por digest 48b65d….
  API UP, Prometheus Ready, Grafana database ok; scrape API en 18081 UP y
  kubelet UP. [runtime-result.json](b03/runtime-result.json).
- Desinstalación y eliminación explícita de los tres PVC temporales; sin recursos
  del prefijo temporal entre Deployment/Service/PVC/ConfigMap/ServiceAccount;
  Helm retiró su RBAC. Túneles cerrados comprobados por conexión fallida.
  [cleanup-result.json](b03/cleanup-result.json).
- Release principal `l4` revisión 10 conservado: captura Helm antes/después
  idéntica salvo resourceVersion periódico de tres Pods relacionados; objetos
  Deployment seleccionados idénticos. Pods principales mismos nombres/UID,
  Running/Ready, sin reinicios. No upgrade del release principal.
- Sintaxis de cada Bash modificado y parseo PowerShell PASS. No se repitió el
  ciclo completo start/tráfico/persistencia: sus verificaciones L4-03/L4-10
  son antecedentes, no ejecuciones nuevas de estos scripts.
- 464 archivos previos de reportes/Word/PDF intactos por SHA256;
  `preservacion-antes.json` / `preservacion-resultado.json`.

## Intentos y límites

Primera lectura Kubernetes y primera comprobación Bash restringidas por acceso;
repetidas con acceso suficiente, exitosas. Helm 4 no acepta `list --all`:
intento fallido conservado en `releases-before-intento-flag.txt`, luego list
correcto. El primer auditor marcó diferencia por resourceVersion de Pods
(metadato periódico): comparación corregida sin omitir otros campos y auditada
sin reinstalar. Esto no fue fallo de Helm install ni cambio de configuración.

La variante con cero réplicas fue renderizada, no aplicada. Puertos alternativos
sí ejecutados en procesos reales; no se probó cada uno de los 64.512 puertos
admitidos ni persistencia tras recreación en esta etapa. El límite mínimo 1024
evita depender de puertos privilegiados con usuarios sin root.

Fuentes de configuración de procesos: [Spring Boot](https://docs.spring.io/spring-boot/3.3/how-to/webserver.html),
[Prometheus](https://prometheus.io/docs/prometheus/latest/command-line/prometheus/),
[Grafana](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/).

Implementación, reporte y evidencias solo locales. Sin commit, push, nueva imagen,
scan de vulnerabilidades, ejecución Jenkins, cambios Word ni informe integrador.
B02 literal, B04/B08, publicación e informe conservan sus pendientes propios.
