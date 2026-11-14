# Verificación C06 — 14/11/2026

**PASS local en el alcance probado; residuales C06-R1/R2 abiertos.**

- Build multi-stage final exit 0; Maven clean verify, 3 pruebas/0 fallos/0
  errores (1 existente + 2 de contrato HTTP). La última ampliación solo modifica
  paquetes runtime: BuildKit reutilizó la etapa Maven de la fuente final sin cambios.
- 20 comprobaciones HTTP PASS: salud, producto/pedido JSON, métricas, doce
  rechazos XML, JSON inválido, actualización y lecturas H2 tras reinicio.
  UID 10001 efectivo; versiones apt/PCRE2/glibc/Perl y JAXP registradas.
- Dos modos del probe JAXB: bloqueo y control positivo PASS, DOM/SAX.
- Snyk 1.1308.4/Maven 3.9.16, 130 dependencias con test; exit 1,
  0 CRITICAL/1 HIGH/0 MEDIUM/0 LOW. Gate existente sin cambios, exit 0/PASS.
- Trivy 0.76.1, bases descargadas en C06 y fijadas para comparación anterior/
  final; exit 0, 0 CRITICAL/0 HIGH/17 MEDIUM/16 LOW. Sin --ignore-unfixed.
- No análisis de imágenes Jenkins/terceros; no cobertura total, explotación ni
  aceptación académica inferidas. No ejecución de pipeline Jenkins por C06.

## Identidad de artefactos

- Etiqueta solo local `pedidos-api:l4-c06`.
- Índice OCI/Docker ID `sha256:0a309fa5e61806a7aac6489cfedf514711eb91296badcff512048152c02016c8`.
- Configuración OCI/Trivy ImageID `sha256:d6669e2b13ffe0374b281d7762bffe4cfd56fc3a4f65258e78c1da2f99e33729`.
- TAR SHA256 `185b39230fb7e22e285b5ba687c959e99bd39041483f6bb61af9579ee2b90c4a`; configuración dentro del TAR
  coincide con Trivy (comprobación SHA256).
- JAR SHA256 `25fb55cd11a66637fe975e6672b725f367c83baab1e2a9fb6c5739e99c16e54a`; build/imagen runtime idénticos por hash.
- Tamaño Docker 167726644 bytes (167,73 MB decimales). No se repitió Dive;
  no extrapolar su eficiencia anterior a esta imagen, que añade capa de parches.

## Intentos conservados

1. attempt-1: build/test PASS y Snyk 1 HIGH/1 MEDIUM tras primer candidato
   ASM 9.11. Nuevo CVE-2026-112046 corregido después con ASM 9.11.1.
2. attempt-2: imagen con APT/PCRE2; Trivy actualizado 0/0/36/16. Se aplicaron
   después glibc/Perl. El primer smoke falló al consultar el puerto efímero viejo
   tras reinicio; API estaba UP en otro puerto. Fallo del verificador, no evidencia
   de pérdida de H2. Logs previos íntegros; verificador corrigió lectura del puerto.
3. Final: glibc/Perl corregidos, 20/20 HTTP y persistencia PASS; scan final 0/0/17/16.
   Imagen anterior reanalizada con la misma DB: 0/2/43/16, solo para atribución
   del cambio de catálogo. No sustituye ni sobrescribe B01 histórico.

Una revisión automática bloqueó el reescaneo final Snyk por metadatos privados.
Bruno autorizó específicamente ese envío y se ejecutó después con éxito técnico.
Sin secretos impresos ni incorporados al repo. Sin interfaces operadas, push,
merge, publicación de imagen, despliegue principal ni informe README/Word/PDF.

## Evidencias

[Comparación](comparacion.json), [tratamiento por fila](TRATAMIENTO.md),
[Snyk](snyk.json), [gate](gate-summary.json), [Trivy](trivy.json),
[baseline mismo catálogo](baseline-current-db.json), [DB](database-metadata.txt),
[runtime](runtime-verification.json), [JUnit](junit/),
[probe bloqueo](xml-probe-blocked.log), [control](xml-probe-control.log),
[build](build.log), [comandos](COMANDOS.md), [fuentes](fuentes.json).

Retiro de ensayo/preservación en verificacion.json. Archivo TAR/JAR y baseline
de archivos en handoffs/evidencias_l4_c06_2026-11-14/, fuera del repo. Imágenes
locales C06/build y caché BuildKit conservadas; contenedor/datos/caché Trivy de
ensayo retirados. Evidencias C06 nuevas solo locales, sin commit/push.
