# Tratamiento de residuales C06

14/11/2026, Uruguay. C06 completa como corrección local y tratamiento explícito;
**no equivale a eliminar todas las vulnerabilidades**. Bruno eligió corregir y
probar aislado y autorizó expresamente el envío de dependencias/metadatos a Snyk.

## Resultado y comparación

| Análisis | CRITICAL | HIGH | MEDIUM | LOW |
|---|---:|---:|---:|---:|
| Snyk Jenkins #7, 11/11 | 0 | 1 | 8 | 1 |
| Snyk C06, 14/11 | 0 | 1 | 0 | 0 |
| Trivy B01 histórico, 11/11 | 0 | 2 | 23 | 16 |
| Imagen #7 con bases C06, 14/11 | 0 | 2 | 43 | 16 |
| Imagen C06 con las mismas bases | 0 | 0 | 17 | 16 |

No sumar Snyk y Trivy como IDs únicos. Snyk incluye test (130 dependencias);
Trivy analiza Ubuntu (143 paquetes) y Java runtime (83). Java: cero detectados
por Trivy en C06, aunque Snyk mantiene JAXB. No es falso positivo acreditado.
Exit Snyk 1 significa hallazgos; gate existente PASS por cero críticos. Trivy
exit 0 acredita ejecución. No ignores, parches Snyk ni filtrado de severidad.

La comparación controlada de Trivy elimina **28 pares paquete/ID** (dos HIGH y
26 MEDIUM), sin pares nuevos. La base actual añade veinte pares medios al
diagnóstico histórico sobre la misma imagen anterior. No atribuir ese aumento
a los cambios de código. Ver [comparación por pares](comparacion.json),
[baseline actual](baseline-current-db.json), [Trivy final](trivy.json).

## Correcciones aplicadas

- APT/libapt-pkg6.0 2.4.15ubuntu0.1: CVE-2026-109518, dos filas HIGH corregidas.
- PCRE2 10.39-3ubuntu0.2, glibc/libc-bin/locales 2.35-0ubuntu3.18 y Perl
  5.34.0-3ubuntu1.10: parches de Ubuntu; metadatos dpkg conservados. Base/JRE
  Temurin 21.0.13_9 Jammy por digest conservados. Una capa adicional de parches;
  versiones explícitas fallan si dejan de estar disponibles (no fallback silencioso).
- Logback 1.6.5, json-smart 2.6.1, ASM 9.11.1 y Objenesis 3.6. Los nueve IDs
  Snyk medios/bajo anteriores ya no aparecen. Json-smart/ASM/Objenesis son test
  y no están en BOOT-INF/lib; Logback sí es runtime. Versiones verificadas por
  build, Snyk y [lista del JAR](runtime-libraries.json).

No cambiar a snapshots ni compilar una variante privada de JAXB para ocultar
su resultado. Conservar Tomcat 11.0.27/Jackson 3.1.8. Pruebas aprobadas respaldan
este alcance local; no certifican todos los usos futuros de esas bibliotecas.

## JAXB HIGH: mitigado, no parcheado

`SNYK-JAVA-ORGGLASSFISHJAXB-20883142` / CVE-2026-92877, jaxb-core 4.0.9;
ruta Boot data-jpa → Hibernate 7.4.5.Final → jaxb-runtime → jaxb-core. Snyk
mantiene fixedIn vacío. Ficha y upstream consultados el 14/11: hardening en
master; sin versión corregida publicada acreditada. Se conserva por dependencia
Hibernate, sin excluir JAXB a ciegas ni declarar inexplotabilidad.

Revisión de fuentes de aplicación: entidades anotadas, sin carga XML/JAXB
explícita ni mapeos XML localizados en lo revisado; eso no es análisis completo
de alcanzabilidad de Hibernate. Los cuatro POST/PUT de negocio declaran ahora
consumes application/json. Se comprobaron doce rechazos HTTP 415 (tres tipos
XML por cuatro rutas) y XML etiquetado como JSON rechazado con 400. El rechazo
temprano impide esa vía HTTP probada; no demuestra cierre de todas las vías.

El runtime fija `javax.xml.accessExternalDTD`, `accessExternalSchema` y
`accessExternalStylesheet` vacíos. Prueba directa de las fábricas DOM y SAX
de jaxb-core con un archivo ficticio: lectura externa bloqueada y XML normal
admitido. Control con accessExternalDTD=all sí leyó el mismo tipo de fixture.
No se leyeron archivos sensibles ni hubo solicitudes a destinos externos.
Se verificó DTD/entidad de archivo; Schema/Stylesheet están configuradas, sin
prueba individual aquí. Resolver personalizado, flags deshabilitados, cambiar
JAXP/JDK o agregar XML no confiable requieren revisar la mitigación de nuevo.

**C06-R1 pendiente:** antes de C07/entrega, Bruno/compañero revisan este residual;
al publicarse fix compatible, actualizar JAXB/BOM, probar y reescanear. Priorizar
antes si se agrega XML externo, un resolver, importación de ficheros o cambia JRE.
Responsable técnico propuesto: mantenedor del repo; no se envió mensaje externo
ni se supone aceptación académica o de riesgo por un tercero.

## Ubuntu MEDIUM/LOW: seguimiento por fila

Las 33 filas finales (17 MEDIUM, 16 LOW) tienen FixedVersion vacío en este
resultado. Se conserva inventario individual debajo, sin suprimirlo. Decisión:
no remover bibliotecas del sistema a ciegas ni migrar distribución por esta
etapa; seguir actualizaciones del proveedor, antes de C07 y ante nueva base/DB.
Ausencia de versión informada no garantiza ausencia de parche en otras fuentes.
El runtime ejecuta UID 10001; no instala paquetes durante el arranque, y los
ensayos son locales. Son controles parciales, no pruebas de inalcanzabilidad.
**C06-R2 pendiente:** volver a evaluar cada fila si aparece fix, sube severidad,
se expone públicamente o cambia el uso; no ampliar la conclusión a producción.

| Paquete | ID | Nivel | Instalada | Decisión |
|---|---|---|---|---|
| gcc-12-base | CVE-2022-27943 | LOW | 12.3.0-1ubuntu1~22.04.3 | Sin fix informado; seguimiento C06-R2. |
| libgcc-s1 | CVE-2022-27943 | LOW | 12.3.0-1ubuntu1~22.04.3 | Sin fix informado; seguimiento C06-R2. |
| libncurses6 | CVE-2023-50495 | LOW | 6.3-2ubuntu0.3 | Sin fix informado; seguimiento C06-R2. |
| libncursesw6 | CVE-2023-50495 | LOW | 6.3-2ubuntu0.3 | Sin fix informado; seguimiento C06-R2. |
| libpcre2-8-0 | CVE-2022-41409 | LOW | 10.39-3ubuntu0.2 | Sin fix informado; seguimiento C06-R2. |
| libstdc++6 | CVE-2022-27943 | LOW | 12.3.0-1ubuntu1~22.04.3 | Sin fix informado; seguimiento C06-R2. |
| libsystemd0 | CVE-2026-40228 | LOW | 249.11-0ubuntu3.23 | Sin fix informado; seguimiento C06-R2. |
| libtinfo6 | CVE-2023-50495 | LOW | 6.3-2ubuntu0.3 | Sin fix informado; seguimiento C06-R2. |
| libudev1 | CVE-2026-40228 | LOW | 249.11-0ubuntu3.23 | Sin fix informado; seguimiento C06-R2. |
| libzstd1 | CVE-2022-4899 | LOW | 1.4.8+dfsg-3build1 | Sin fix informado; seguimiento C06-R2. |
| login | CVE-2023-29383 | LOW | 1:4.8.1-2ubuntu2.2 | Sin fix informado; seguimiento C06-R2. |
| login | CVE-2024-56433 | LOW | 1:4.8.1-2ubuntu2.2 | Sin fix informado; seguimiento C06-R2. |
| ncurses-base | CVE-2023-50495 | LOW | 6.3-2ubuntu0.3 | Sin fix informado; seguimiento C06-R2. |
| ncurses-bin | CVE-2023-50495 | LOW | 6.3-2ubuntu0.3 | Sin fix informado; seguimiento C06-R2. |
| passwd | CVE-2023-29383 | LOW | 1:4.8.1-2ubuntu2.2 | Sin fix informado; seguimiento C06-R2. |
| passwd | CVE-2024-56433 | LOW | 1:4.8.1-2ubuntu2.2 | Sin fix informado; seguimiento C06-R2. |
| dash | CVE-2026-102473 | MEDIUM | 0.5.11+git20210903+057cd650a4ed-3build1 | Sin fix informado; seguimiento C06-R2. |
| dash | CVE-2026-102474 | MEDIUM | 0.5.11+git20210903+057cd650a4ed-3build1 | Sin fix informado; seguimiento C06-R2. |
| libexpat1 | CVE-2025-66382 | MEDIUM | 2.4.7-1ubuntu0.9 | Sin fix informado; seguimiento C06-R2. |
| libexpat1 | CVE-2026-93990 | MEDIUM | 2.4.7-1ubuntu0.9 | Sin fix informado; seguimiento C06-R2. |
| libgnutls30 | CVE-2026-67693 | MEDIUM | 3.7.3-4ubuntu1.9 | Sin fix informado; seguimiento C06-R2. |
| libgnutls30 | CVE-2026-88647 | MEDIUM | 3.7.3-4ubuntu1.9 | Sin fix informado; seguimiento C06-R2. |
| libgnutls30 | CVE-2026-88648 | MEDIUM | 3.7.3-4ubuntu1.9 | Sin fix informado; seguimiento C06-R2. |
| libgnutls30 | CVE-2026-95184 | MEDIUM | 3.7.3-4ubuntu1.9 | Sin fix informado; seguimiento C06-R2. |
| libgnutls30 | CVE-2026-95210 | MEDIUM | 3.7.3-4ubuntu1.9 | Sin fix informado; seguimiento C06-R2. |
| libsasl2-2 | CVE-2026-107161 | MEDIUM | 2.1.27+dfsg2-3ubuntu1.2 | Sin fix informado; seguimiento C06-R2. |
| libsasl2-modules-db | CVE-2026-107161 | MEDIUM | 2.1.27+dfsg2-3ubuntu1.2 | Sin fix informado; seguimiento C06-R2. |
| libsystemd0 | CVE-2026-121876 | MEDIUM | 249.11-0ubuntu3.23 | Sin fix informado; seguimiento C06-R2. |
| libudev1 | CVE-2026-121876 | MEDIUM | 249.11-0ubuntu3.23 | Sin fix informado; seguimiento C06-R2. |
| perl-base | CVE-2026-48962 | MEDIUM | 5.34.0-3ubuntu1.10 | Sin fix informado; seguimiento C06-R2. |
| tar | CVE-2026-18477 | MEDIUM | 1.34+dfsg-1ubuntu0.1.22.04.6 | Sin fix informado; seguimiento C06-R2. |
| tar | CVE-2026-18508 | MEDIUM | 1.34+dfsg-1ubuntu0.1.22.04.6 | Sin fix informado; seguimiento C06-R2. |
| wget | CVE-2021-31879 | MEDIUM | 1.21.2-2ubuntu1.5 | Sin fix informado; seguimiento C06-R2. |

## Fuentes consultadas

- [APT](https://ubuntu.com/security/CVE-2026-109518).
- [glibc](https://ubuntu.com/security/CVE-2026-18374).
- [Perl](https://ubuntu.com/security/CVE-2026-82560).
- [JAXB](https://security.snyk.io/vuln/SNYK-JAVA-ORGGLASSFISHJAXB-20883142).
- [JAXB upstream](https://github.com/eclipse-ee4j/jaxb-ri/pull/2013).
- [JAXP](https://docs.oracle.com/en/java/javase/21/security/java-api-xml-processing-jaxp-security-guide.html).
- [Logback](https://security.snyk.io/vuln/SNYK-JAVA-CHQOSLOGBACK-20824362).
- [json-smart](https://security.snyk.io/vuln/SNYK-JAVA-NETMINIDEV-21715438).
- [ASM](https://security.snyk.io/vuln/SNYK-JAVA-ORGOW2ASM-21715451).
- [Objenesis](https://security.snyk.io/vuln/SNYK-JAVA-ORGOBJENESIS-21755439).
