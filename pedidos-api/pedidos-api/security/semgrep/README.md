# Semgrep Java — L4-05

10/11/2026, Uruguay. Dos reglas oficiales conservadas sin modificar desde
https://github.com/semgrep/semgrep-rules/tree/a5ad1714f00c9f7fde980cab0ea1d6dc6d414fd2

| ID | Archivo original | Riesgo | Severidad de la regla |
|---|---|---|---|
| command-injection-formatted-runtime-call | java/lang/security/audit/command-injection-formatted-runtime-call.yaml | CWE-78: cadenas concatenadas/formateadas en Runtime y otras variantes cubiertas por la regla | ERROR |
| jdbc-sqli | java/lang/security/audit/sqli/jdbc-sqli.yaml | CWE-89: SQL dinámico en llamadas JDBC Statement | WARNING |

Se conserva LICENSE del repositorio de reglas (Semgrep Rules License v1.0).
Estos dos controles no cubren todas las formas de inyección ni toda la seguridad Java.
Las reglas son de auditoría y requieren revisión contextual si producen alertas.
La API usa Spring Data JPA; no se detectaron patrones de estas reglas en ocho archivos
Java de producción. No se añadieron ejemplos vulnerables a la aplicación.

## Reproducir desde PowerShell

Desde la raíz del repositorio, crear el directorio de salida y resolver ambas rutas
absolutas. Se requiere Docker en ejecución y descargar la imagen fijada si falta.

```powershell
$appPath = (Resolve-Path 'pedidos-api/pedidos-api').Path
$reportPath = (New-Item -ItemType Directory -Force 'reports/l4-05').FullName
docker pull semgrep/semgrep@sha256:cc1b68266f267878b39739373ea9985b9a78e5d64497dd875c8de100b22695ed
docker run --rm --network none --mount "type=bind,source=$appPath,target=/src,readonly" --mount "type=bind,source=$reportPath,target=/out" -w /src -e SEMGREP_SEND_METRICS=off -e SEMGREP_ENABLE_VERSION_CHECK=0 semgrep/semgrep@sha256:cc1b68266f267878b39739373ea9985b9a78e5d64497dd875c8de100b22695ed semgrep scan --config security/semgrep --metrics=off --disable-version-check --strict --error --no-rewrite-rule-ids --json-output /out/semgrep.json --text --output /out/semgrep.txt --verbose src 2>&1 | Tee-Object -FilePath "$reportPath/scan-log.txt"
$scanExitCode = $LASTEXITCODE
```

Conservar y propagar `$scanExitCode` en Jenkins: `--error` devuelve fallo si hay
hallazgos; `--strict` evita aceptar errores de configuración como análisis correcto.
La política de bloqueo por críticos del pipeline se define en L4-09; las categorías
ERROR/WARNING de estas reglas no son severidades de CVE.
Semgrep 1.184.0, motor OSS; red deshabilitada durante el análisis, métricas off.
El resultado actual excluye `src/test/java` por semgrepignore predeterminado.
No analiza Maven, dependencias, Docker, YAML ni Helm. El reporte de entrega es
`reports/semgrep-report.txt` desde la raíz del repo; JSON y salida sin hallazgos
(vacía) están en `reports/l4-05/`. El log contiene el resumen real.

Documentación: https://semgrep.dev/docs/running-rules
