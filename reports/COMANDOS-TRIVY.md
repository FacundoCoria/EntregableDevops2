# Cómo se ejecutó Trivy

Fecha: 1 de noviembre de 2026. Terminal: PowerShell en Windows, con Docker Desktop y su motor Linux funcionando.

## Compilación de la aplicación

```powershell
cd 'C:\Users\Bruno\PARA System\1- Projects\Entregable 3 - Devops\EntregableDevops2\pedidos-api\pedidos-api'
.\mvnw.cmd package
```

Este paso genera `target/pedidos-api-0.0.1-SNAPSHOT.jar`, requerido por el Dockerfile. Se ejecutó la prueba existente: una prueba, cero fallos y cero errores. Su resultado está en `prueba-maven.txt`.

## Construcción y descarga del analizador

Desde la raíz del repositorio:

```powershell
cd 'C:\Users\Bruno\PARA System\1- Projects\Entregable 3 - Devops\EntregableDevops2'
New-Item -ItemType Directory -Path reports -Force | Out-Null
docker build --pull --progress plain -t pedidos-api:trivy-20261101 ./pedidos-api/pedidos-api
docker pull aquasec/trivy:0.76.1
docker image inspect pedidos-api:trivy-20261101
docker image inspect aquasec/trivy:0.76.1
```

`docker-build.txt` conserva el registro de la construcción. Los archivos `imagen-analizada.json` e `imagen-trivy.json` identifican las imágenes utilizadas. `ejecucion.json` registra el commit y el SHA256 del JAR.

## Análisis de la imagen

Se exporta una copia de la imagen y se entrega a Trivy en modo de lectura. No se necesita iniciar la API ni publicar puertos para este análisis.

```powershell
docker save --output pedidos-api/pedidos-api/target/pedidos-api-trivy.tar pedidos-api:trivy-20261101
$trivyInput = (Resolve-Path pedidos-api/pedidos-api/target).Path
$trivyReports = (Resolve-Path reports).Path
docker run --rm --mount "type=bind,source=$trivyInput,target=/input,readonly" --mount "type=bind,source=$trivyReports,target=/reports" --mount type=volume,source=entregable3-trivy-cache,target=/root/.cache/trivy aquasec/trivy:0.76.1 image --input /input/pedidos-api-trivy.tar --scanners vuln --format json --output /reports/trivyreport.json --timeout 15m
if ($LASTEXITCODE -ne 0) { throw 'El análisis de Trivy no se completó.' }
docker run --rm --mount "type=bind,source=$trivyReports,target=/reports" aquasec/trivy:0.76.1 convert --scanners vuln --format table --output /reports/trivyreport.txt /reports/trivyreport.json
if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar el reporte de texto.' }
```

El reporte de texto se obtiene del mismo JSON, sin repetir el análisis ni cambiar la base entre formatos. Las rutas `/reports/...` del contenedor corresponden a la carpeta `reports` en la raíz del repositorio.

Se analizan vulnerabilidades conocidas de los paquetes del sistema y las dependencias incluidas en la imagen. No se aplica un filtro de gravedad ni se omiten vulnerabilidades sin solución. Este control no sustituye las otras herramientas de la entrega ni demuestra por sí solo que una vulnerabilidad sea explotable en esta API. El resultado depende de la imagen exacta y de la base de vulnerabilidades disponible al ejecutar Trivy; una ejecución futura puede producir resultados diferentes.

La copia de la imagen queda en `target`, junto a los demás archivos de compilación, y no forma parte de los reportes para GitHub.

Referencia: [documentación oficial de instalación de Trivy](https://trivy.dev/docs/latest/getting-started/installation/).
