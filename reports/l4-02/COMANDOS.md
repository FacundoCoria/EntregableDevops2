# Reproducción L4-02

Ejecución original: 10/11/2026, Uruguay. Ejecutar desde la carpeta general `Entregable 3 - Devops` (padre del repositorio). Docker debe estar disponible. Dive Windows 0.13.1 se descargó del release oficial y se comprobó su ZIP contra `dive_0.13.1_checksums.txt`; herramienta local en `.tools/dive/dive.exe`, fuera del repositorio.

Los comandos siguientes reproducen el procedimiento. Para una nueva ejecución, elegir otro directorio de resultados y otro TAR; no sobrescribir este diagnóstico. Descargar bases en otra fecha puede modificar los resultados.

```powershell
docker image inspect pedidos-api:l4-01
docker history --no-trunc pedidos-api:l4-01
docker save --output handoffs/evidencias_l4_02_2026-11-10/pedidos-api-l4-01.tar pedidos-api:l4-01

./.tools/dive/dive.exe --source docker-archive handoffs/evidencias_l4_02_2026-11-10/pedidos-api-l4-01.tar --json EntregableDevops2/reports/l4-02/dive.json
./.tools/dive/dive.exe --source docker-archive handoffs/evidencias_l4_02_2026-11-10/pedidos-api-l4-01.tar --ci

$l4Input = (Resolve-Path handoffs/evidencias_l4_02_2026-11-10).Path
$l4Reports = (Resolve-Path EntregableDevops2/reports/l4-02).Path
docker run --rm --mount "type=bind,source=$l4Input,target=/input,readonly" --mount "type=bind,source=$l4Reports,target=/reports" --mount type=volume,source=entregable3-trivy-cache,target=/root/.cache/trivy aquasec/trivy:0.76.1 image --input /input/pedidos-api-l4-01.tar --scanners vuln --format json --output /reports/trivyreport.json --timeout 15m
$LASTEXITCODE
docker run --rm --mount "type=bind,source=$l4Reports,target=/reports" aquasec/trivy:0.76.1 convert --scanners vuln --format table --output /reports/trivyreport.txt /reports/trivyreport.json
docker run --rm --mount type=volume,source=entregable3-trivy-cache,target=/root/.cache/trivy aquasec/trivy:0.76.1 --version
```

En la ejecución original, la exportación JSON de Dive incluyó también `--ci`; esa combinación exporta JSON sin mostrar la evaluación de umbrales. Se ejecutó después `--ci` por separado: su salida y código están en `dive-ci.txt` y `dive-ci-exit.txt`. No se usó interfaz interactiva ni se ignoraron errores de lectura.

Trivy usó el TAR de solo lectura, sin montar el socket Docker. `--scanners vuln` analiza vulnerabilidades conocidas: no evalúa secretos, configuración, explotación ni cumplimiento. No se filtraron severidades ni se usó `--ignore-unfixed`. El código 0 indica ejecución exitosa; no constituye aprobación de seguridad ni bloqueo de CI por críticos.

La versión/digest de Trivy, identificación completa de la imagen, SHA256 del TAR, manifiestos OCI, historial y preservación de los trece reportes anteriores están en `handoffs/evidencias_l4_02_2026-11-10/`, fuera del repositorio. Los reportes nuevos están en `EntregableDevops2/reports/l4-02/`; el resumen requerido está en `EntregableDevops2/reports/image-analysis.md`.

Fuentes oficiales consultadas el 10/11/2026: [Dive y opciones CI/JSON](https://github.com/wagoodman/dive), [release 0.13.1](https://github.com/wagoodman/dive/releases/tag/v0.13.1), [Trivy: imágenes y TAR](https://trivy.dev/docs/latest/target/container_image/).
