# L4-C02 — verificación de la guía portable

Fecha: 13/11/2026, Uruguay. Resultado: **PASS documental**.
No se ejecutaron instalación, ejemplos HTTP, tráfico, conexión Kubernetes,
scans, trabajos Jenkins, publicación de imagen ni despliegues nuevos.

Documentos revisados: [instalación portable](../../docs/INSTALACION-L4.md),
[operaciones](../../scripts/l4/GUIA.md),
[reproducción B04](../../scripts/l4/B04-REPRODUCCION.md) y
[Jenkins dedicado](../../ci/jenkins/README.md).

- 25 enlaces locales existentes y contenidos dentro del repositorio.
- 22 bloques Bash/sh con sintaxis válida mediante `bash -n`; no ejecución.
- Dos bloques PowerShell de la guía con sintaxis válida mediante
  `System.Management.Automation.Language.Parser.ParseInput`, sin ejecución.
- Rutas GET/POST y comportamiento del ejemplo cotejados con controladores
  ProductoController/PedidoController; JSON de producto válido.
- Cinco versiones del agente coinciden con bootstrap; tres parámetros e IDs
  de credenciales coinciden con Jenkinsfile. Revisada restricción de imagen
  `usuario/pedidos-api-l4` y clon shell sin credenciales para Git privado.
- Dependencia de `../.tools/` y errata `+y` retiradas de la guía operativa.
- `git diff --exit-code` sin cambios en reportes versionados anteriores,
  aplicación/chart, Jenkinsfile e informe README. Inventario SHA256 de **801**
  archivos de evidencia anteriores, incluyendo C01 local, en el JSON.

Al cerrar se compararon nuevamente los SHA256: **801/801 evidencias intactas**
y cuatro documentos idénticos a los verificados. Doce enlaces locales del cierre
C02 en registros/handoff/reporte también resuelven. La comprobación solo leyó
archivos, sin acceder a servicios ni secretos.

Verificador y detalle: [verificar_documentacion.py](verificar_documentacion.py)
y [verificacion.json](verificacion.json). El primer intento de comprobación
Bash no pudo iniciar por restricción de permisos de MSYS (`NtCreateDirectoryObject`,
0xC0000022); no fue un error de sintaxis ni una prueba exitosa. La repetición
autorizada fuera de esa restricción completó las verificaciones con PASS.

Las páginas oficiales de Docker Windows/WSL2, Helm, Minikube y kubectl se
consultaron para el procedimiento de instalación y se enlazan en la guía.
No se descargaron ni instalaron CLI nuevas durante C02. Los hashes de descarga
deben compararse en la máquina de destino antes de instalar.

Fuente publicada anterior: `trabajo-integrador-4`, commit `50a0eb5...`.
Trabajo local: `lab4/c01-jenkins-reproducible` sobre ese mismo HEAD, cambios
C01 y C02 sin commit/push. El clon publicado todavía no contiene C01/C02.
Los resultados de instalaciones C01/B04 y pipeline #7 son antecedentes
identificados; C02 no acredita un ciclo global nuevo. C03/C07/C09 conservan
recuperación Jenkins, reproducción integral y publicación propias.
