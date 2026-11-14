# Reproducción C06

14/11/2026. Usar otra carpeta de salida para no sobrescribir evidencia. Requiere
Docker y las herramientas documentadas en la guía de instalación. No ejecutar
el Jenkinsfile integral para repetir estos controles: publica y despliega.

Desde la raíz del repositorio, en Bash:

```bash
docker build --progress plain -t pedidos-api:c06-recheck pedidos-api/pedidos-api
docker build --target build -t pedidos-api:c06-recheck-build pedidos-api/pedidos-api
docker create --name c06-recheck-build pedidos-api:c06-recheck-build
mkdir -p c06-recheck/junit
docker cp c06-recheck-build:/workspace/target/surefire-reports c06-recheck/junit/
docker rm c06-recheck-build
docker save -o c06-recheck/image.tar pedidos-api:c06-recheck
```

El build ejecuta los tres tests; H2 de test es memoria. Para Snyk, entrar en la
carpeta de aplicación, con sesión autenticada y autorización de enviar el
manifiesto/metadatos a Snyk. CLI/Maven usados: 1.1308.4/3.9.16.

```bash
cd pedidos-api/pedidos-api
snyk test --file=pom.xml --package-manager=maven --dev --json-file-output=../../reports/l4-c06-recheck-snyk.json
scan_exit=$?
python3 ../../ci/gate-snyk.py ../../reports/l4-c06-recheck-snyk.json "$scan_exit"
```

Exit 1 de Snyk con findings es válido; errores son otra condición. El gate
actual conserva la regla cero críticos, sin suprimir HIGH. Las versiones futuras
del catálogo pueden cambiar el resultado. No fijar exit 1 a mano al repetir.

Trivy sin socket Docker ni envío del artefacto a un servicio de análisis:

```bash
docker run --rm -v "$PWD/c06-recheck:/input" -v c06-recheck-trivy:/root/.cache/trivy \
  aquasec/trivy:0.76.1 image --input /input/image.tar --scanners vuln \
  --format json --output /input/trivy.json --timeout 15m
```

Ejecutar desde la raíz del repo para ese último bloque. Para comparar dos
imágenes con el mismo catálogo, analizar ambas con esa caché y
`--skip-db-update --skip-java-db-update` después de descargarla; guardar fechas
y hashes de ambas bases. No atribuir diferencias entre fechas solo al parche.

Para probar manualmente runtime, elegir nombres y puertos libres propios:

```bash
docker volume create c06-recheck-data
docker run -d --name c06-recheck-api -p 127.0.0.1:19086:8080 \
  -v c06-recheck-data:/data pedidos-api:c06-recheck
curl --fail http://127.0.0.1:19086/actuator/health
curl --fail -H 'Content-Type: application/json' \
  -d '{"nombre":"C06","precio":25.5}' http://127.0.0.1:19086/api/productos
docker restart c06-recheck-api
# Esperar salud UP y comprobar que el producto sigue presente.
curl --fail http://127.0.0.1:19086/api/productos
```

Los tests JsonContractTests verifican doce rechazos 415 XML y aceptación JSON;
el ensayo C06 además comprobó pedido, métricas, actualización, 400 y persistencia.
El verificador auxiliar de sesión actualizó el puerto asignado por Docker tras
restart; aquí se propone uno fijo para simplificar repetición manual.

El [probe de JAXB](XmlFactoryProbe.java) se compiló con JDK 21 y el jaxb-core
extraído del JAR ejecutable mediante zipfile de Python. Ejecutarlo con
`java -cp <carpeta-probe>:<jaxb-core.jar> XmlFactoryProbe blocked` dentro de la
imagen de runtime conserva JAVA_TOOL_OPTIONS. El control usa
`JAVA_TOOL_OPTIONS=-Djavax.xml.accessExternalDTD=all` y argumento `allowed`.
Solo hace lecturas de un archivo ficticio creado por el propio probe. No aplicar
el override de control a la API ni a otro entorno. Logs C06 conservan ambos modos.

Al terminar, retirar solo los nombres creados para este ensayo:

```bash
docker rm -f c06-recheck-api
docker volume rm c06-recheck-data c06-recheck-trivy
```

Las imágenes/caché de build se conservan salvo decisión posterior. No usar prune
global. Nada de este procedimiento publica imagen/código ni modifica Minikube.
