# Laboratorio 4 — instalación y uso en otra máquina

Guía L4-C02, 13/11/2026. Punto de entrada operativo: preparación → fuente →
Jenkins dedicado → Kubernetes → API y paneles → apagado. Los detalles ya probados
se enlazan dentro del repositorio; no hace falta disponer de handoffs ni de la
carpeta administrativa `.tools`. Las acciones de interfaz las realiza el lector.

**Disponibilidad:** la entrega publicada es `trabajo-integrador-4`, commit
`50a0eb53e7a1152fbe0e4f26252fac2380403fc3`. C01 (Jenkins dedicado), esta guía
C02 y recuperación C03 están todavía **solo en la copia local**, sin commit/push. El clon de ese
commit permite el recorrido Kubernetes, pero no contiene `ci/jenkins/` ni esta
guía. Para el recorrido completo recibir una copia del árbol revisado C01/C02/C03
sin secretos, o esperar su publicación autorizada y usar su rama/commit real.
No existe todavía un commit publicado de C01/C02/C03 que se pueda indicar aquí.

## 1. Equipo, herramientas y acceso

| Elemento | Alcance de esta guía |
|---|---|
| Sistema de referencia | Windows x86-64, Docker Desktop con contenedores Linux y backend WSL2; Git Bash para scripts Bash y PowerShell 7 (`pwsh`) para `.ps1`. Es la plataforma probada previamente. |
| Alternativa | Linux x86-64 con Docker Engine y Compose v2; Bash, Python 3 y curl. Jenkins tiene entrada `start.sh`. El recorrido completo en Linux nativo no se ha probado; la conexión Kubernetes entregada requiere también PowerShell 7. |
| Fuera del alcance probado | ARM/macOS, contenedores Windows, otro driver/kernel. Los digests Jenkins son amd64 y Falco exige compatibilidad modern eBPF. |
| Recursos | Kubernetes usa 2 CPU y 2800 MiB en el perfil aislado; Jenkins recomienda aproximadamente 4 GiB libres y 8 GiB de disco. Como presupuesto conjunto reservar al menos 7 GiB de RAM y 30 GiB de disco libres para Docker, más margen del sistema/builds; es una estimación, no una prueba de capacidad mínima. |
| Red | HTTPS hacia GitHub, Docker Hub, updates.jenkins.io, Maven Central, PyPI, downloads.snyk.io, get.helm.sh, dl.k8s.io, repositorios Kyverno/Falco y registros de sus imágenes. Proxy/CA corporativos deben configurarse también dentro de Docker y del agente. No desactivar validación TLS para resolver errores. |
| Accesos | Docker operativo para la cuenta local; kubeconfig administrador del perfil propio para instalación/RBAC. Jenkins recibe una identidad limitada distinta. Git público no pide cuenta; Snyk y Docker Hub solo hacen falta para la etapa integral. |

Instalar Git (incluye Git Bash en Windows), Python 3, PowerShell 7 y Docker
desde sus sitios oficiales: [Git](https://git-scm.com/downloads),
[Python](https://www.python.org/downloads/),
[PowerShell](https://learn.microsoft.com/powershell/scripting/install/installing-powershell),
[Docker Windows/WSL2](https://docs.docker.com/desktop/setup/install/windows-install/)
o [Docker Engine Linux](https://docs.docker.com/engine/install/).
En Windows habilitar virtualización/WSL2 siguiendo los requisitos de Docker,
reiniciar si lo pide el instalador y abrir Docker Desktop. En **Settings →
General**, comprobar el backend WSL2 y el modo de contenedores Linux. WSL2 es
el backend: los comandos de esta ruta se ejecutan en Git Bash/PowerShell de
Windows, sin mezclar kubeconfigs ni binarios de una distribución WSL.

### CLI Kubernetes en PATH, sin carpetas externas del proyecto

Usar **Helm 4.3.1, kubectl 1.37.0 y Minikube 1.39.0** para reproducir las
versiones registradas. No sustituir por `latest` ni Helm 3: los scripts emplean
`--server-side=false --wait=legacy`. Los requisitos e instrucciones oficiales
son [Helm](https://helm.sh/docs/intro/install/),
[kubectl](https://kubernetes.io/docs/tasks/tools/) y
[Minikube](https://minikube.sigs.k8s.io/docs/start/).

En Windows descargar estos archivos y sus checksums:

| Herramienta | Archivo oficial | SHA256 oficial |
|---|---|---|
| Helm | [helm-v4.3.1-windows-amd64.zip](https://get.helm.sh/helm-v4.3.1-windows-amd64.zip) | [sha256sum](https://get.helm.sh/helm-v4.3.1-windows-amd64.zip.sha256sum) |
| kubectl | [kubectl.exe](https://dl.k8s.io/release/v1.37.0/bin/windows/amd64/kubectl.exe) | [sha256](https://dl.k8s.io/release/v1.37.0/bin/windows/amd64/kubectl.exe.sha256) |
| Minikube | [minikube-windows-amd64.exe](https://github.com/kubernetes/minikube/releases/download/v1.39.0/minikube-windows-amd64.exe) | [sha256](https://github.com/kubernetes/minikube/releases/download/v1.39.0/minikube-windows-amd64.exe.sha256) |

En PowerShell, `Get-FileHash -Algorithm SHA256 <archivo-descargado>` permite
comparar el hash con el archivo oficial; reemplazar el marcador por la ruta real.
Si difieren, detenerse. Extraer `windows-amd64/helm.exe` del ZIP. Colocar ese
ejecutable, `kubectl.exe` y Minikube renombrado a `minikube.exe` en una carpeta
propia, por ejemplo `%USERPROFILE%\bin\l4`. En **Editar las variables de entorno
de esta cuenta → Path → Editar → Nuevo**, agregar esa carpeta. Abrir terminales
nuevas para tomar el cambio. No reemplazar herramientas de otros proyectos.

En Linux instalar Bash/Git/Python 3/curl/CA/tar y utilidades SHA256 con el gestor
de la distribución. Descargar y verificar los binarios de las mismas versiones:

- Helm: `https://get.helm.sh/helm-v4.3.1-linux-amd64.tar.gz` y el mismo URL con
  sufijo `.sha256sum`; extraer `linux-amd64/helm`.
- kubectl: `https://dl.k8s.io/release/v1.37.0/bin/linux/amd64/kubectl` y el
  mismo URL con sufijo `.sha256`.
- Minikube: `https://github.com/kubernetes/minikube/releases/download/v1.39.0/minikube-linux-amd64`
  y el mismo URL con sufijo `.sha256`.

Comparar `sha256sum <archivo>` con el hash oficial antes de instalar. Copiar
solo los tres ejecutables a `$HOME/.local/bin`, renombrar Minikube a `minikube`,
darles permiso ejecutable y agregar `export PATH="$HOME/.local/bin:$PATH"` al
archivo de inicio de Bash. No ejecutar el bootstrap Linux de Jenkins sobre
Windows: instala herramientas del agente y no prepara el host.

Desde **Git Bash o Bash**, comprobar antes de crear recursos:

```bash
git --version
bash --version
curl --version
python3 --version
docker info --format '{{.OSType}} {{.Architecture}} {{.ServerVersion}}'
docker compose version
helm version --short
kubectl version --client
minikube version
```

Si en Windows `python3` abre Microsoft Store, comprobar `python --version` y
usar `export L4_PYTHON=python` en **cada terminal Bash**. El resto de esta guía
usa `${L4_PYTHON:-python3}` para admitir ambos nombres. Confirmar Docker Linux
amd64/x86_64 y las tres versiones CLI anteriores. El Docker del host puede
tener otra versión compatible; el motor interno Jenkins queda fijado a 29.7.2.
No hacen falta Java/Maven/Snyk/Semgrep en el host para usar estos scripts.

## 2. Obtener y comprobar la fuente

En una carpeta elegida, desde Bash (los siguientes comandos crean un clon nuevo):

```bash
git clone --branch trabajo-integrador-4 --single-branch https://github.com/FacundoCoria/EntregableDevops2.git
cd EntregableDevops2
git rev-parse HEAD
git status --short
```

El commit publicado registrado es `50a0eb53e7a1152fbe0e4f26252fac2380403fc3`;
una rama puede avanzar. Registrar el HEAD real y revisar diferencias si cambió.
Si se recibe una copia local revisada con C01/C02, trabajar desde su raíz y
conservar la identificación de su base y sus cambios sin commit. Comprobar
`scripts/l4/`, `pedidos-api/pedidos-api/helm-chart/` y, para Jenkins nuevo,
`ci/jenkins/compose.yaml`. Si falta este último, no seguir la sección 3 hasta
recibir C01: no instalar el Jenkins del curso como sustituto. No copiar `.local/`,
kubeconfigs, tokens ni volúmenes de otra persona. Conservar rutas entrecomilladas
si tienen espacios. Todos los comandos siguientes parten de la raíz del repo,
salvo los que indiquen otra ubicación.

## 3. Crear Jenkins dedicado y comprobarlo

Seguir [Jenkins desde cero](../ci/jenkins/README.md). En **PowerShell 7**:

```powershell
./ci/jenkins/start.ps1
```

En Linux: `sh ci/jenkins/start.sh`. Se construyen controlador/agente y se inicia
el motor Docker dedicado, con cinco volúmenes propios del proyecto `l4-c01`.
No se conecta el socket Docker del host ni se reutiliza Jenkins del curso.
Plugins: 67 versiones fijadas y SHA256 verificado; no instalarlos a mano.
Herramientas del agente: Maven 3.9.16, Snyk 1.1308.4, Helm 4.3.1,
kubectl 1.37.0 y Semgrep 1.184.0, comprobadas también al reutilizarse.
Controlador/agente UID 1000; DinD es root/privilegiado, excepción explícita.

Abrir [Jenkins dedicado](http://localhost:18080), entrar como `bruno` usando
la clave de `ci/jenkins/.local/admin-password.txt` de **esta máquina**. Mantener
ese archivo privado; con volumen existente prevalece una contraseña cambiada
en Jenkins. En **L4-C01-preflight → Build Now**, iniciar solo el diagnóstico.
Esperar **SUCCESS**, abrir **Build → Artifacts → evidence/** y comprobar UID
1000, versiones, clon del commit publicado y build Docker local con TLS.
La primera ejecución dice `PERSISTENCE_CREATED`; una posterior con los mismos
datos debe decir `PERSISTENCE_REUSED`. No se ejecutó otra prueba por escribir C02.

El trabajo **L4-integral** se crea **deshabilitado** y apunta al commit publicado
`50a0eb5...`; su Jenkinsfile mantiene defaults B05. No habilitarlo como parte
del diagnóstico. El Jenkins del curso y sus trabajos conservan su configuración.

## 4. Crear los servicios en Kubernetes propio

La ruta de ensayo recomendada es el perfil **minikube-l4-b04**, separado del
principal `minikube`. Docker debe estar iniciado. Consultar primero el plan:

```bash
bash scripts/l4/sandbox.sh
L4_CONFIRM=minikube-l4-b04/laboratorio4/l4 bash scripts/l4/sandbox.sh create
```

`create` instala Kubernetes v1.37.0/containerd (2 CPU, 2800 MiB), luego API/H2,
Prometheus, Grafana, Kyverno y Falco. Resultado esperado **PASS**, tres Pods de
aplicación Ready, tres PVC Bound, salud API UP, Prometheus ready, Grafana database
ok y seguridad disponible. Emplea chart local 0.3.0 e imagen API publicada por
digest de #7; no construye ni publica imagen nueva. Guarda evidencia propia en
`reports/l4-10/` y propiedad del perfil en `reports/l4-11b/b04-profile-owner.json`.
Si ya existe el perfil o el registro, detenerse y revisar el intento previo;
no borrar el registro para forzar otra creación. Detalle y eliminación en
[reproducción B04](../scripts/l4/B04-REPRODUCCION.md).

Si se eligió expresamente un **perfil principal propio**, primero crearlo con
`minikube start -p minikube --driver=docker --container-runtime=containerd --kubernetes-version=v1.37.0 --memory=2800 --cpus=2 --keep-context`
y luego `bash scripts/l4/start.sh --security`. No usar esos comandos para
reconfigurar un perfil compartido. `--jenkins-existing` pertenece al contenedor
heredado del curso; no se usa con Jenkins dedicado C01. `start.sh` instala o
actualiza recursos: no es un comando de consulta.

## 5. API, tráfico, métricas y dashboard

En Bash, para el perfil de ensayo:

```bash
L4_CONTEXT=minikube-l4-b04 bash scripts/l4/access.sh
```

Dejarlo activo; muestra URLs loopback con puertos libres para API, Prometheus y
Grafana. Abrir manualmente la URL Grafana que termina en `/d/l4-observabilidad`.
En un volumen Grafana nuevo el login inicial por defecto es `admin`/`admin`;
cambiar la clave cuando lo solicite. En uno conservado usar su clave vigente.
El dashboard y datasource se aprovisionan desde el chart.

En **otra terminal Bash**, copiar la URL API real mostrada por `access.sh`
(reemplazar el puerto de ejemplo); la API debe seguir accesible:

```bash
API=http://127.0.0.1:12345
curl --fail-with-body -sS "$API/actuator/health"
PRODUCTO=$(curl --fail-with-body -sS "$API/api/productos" \
  -H 'Content-Type: application/json' -d '{"nombre":"ejemplo-c02","precio":42.5}')
printf '%s\n' "$PRODUCTO"
PRODUCTO_ID=$(printf '%s' "$PRODUCTO" | "${L4_PYTHON:-python3}" -c 'import json,sys; print(json.load(sys.stdin)["id"])')
curl --fail-with-body -sS "$API/api/pedidos" -H 'Content-Type: application/json' \
  -d "{\"cliente\":\"Ejemplo C02\",\"producto\":{\"id\":$PRODUCTO_ID},\"estado\":\"Pendiente\",\"minutosEspera\":12}"
curl --fail-with-body -sS "$API/api/productos"
curl --fail-with-body -sS "$API/api/pedidos"
curl --fail-with-body -sS "$API/actuator/prometheus"
```

Esperado según los controladores: salud `{"status":"UP"}`; POST producto y
pedido HTTP 200 con JSON e `id` generado (no asumir ID 1 ni HTTP 201). El pedido
incluye producto, `precioUnitario: 42.5`, estado Pendiente, minutosEspera 12 y
fechaCreacion. Los GET de colecciones devuelven arrays; métricas devuelve texto
Prometheus con `pedidos_creados_total` para `producto="ejemplo-c02"` después del
pedido. Repetir el ejemplo crea más datos. Es una API demostrativa sin una
validación completa de entradas; usar un producto existente y no interpretar un
cuerpo vacío como creación exitosa. Este ejemplo fue cotejado con código y
tráfico previo; no se ejecutó nuevamente en C02.

Para observar tráfico sostenido sin manejar IDs:

```bash
L4_CONTEXT=minikube-l4-b04 L4_ITERATIONS=60 L4_INTERVAL=1 bash scripts/l4/traffic.sh
```

Genera 60 pedidos y 120 lecturas, comprueba incremento del contador y termina
con PASS. No lanzar dos generadores sobre el mismo producto. En Prometheus
abrir **Status → Targets** y comprobar API/kubelet-resource UP. En Grafana
seleccionar **Last 15 minutes**, refresco 5 s; ver RPS, latencia, CPU/memoria y
pedidos por producto/tasa. Las tasas requieren muestras; los contadores se
reinician al reiniciar el proceso y no son el total histórico H2. Ver
[métricas](METRICAS-PEDIDOS.md) y [dashboard exportado](../grafana/dashboard.json).

## 6. Preparación del integral: cuentas, fuente y conexión limitada

Esta sección prepara una ejecución futura **C07**: el integral publica imagen
y despliega. No es necesario ejecutarlo para usar los servicios de la sección 5.

1. En [Snyk](https://app.snyk.io/), acceder a la cuenta y obtener el API token en
   la configuración personal. En Jenkins: **Manage Jenkins → Credentials →
   System → Global credentials → Add Credentials**, tipo **Secret text**, ID
   **l4-snyk-token**. Pegar el token solo en el campo secreto.
2. En [Docker Hub](https://hub.docker.com/), crear/elegir un repositorio propio
   llamado **pedidos-api-l4**. El pipeline actual exige exactamente
   `usuario/pedidos-api-l4` y que el usuario de la credencial coincida con ese
   prefijo. Para este recorrido usar repositorio público: el clúster no tiene
   imagePullSecret configurado. Crear un token con permiso de escritura y en
   Jenkins guardar tipo **Username with password**, ID **l4-dockerhub**,
   usuario Docker Hub y token como password. No usar el repositorio de Bruno
   si la cuenta que publica es otra.
3. En **L4-integral → Configure**, revisar **Pipeline script from SCM → Git**,
   URL, Branch Specifier y Script Path `Jenkinsfile`; y en parámetros revisar
   **SOURCE_URL**, **SOURCE_REF**, **IMAGE_REPOSITORY**. SCM elige el Jenkinsfile;
   SOURCE_REF elige el código que ese archivo clona. Para reproducir una fuente
   final acordada, alinear ambos al commit aprobado y comprobar los valores en
   el formulario antes de ejecutar: el Jenkinsfile B05 puede restaurar defaults
   históricos. C08 coordina la fuente final; esta guía no cambia el job.
4. La fuente actual es pública, sin credencial Git. Para un repo privado,
   **no alcanza** con elegir Credentials en SCM: el Jenkinsfile hace además
   `git clone` por shell sin credenciales vinculadas. Hace falta adaptar ese
   paso con una credencial específica y probarlo con alcance propio; nunca
   incrustar un token en la URL o en parámetros.

Antes de conectar Kubernetes, acordar contexto, red, API, namespace y release.
El pipeline actual fija `l4`/`laboratorio4` y usa el contexto del kubeconfig que
se instala en el agente. En **PowerShell 7**, con el perfil propio ya instalado,
se puede preparar exclusivamente el ensayo B04 mediante:

```powershell
./ci/jenkins/connect-kubernetes.ps1 -Context minikube-l4-b04 -DockerNetwork minikube-l4-b04 -ApiServer https://minikube-l4-b04:8443
```

Para el principal propio `minikube`, los defaults del mismo script son los
documentados en [Jenkins C01](../ci/jenkins/README.md). El script crea RBAC
`jenkins-c01`, une solo el agente a la red elegida y guarda kubeconfig limitado
en su volumen. Puede gestionar Secrets del namespace para Helm, pero no crear
ClusterRoles ni leer Secrets de kube-system; se comprueban esos rechazos.
La conexión dedicada solo tenía sintaxis verificada en C01; no se probó en vivo
en C02. Conectar un destino distinto no cambia nombres/release del Jenkinsfile.

El token se solicita por **24 h**; no se renueva al reiniciar. Antes de cada
ejecución futura repetir el script con el destino revisado: renueva el token y
comprueba acceso y límites. Repetir también al recrear el agente, porque su unión
adicional a la red no está declarada en Compose. No copiar ni imprimir kubeconfig
para comprobar vigencia. Un `Unauthorized` obliga a revisar/renovar la conexión;
no demuestra que los análisis de seguridad hayan fallado por vulnerabilidades.

## 7. Diagnóstico y apagado

| Síntoma | Comprobación/acción |
|---|---|
| Comando ausente/versión distinta | Revisar PATH en esa terminal, Helm 4.3.1/kubectl 1.37.0/Minikube 1.39.0. En Windows `where.exe helm` permite detectar otra copia anterior; verificar Python y L4_PYTHON. |
| Docker no responde o muestra Windows | Iniciar Docker Desktop, confirmar Linux/WSL2 y acceso de la cuenta. No crear un clúster hasta que `docker info` funcione. |
| Jenkins unhealthy/agente offline | Logs de controller/agent según README C01; comprobar plugins fijados, permisos del secreto y red. No desactivar TLS ni montar socket host. |
| Puerto 18080 ocupado | Revisar qué lo ocupa o fijar `JENKINS_HTTP_PORT=18081` antes de iniciar Compose y abrir el nuevo puerto. |
| Pending/OOMKilled | `kubectl --context minikube-l4-b04 -n laboratorio4 get pods,pvc`; `describe pod` y eventos. Revisar memoria/disco/storage. No reducir Grafana a 256 MiB: hubo OOM previo. |
| ImagePullBackOff/descarga fallida | `describe pod`, red/CA/proxy, existencia y acceso del digest. Un repositorio privado requiere preparación adicional; no usar etiquetas distintas sin registrarlo. |
| API inaccesible tras reinicio | Repetir access.sh, copiar las nuevas URLs. Los túneles anteriores no siguen a un Pod reemplazado. |
| Panel vacío | Ver targets UP, intervalo temporal y tráfico; esperar muestras. No esperar historial de contadores después de reiniciar API. |
| Forbidden/Unauthorized en CI | Revisar destino/RBAC o renovar token, respectivamente; no ampliar permisos globales para ocultar el fallo. |
| Perfil/registro B04 existente | Revisar evidencia y propiedad. No quitar el marcador ni ejecutar `create` otra vez a ciegas. |

Para **apagar conservando datos**: esperar trabajos Jenkins terminados, finalizar
tráfico, cerrar `access.sh` con Ctrl+C y detener solo el perfil propio:

```bash
minikube stop -p minikube-l4-b04
```

Después, desde `ci/jenkins`, conservar los cinco volúmenes de C01 con:

```bash
docker compose --env-file images.env -f compose.yaml stop
```

Para recuperar, desde esa carpeta `docker compose --env-file images.env -f
compose.yaml up -d --wait`; desde la raíz arrancar el perfil existente con
`minikube start -p minikube-l4-b04 --keep-context` y volver a abrir túneles. No
usar `sandbox.sh create` para reiniciar. Si se desea reconciliar los componentes,
`L4_CONTEXT=minikube-l4-b04 bash scripts/l4/start.sh --security` instala/actualiza
el chart y conserva datos: revisar antes su alcance. Renovar conexión del agente
cuando corresponda antes del integral.

Para **eliminar el clúster de ensayo y sus datos**, seguir las dos etapas con
confirmación y verificación de propiedad de [B04](../scripts/l4/B04-REPRODUCCION.md).
La [guía de operaciones](../scripts/l4/GUIA.md) explica retirada de aplicación
con conservación o purga de PVC. Backup/restauración y purga verificados de
Jenkins dedicado se detallan en la [guía C03](../ci/jenkins/RECUPERACION.md):
copia en frío, clave separada, destino vacío y purga por propiedad/nombre exactos.
Apagar Docker Desktop al final si ya no tiene otros usos.

## 8. Qué acredita esta guía

C02 verifica documentación, enlaces y correspondencia con archivos/código.
Reutiliza las pruebas anteriores [C01](../reports/l4-c01/VERIFICACION.md),
[B04](../reports/l4-11b/b04-reproduccion.md) y
[L4-10](../reports/l4-10/VERIFICACION.md), sin afirmar otro ciclo ejecutado.
El [índice de evidencias](../reports/ESTADO-EVIDENCIAS-L4.md) conserva resultados
de seguridad y sus límites. Publicar C01/C02/C03 sigue pendiente con alcance propio;
la prueba integral desde la fuente final y Jenkins nuevo corresponde a C07.
