# Imagen publicada — L4-11B/B01

Fecha: 11/11/2026, Uruguay. **B01 cerrada: análisis realizado; dos HIGH permanecen abiertos.** Reporte técnico de 1.d–e, separado del informe final.

Imagen: `brunovitola/pedidos-api-l4@sha256:48b65d95763c2a1eb6727f9b22b78fc27509f79b62a7b87903cea87a4aee41d9`; etiqueta histórica Jenkins #7 `l4-7-0f47780b51b3`. Pull por digest confirmado en esta sesión; no hubo build, push ni despliegue.

Manifiesto linux/amd64: `sha256:48b65d95763c2a1eb6727f9b22b78fc27509f79b62a7b87903cea87a4aee41d9`. Configuración OCI/ID Trivy: `sha256:859e7bc1a1a1323cd7b507479eb79755bf00da50cd2cbe83d5464ecd3e3557d3`. A diferencia de L4-02, este digest publicado apunta directamente a un manifiesto, no a un índice multiplataforma. Ocho blobs verificados por SHA256 y tamaño, ocho DiffIDs coincidentes Docker/configuración/Trivy/Dive. Usuario de imagen `10001:10001` (metadato, no ejecución runtime nueva).

## Tamaño y composición

| Medida | L4-02 anterior | Publicada #7 |
|---|---:|---:|
| Docker inspect, bytes | 150573049 | 150630157 |
| Blobs comprimidos OCI, bytes | 150563497 | 150621357 |
| Archivos Dive, bytes | 346863490 | 346922869 |
| Capas filesystem | 8 | 8 |
| Eficiencia Dive | 98,6732 % | 98.6734 % |

Tamaño almacenado Docker: 150.63 MB decimales; aumento de 57108 bytes. El contenido Dive (346.92 MB) es descomprimido: no sumarlo ni compararlo como descarga. TAR: 150644736 bytes; huella en archive-manifests.json fuera del repositorio.

| Capa | Contenido | Bytes de archivos |
|---|---|---:|
| 0 | Ubuntu 22.04 | 78092943 |
| 1 | Paquetes Temurin | 42837090 |
| 2 | JRE Temurin | 165625294 |
| 3 | Verificación Java | 0 |
| 4 | Certificados | 5977 |
| 5 | WORKDIR | 0 |
| 6 | Usuario y /data | 3245291 |
| 7 | JAR API | 57116274 |

Dive Windows 0.13.1, JSON y CI independientes con exit 0; CI PASS, dos reglas aprobadas y una desactivada. Ineficiencia estimada: 5465165 bytes. JAR único de 57116274 bytes; no se localizaron javac, /workspace ni /root/.m2 en listas Dive.

Optimización ya presente: multi-stage JDK→JRE y copia única del JAR. Persisten expansión de lastlog/faillog y duplicaciones heredadas. Evaluar `useradd --no-log-init` en una futura construcción, midiendo efecto real; no borrar metadatos dpkg/identidad. El JRE domina el tamaño: un runtime menor/jlink exige validar compatibilidad, certificados, H2 y métricas. No se aplicaron optimizaciones nuevas en B01.

## Trivy y comparación

Trivy 0.76.1, `--scanners vuln`, todas las severidades, sin `--ignore-unfixed`; finalización `2026-11-11T18:19:57.344056192Z`. Exit 0 acredita ejecución, no ausencia de hallazgos ni gate. Bases reutilizadas vigentes según metadatos: general UpdatedAt 10/11 19:01:23 UTC, NextUpdate 11/11 19:01:23 UTC; Java UpdatedAt 10/11 00:57:42 UTC, NextUpdate 13/11 00:57:42 UTC. Fechas de actualización/descarga iguales a L4-02; no se descargó otra base en esta sesión.

| Severidad | L4-02 | Publicada #7 |
|---|---:|---:|
| CRITICAL | 4 | 0 |
| HIGH | 7 | 2 |
| MEDIUM | 25 | 23 |
| LOW | 16 | 16 |
| Total filas | 52 | 41 |
| IDs distintos | 41 | 30 |

Las 41 filas actuales son de Ubuntu (143 paquetes detectados); Java se analizó con 83 paquetes y cero vulnerabilidades detectadas. Once pares paquete/ID Java anteriores ya no aparecen (4 críticos, 5 altos, 2 medios); ningún par nuevo. Los 41 pares Ubuntu persisten. El cambio comprobado de Tomcat/Jackson y las mismas fechas de bases respaldan esta comparación; no es ausencia universal de vulnerabilidades ni prueba de explotación/alcanzabilidad.

Paquetes reconocidos en el JSON actual:

- `org.apache.tomcat.embed:tomcat-embed-core`: `11.0.27`.
- `org.glassfish.jaxb:jaxb-runtime`: `4.0.9`.
- `tools.jackson.core:jackson-core`: `3.1.8`.
- `tools.jackson.core:jackson-databind`: `3.1.8`.

### Altos abiertos y tratamiento

| ID | Paquete | Instalada | Corregida según Trivy |
|---|---|---|---|
| CVE-2026-109518 | apt | 2.4.14 | 2.4.15ubuntu0.1 |
| CVE-2026-109518 | libapt-pkg6.0 | 2.4.14 | 2.4.15ubuntu0.1 |

Ambos HIGH corresponden a CVE-2026-109518, reutilización de hard links en reintentos de descarga de apt. Revisar base Temurin corregida o actualización controlada del paquete a la versión indicada; reconstruir con otra identidad, probar API/JSON/H2/métricas y reescanear. No se modificó esta imagen ni se confirmó alcanzabilidad; apt no es la función de negocio de la API, pero eso no elimina el hallazgo. MEDIUM/LOW quedan en JSON/tabla para seguimiento del proveedor.

Snyk Maven #7 sigue registrando una alta JAXB, ocho medias y una baja. Trivy reconoce jaxb-runtime 4.0.9 sin señalar esa alta en esta ejecución; no se declara falso positivo ni resuelto Snyk. Son herramientas y alcances diferentes (Snyk incluye test, imagen contiene runtime). No sumar sus filas como vulnerabilidades únicas.

## Evidencias

[Trivy JSON](trivyreport.json), [tabla](trivyreport.txt), [fechas de bases](trivy-version.txt), [Dive JSON](dive.json), [CI Dive](dive-ci.txt), [resumen/comparación por paquete-ID](resumen.json), [comandos](COMANDOS.md). Identificación, TAR/manifiestos y huellas en `handoffs/evidencias_l4_11b_2026-11-11/`, fuera del repositorio. Diagnóstico L4-02 y resultados iniciales conservados.

Solo API publicada; no imágenes de terceros, secretos, configuración, explotación ni salud actual del clúster. Código/reportes nuevos locales sin commit/push. E3 pausado; informe final no modificado. B02–B04/B08 pendientes de continuidad.
