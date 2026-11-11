# Reproducción B01 — imagen publicada

11/11/2026. Desde la carpeta general padre del repositorio. Para repetir, elegir
otro destino de evidencias y reportes: no sobrescribir esta ejecución. Docker
activo; Dive Windows 0.13.1 instalado/verificado en L4-02.

```powershell
$l4Image='brunovitola/pedidos-api-l4@sha256:48b65d95763c2a1eb6727f9b22b78fc27509f79b62a7b87903cea87a4aee41d9'
docker pull $l4Image
docker image inspect $l4Image
docker history --no-trunc $l4Image
docker save --output handoffs/evidencias_l4_11b_2026-11-11/pedidos-api-publicada.tar $l4Image
./.tools/dive/dive.exe --source docker-archive handoffs/evidencias_l4_11b_2026-11-11/pedidos-api-publicada.tar --json EntregableDevops2/reports/l4-11b/dive.json --ci
$LASTEXITCODE
./.tools/dive/dive.exe --source docker-archive handoffs/evidencias_l4_11b_2026-11-11/pedidos-api-publicada.tar --ci
$LASTEXITCODE
$l4Input=(Resolve-Path handoffs/evidencias_l4_11b_2026-11-11).Path
$l4Reports=(Resolve-Path EntregableDevops2/reports/l4-11b).Path
docker run --rm --mount "type=bind,source=$l4Input,target=/input,readonly" --mount "type=bind,source=$l4Reports,target=/reports" --mount type=volume,source=entregable3-trivy-cache,target=/root/.cache/trivy aquasec/trivy:0.76.1 image --input /input/pedidos-api-publicada.tar --scanners vuln --format json --output /reports/trivyreport.json --timeout 15m
$LASTEXITCODE
docker run --rm --mount "type=bind,source=$l4Reports,target=/reports" aquasec/trivy:0.76.1 convert --scanners vuln --format table --output /reports/trivyreport.txt /reports/trivyreport.json
$LASTEXITCODE
docker run --rm --mount type=volume,source=entregable3-trivy-cache,target=/root/.cache/trivy aquasec/trivy:0.76.1 --version
```

Logs/códigos de salida guardados por separado. No se filtraron severidades ni se
usó ignore-unfixed. Trivy leyó el mismo TAR de Dive, sin socket Docker. Bases
vigentes reutilizadas de caché: fechas en trivy-version.txt. Una repetición futura
con otras bases puede cambiar los resultados. Convert no repite el análisis.

Verificación local: `.tools/l4-11b-image.py` comprueba hashes/tamaños OCI,
configuración, DiffIDs Docker/Trivy/Dive y códigos de salida; genera comparación
por paquete/ID. No construye, publica ni despliega. La identidad del scanner está
en imagen-trivy.json fuera del repo; versión/checksum Dive se conservan en L4-02.
