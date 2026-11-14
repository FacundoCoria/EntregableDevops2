# Análisis de imagen — resultado vigente y diagnóstico histórico

**11/11/2026 — L4-11B/B01 completada sobre la imagen publicada #7.**
Digest `sha256:48b65d95763c2a1eb6727f9b22b78fc27509f79b62a7b87903cea87a4aee41d9`.
Trivy: **0 CRITICAL, 2 HIGH, 23 MEDIUM, 16 LOW**; 41 filas, 30 IDs.
Docker: **150.630.157 bytes**, ocho capas; Dive: **98,6734 %** de eficiencia.
Los dos HIGH Ubuntu siguen abiertos; Snyk #7 conserva su alta independiente.
[Análisis actual completo, comparación y tratamiento](l4-11b/image-analysis.md).

El texto siguiente conserva íntegro el diagnóstico L4-02 del 10/11. Sus frases
«pendiente Snyk/Jenkins», versiones candidatas y once prioritarios describen aquel
momento; la comparación vigente está enlazada arriba. No atribuir los 52 hallazgos
históricos a la imagen publicada. No es el informe integrador final.

---

# Análisis de la imagen - Laboratorio 4, L4-02

Fecha: 10/11/2026, Uruguay. Evidencia local nueva sobre la imagen de L4-01. Reporte técnico del requisito 1.d-e; no constituye el informe integrador final.

## Imagen y alcance

- Etiqueta: `pedidos-api:l4-01`; plataforma: `linux/amd64`; usuario: `10001:10001`.
- ID Docker/índice OCI: `sha256:5a76e0b66f7bf62d97788dee808402bbac40f6936b4508b0079cf2566bad5279`.
- Manifiesto linux/amd64: `sha256:40b5f344d9ca1a80965434d32589a6379b2dcfa783044ccb7ede83d567cf61de`.
- Configuración OCI: `sha256:1cb073e6aa69c2f35d61a2cbeb5816e06e5e54daed81f4cad580992102e22b72`; ID informado por Trivy: `sha256:1cb073e6aa69c2f35d61a2cbeb5816e06e5e54daed81f4cad580992102e22b72`. Los identificadores designan objetos distintos; la correspondencia se conserva en `archive-manifests.json`.
- Rama `lab4/l4-01-docker-manifiestos`, HEAD base `489f9f37a2275a5e284769fdbb511c0855c1c384`; Dockerfile y demás cambios L4 locales sin commit/publicación. El commit base no contiene esos cambios.
- Runtime Temurin 21.0.13+9 JRE Jammy fijado por digest en Dockerfile. No se reconstruyó ni se modificaron dependencias en esta etapa.

## Tamaño y capas

| Medición | Bytes | MB decimales |
|---|---:|---:|
| Docker inspect Size | 150573049 | 150.57 |
| Suma de blobs gzip de las 8 capas OCI | 150563497 | 150.56 |
| Contenido de archivos contabilizado por Dive | 346863490 | 346.86 |
| TAR exportado con metadatos | 150593024 | 150.59 |

Docker está usando capas OCI gzip: por eso su tamaño almacenado se aproxima al de los blobs comprimidos y difiere del contenido contabilizado por Dive. No interpretar el tamaño de Dive como descarga ni sumar ambas métricas. `docker history` también incluye metadatos y sobrecarga de filesystem: sus tamaños no son esta misma medición.

RootFS/Dive identifican **8 capas de filesystem**, incluidas dos sin contenido de archivos. Las instrucciones de configuración (USER, ENV, EXPOSE, ENTRYPOINT) no agregan capas de archivos.

| Índice Dive | Contenido | Bytes de archivos |
|---|---|---:|
| 0 | Ubuntu 22.04 base | 78092943 |
| 1 | Paquetes auxiliares de Temurin | 42837090 |
| 2 | JRE Temurin | 165625294 |
| 3 | Verificación Java, sin archivos nuevos | 0 |
| 4 | Script de certificados | 5977 |
| 5 | WORKDIR /app, sin contenido de archivos | 0 |
| 6 | Usuario/grupo y /data | 3245291 |
| 7 | JAR de la API | 57056895 |

## Dive y optimizaciones

Dive **0.13.1 para Windows** sobre el TAR: eficiencia estimada **98.6732 %**, **5465165 bytes** considerados ineficientes (5,47 MB). Ejecución JSON exitosa y evaluación CI separada: PASS, 2 reglas aprobadas, 0 fallidas, 1 omitida (highestWastedBytes desactivada). Umbrales predeterminados: eficiencia mínima 90 %, userWastedPercent máximo 10 %; valor observado de este último 2,0334 %. Estas medidas describen almacenamiento, no seguridad.

- Ya implementado en L4-01: multi-stage, solo JAR hacia JRE, usuario no root y exclusión de reportes/datos/target del contexto. Dive confirma `/app/app.jar` (57.056.895 bytes, UID/GID 10001); no se localizaron en sus listas `javac`, `/workspace` ni `/root/.m2`.
- La capa de creación de usuario aumenta `/var/log/lastlog` y `/var/log/faillog`. Evaluar `useradd --no-log-init` en una próxima reconstrucción y medir de nuevo. El ahorro en archivos descomprimidos no equivale a igual ahorro en blobs gzip: la capa completa de usuario ocupa solo 4.705 bytes comprimidos.
- Duplicación principal informada por Dive: lastlog (2.950.076 bytes), debconf/templates.dat (1.364.285), dpkg.log (408.717), faillog (323.296). Gran parte es heredada del runtime; no eliminar bases de dpkg ni archivos de identidad para mejorar una puntuación.
- Considerar runtime menor o jlink únicamente con pruebas de compatibilidad, certificados, librerías nativas, persistencia y observabilidad. El JRE y Ubuntu dominan el contenido; borrar archivos heredados en una capa posterior no elimina sus bytes de capas anteriores.
- Conservar el JAR en una sola copia. Separar dependencias de Spring Boot en capas puede mejorar caché de reconstrucción; no demuestra por sí solo menor tamaño total.
- El Docker inspect histórico del 1/11 registró 166.978.828 bytes; el nuevo registra 150.573.049 (9,83 % menor en esa métrica). Cambiaron base y proceso de construcción: no atribuir toda la diferencia únicamente al multi-stage ni comparar tamaños comprimidos con los de Dive.

## Vulnerabilidades conocidas: Trivy

Trivy **0.76.1**, escáner `vuln`, sin filtrar severidades ni ocultar hallazgos sin corrección. Análisis finalizado: `2026-11-10T23:20:08.983887988Z`. Código 0 de ejecución; no se configuró gate por severidad. Versiones y fechas de ambas bases en [trivy-version.txt](l4-02/trivy-version.txt).

| Severidad | Hallazgos paquete/vulnerabilidad |
|---|---:|
| CRITICAL | 4 |
| HIGH | 7 |
| MEDIUM | 25 |
| LOW | 16 |
| UNKNOWN | 0 |
| Total | 52 |

Son **41 identificadores distintos**; una misma CVE puede afectar varios paquetes. No confundir cantidad de filas con CVE únicas.

| Objetivo | Tipo | CRITICAL | HIGH | MEDIUM | LOW | Total |
|---|---|---:|---:|---:|---:|---:|
| /input/pedidos-api-l4-01.tar (ubuntu 22.04) | ubuntu | 0 | 2 | 23 | 16 | 41 |
| Java | jar | 4 | 5 | 2 | 0 | 11 |

### Hallazgos prioritarios y tratamiento

Estado: **abiertos y documentados; no corregidos ni declarados falsos positivos**. Las versiones corregidas son las informadas por la base utilizada, no una validación de compatibilidad.

| ID | Paquete | Instalada | Severidad | Corregida según Trivy | Descripción |
|---|---|---|---|---|---|
| [CVE-2026-109518](https://avd.aquasec.com/nvd/cve-2026-109518) | apt | 2.4.14 | HIGH | 2.4.15ubuntu0.1 | apt: apt: Remote code execution via hard link reuse during package download retries |
| [CVE-2026-109518](https://avd.aquasec.com/nvd/cve-2026-109518) | libapt-pkg6.0 | 2.4.14 | HIGH | 2.4.15ubuntu0.1 | apt: apt: Remote code execution via hard link reuse during package download retries |
| [CVE-2026-65182](https://avd.aquasec.com/nvd/cve-2026-65182) | org.apache.tomcat.embed:tomcat-embed-core | 11.0.24 | CRITICAL | 11.0.25, 10.1.58, 9.0.121 | tomcat: Apache Tomcat: Security constraint bypass due to improper access control |
| [CVE-2026-65637](https://avd.aquasec.com/nvd/cve-2026-65637) | org.apache.tomcat.embed:tomcat-embed-core | 11.0.24 | CRITICAL | 11.0.25, 10.1.59, 9.0.121 | tomcat: Apache Tomcat: Improper Input Validation allows HTTP/2 no-authority bypass of strict SNI validation |
| [CVE-2026-65905](https://avd.aquasec.com/nvd/cve-2026-65905) | org.apache.tomcat.embed:tomcat-embed-core | 11.0.24 | CRITICAL | 11.0.25, 10.1.58, 9.0.121 | tomcat: Apache Tomcat: Authentication bypass via limited replay attack in DIGEST authenticator |
| [CVE-2026-68525](https://avd.aquasec.com/nvd/cve-2026-68525) | org.apache.tomcat.embed:tomcat-embed-core | 11.0.24 | CRITICAL | 11.0.25, 10.1.58, 9.0.121 | tomcat: Apache Tomcat: Unauthorized resource access via FORM authentication bypass |
| [CVE-2026-89407](https://avd.aquasec.com/nvd/cve-2026-89407) | tools.jackson.core:jackson-core | 3.1.5 | HIGH | 3.1.7, 3.2.2 | com.fasterxml.jackson/jackson-core: tools.jackson.core/jackson-core: Jackson-core: Denial of Service via regular expression backtracking |
| [CVE-2026-89425](https://avd.aquasec.com/nvd/cve-2026-89425) | tools.jackson.core:jackson-core | 3.1.5 | HIGH | 3.1.7, 3.2.3 | com.fasterxml.jackson.core/jackson-core: Jackson-core: Denial of Service via unbounded StringBuilder growth during malformed token processing |
| [CVE-2026-68497](https://avd.aquasec.com/nvd/cve-2026-68497) | tools.jackson.core:jackson-databind | 3.1.5 | HIGH | 3.2.2, 3.1.6 | com.fasterxml.jackson.core/jackson-databind: tools.jackson.core/jackson-databind: jackson-databind: CPU Denial of Service via unbounded numeric parsing |
| [CVE-2026-91776](https://avd.aquasec.com/nvd/cve-2026-91776) | tools.jackson.core:jackson-databind | 3.1.5 | HIGH | 3.1.7, 3.2.3 | jackson-databind: com.fasterxml.jackson/jackson-core: jackson-databind: Denial of Service via unbounded cache growth in TypeDeserializerBase |
| [CVE-2026-91777](https://avd.aquasec.com/nvd/cve-2026-91777) | tools.jackson.core:jackson-databind | 3.1.5 | HIGH | 3.1.7, 3.2.3 | com.fasterxml.jackson.core/jackson-databind: tools.jackson.core:jackson-databind: Jackson-databind: Denial of Service via quadratic forward-reference completion |

Tratamiento propuesto: priorizar los CRITICAL y después HIGH. Para dependencias Java, revisar una versión compatible de Spring Boot/BOM que incorpore correcciones de Tomcat/Jackson y demás componentes señalados; si hace falta una excepción de versión, verificar alineación del conjunto, no solo un JAR. Compilar, ejecutar pruebas de API/JSON/persistencia, reconstruir con etiqueta nueva y repetir el análisis conservando este diagnóstico. Para paquetes Ubuntu, revisar base Temurin actualizada o correcciones del proveedor; cambiar un digest requiere reconstruir y probar. Para MEDIUM/LOW sin versión corregida, registrar seguimiento del proveedor; no convertir la ausencia de parche en ausencia de riesgo.

Objetivos concretos según este diagnóstico: Tomcat **11.0.25** dentro de su línea 11 para los cuatro críticos; Jackson core/databind **3.1.7** dentro de la línea 3.1 para los cinco HIGH; apt/libapt-pkg6.0 **2.4.15ubuntu0.1** para los dos HIGH de Ubuntu. Son candidatos para revisión y pruebas, no actualizaciones ya aplicadas. Las versiones 9/10 de Tomcat listadas por Trivy son ramas alternativas, no una propuesta de bajar de versión. Las alertas Tomcat refieren restricciones de acceso, SNI/HTTP2 y autenticadores DIGEST/FORM; las Jackson, agotamiento de CPU/memoria; apt, reintentos de descarga de paquetes. Comprobar condiciones y configuración real antes de justificar aplicabilidad. No se documentó un falso positivo para ninguna de ellas.

No se realizaron pruebas de explotación ni análisis de alcanzabilidad. Los títulos y versiones coincidentes detectados por Trivy no acreditan que se cumplan las condiciones de cada ataque. Usuario no root, límites de recursos y consola H2 deshabilitada aportan defensa, pero no corrigen bibliotecas vulnerables. Snyk sobre Maven corresponde a L4-06 y sigue pendiente; este análisis no lo sustituye. El gate Jenkins por críticos sigue pendiente L4-09.

## Evidencias y límites

- [Dive JSON](l4-02/dive.json), [evaluación CI](l4-02/dive-ci.txt), [Trivy JSON](l4-02/trivyreport.json), [Trivy tabla](l4-02/trivyreport.txt), [resumen estructurado](l4-02/resumen.json), [comandos reproducibles](l4-02/COMANDOS.md).
- Identificación, historial, TAR, SHA256, versión/checksum Dive, digest Trivy, manifiestos OCI y comprobación de preservación: `../../handoffs/evidencias_l4_02_2026-11-10/` desde la ubicación de este reporte (fuera del repositorio). Trece reportes históricos comprobados sin diferencias.
- Únicamente la API `pedidos-api:l4-01`; no se analizaron las imágenes Grafana/Prometheus/Jenkins. No hubo despliegue, publicación, commit ni modificación de informes E3.
- Diagnósticos del 1/11 preservados; las nuevas bases y la nueva imagen impiden atribuir diferencias de hallazgos exclusivamente a un cambio del Dockerfile.

Fuentes de método: [Dive oficial](https://github.com/wagoodman/dive), [release utilizado](https://github.com/wagoodman/dive/releases/tag/v0.13.1), [Trivy: container image/TAR](https://trivy.dev/docs/latest/target/container_image/). Consultadas el 10/11/2026. Los resultados y propuestas anteriores se basan en las ejecuciones locales enlazadas.
