# Resultados del análisis de la imagen con Trivy

El 1 de noviembre de 2026 se construyó y analizó la imagen local `pedidos-api:trivy-20261101` con Trivy 0.76.1. Se detectaron 68 hallazgos de vulnerabilidades: 4 CRITICAL, 5 HIGH, 55 MEDIUM y 4 LOW. Los nueve hallazgos HIGH y CRITICAL afectan a dependencias Java incluidas en la aplicación y se documentan individualmente a continuación. Permanecen pendientes de corrección; no se modificaron las dependencias ni se verificó su explotación.

## Evidencia y alcance

- Reporte solicitado por la consigna: `reports/trivyreport.txt`.
- Datos originales del mismo análisis: `reports/trivyreport.json`.
- Comandos y explicación del procedimiento: `reports/COMANDOS-TRIVY.md`.
- Registro de construcción: `reports/docker-build.txt`.
- Identificación de las imágenes: `reports/imagen-analizada.json` y `reports/imagen-trivy.json`.
- Versiones y fechas de las bases: `reports/trivy-version.txt`.
- Registro de ejecución del analizador: `reports/trivy-ejecucion.txt`.
- Commit y huella del JAR: `reports/ejecucion.json`.
- Resultado de la prueba de Maven: `reports/prueba-maven.txt`.

El código corresponde al commit `695072de8a64a0770de2af3346d85cfaae397922`. La imagen se construyó con el Dockerfile existente y la base `eclipse-temurin:21-jre`, actualizada al construir mediante `--pull`. El registro de construcción conserva el digest exacto de esa base. La imagen analizada tiene configuración `sha256:94d3a5152657532d77f59e92d0db85cc5efaa988aeb77fd2ef75a77796c599a5`.

La compilación con `.\mvnw.cmd package` finalizó correctamente y ejecutó una prueba, sin fallos ni errores. El primer intento se detuvo por falta de permiso para descargar una dependencia de pruebas; el segundo completó la compilación. No se omitieron las pruebas.

El análisis terminó a las 16:36 del 1 de noviembre de 2026, hora de Uruguay. La base general de vulnerabilidades estaba actualizada a las 13:02 UTC de ese día y la de Java a las 00:58 UTC. Se analizaron los paquetes del sistema Ubuntu 26.04, las bibliotecas Java y el binario Go `usr/bin/pebble`. No se filtraron las gravedades ni se excluyeron vulnerabilidades sin versión corregida.

## Distribución de los resultados

| Componente | CRITICAL | HIGH | MEDIUM | LOW | Total |
|---|---:|---:|---:|---:|---:|
| Sistema Ubuntu de la imagen base | 0 | 0 | 53 | 4 | 57 |
| Bibliotecas Java de la aplicación | 4 | 5 | 2 | 0 | 11 |
| Binario Go `usr/bin/pebble` | 0 | 0 | 0 | 0 | 0 |
| Total | 4 | 5 | 55 | 4 | 68 |

Los totales cuentan hallazgos por paquete y vulnerabilidad; una misma CVE puede aparecer en varios paquetes. No equivalen necesariamente a 68 CVE distintas.

## Documentación de los hallazgos HIGH y CRITICAL

La gravedad de esta tabla es la informada por Trivy. El impacto resume el aviso asociado; la presencia de una versión afectada no demuestra que todas las condiciones de explotación se cumplan en esta aplicación. Las versiones corregidas se toman del reporte para la misma línea principal de la dependencia; antes de actualizar se debe comprobar su compatibilidad con Spring Boot y el conjunto de bibliotecas.

| Identificador | Gravedad Trivy | Dependencia y versión instalada | Impacto descrito por el aviso | Versión corregida indicada por Trivy en la misma línea |
|---|---|---|---|---|
| [CVE-2026-65182](https://avd.aquasec.com/nvd/cve-2026-65182) | CRITICAL | `org.apache.tomcat.embed:tomcat-embed-core` 11.0.24 | Posible omisión de restricciones de acceso a recursos. | 11.0.25 |
| [CVE-2026-65637](https://avd.aquasec.com/nvd/cve-2026-65637) | CRITICAL | `org.apache.tomcat.embed:tomcat-embed-core` 11.0.24 | Posible omisión de validación estricta de SNI mediante solicitudes HTTP/2 sin autoridad. | 11.0.25 |
| [CVE-2026-65905](https://avd.aquasec.com/nvd/cve-2026-65905) | CRITICAL | `org.apache.tomcat.embed:tomcat-embed-core` 11.0.24 | Posible omisión de autenticación DIGEST mediante repetición limitada de solicitudes. | 11.0.25 |
| [CVE-2026-68525](https://avd.aquasec.com/nvd/cve-2026-68525) | CRITICAL | `org.apache.tomcat.embed:tomcat-embed-core` 11.0.24 | Posible acceso no autorizado mediante omisión de autenticación FORM. | 11.0.25 |
| [CVE-2026-89407](https://avd.aquasec.com/nvd/cve-2026-89407) | HIGH | `tools.jackson.core:jackson-core` 3.1.5 | Posible denegación de servicio por retroceso excesivo en una expresión regular. | 3.1.7 |
| [CVE-2026-89425](https://avd.aquasec.com/nvd/cve-2026-89425) | HIGH | `tools.jackson.core:jackson-core` 3.1.5 | Posible denegación de servicio por crecimiento sin límite de un StringBuilder al procesar tokens malformados. | 3.1.7 |
| [CVE-2026-68497](https://avd.aquasec.com/nvd/cve-2026-68497) | HIGH | `tools.jackson.core:jackson-databind` 3.1.5 | Posible agotamiento de CPU por procesamiento numérico sin límite. | 3.1.6 |
| [CVE-2026-91776](https://avd.aquasec.com/nvd/cve-2026-91776) | HIGH | `tools.jackson.core:jackson-databind` 3.1.5 | Posible denegación de servicio por crecimiento sin límite de una caché de deserialización de tipos. | 3.1.7 |
| [CVE-2026-91777](https://avd.aquasec.com/nvd/cve-2026-91777) | HIGH | `tools.jackson.core:jackson-databind` 3.1.5 | Posible denegación de servicio por procesamiento cuadrático de referencias adelantadas. | 3.1.7 |

## Tratamiento registrado

Se eligió documentar los hallazgos, opción permitida por la consigna. Los nueve permanecen abiertos: no se marcaron como falsos positivos, no se agregaron exclusiones y no se declaró que estuvieran corregidos. La documentación permite conservar el diagnóstico inicial; no constituye una aceptación definitiva del riesgo para producción.

Para corregirlos, se propone evaluar una actualización compatible de Spring Boot y de las versiones que administra, comprobando que incluya Tomcat 11.0.25 o una versión posterior corregida y un conjunto coherente de Jackson que resuelva los cinco avisos HIGH. En la rama 3.1, el reporte señala 3.1.7 para cubrir los avisos HIGH de ambos componentes Jackson. Estas son referencias mínimas del reporte, no una validación de una combinación de versiones: cualquier actualización deberá compilarse, probarse, incluir pruebas de la API y someterse a un nuevo análisis de la imagen.

Los 55 hallazgos MEDIUM y 4 LOW permanecen en el reporte completo para seguimiento. El análisis de la imagen no incluye las pruebas de Semgrep, políticas de Kubernetes ni alertas de Falco exigidas en otras partes del entregable.

La API no necesitó iniciarse para analizar su imagen. Docker Desktop y su motor sí estaban funcionando. No se publicó la imagen en un registro remoto ni se subieron estos archivos a GitHub.
