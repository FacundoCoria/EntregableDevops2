# Jenkins dedicado desde cero — L4-C01

Recorrido general desde herramientas/fuente hasta servicios y uso de la API:
[instalación portable C02](../../docs/INSTALACION-L4.md). Allí se distingue el
commit publicado de los cambios C01/C02 todavía locales.

Esta instalación es independiente del contenedor `jenkins` del curso. Requiere
Docker Engine Linux/Docker Desktop con Compose v2, red hacia Docker Hub,
updates.jenkins.io, Maven Central, PyPI, Snyk, Helm, Kubernetes y GitHub;
Linux amd64. Las imágenes están fijadas por digest de **amd64**, no sirven para
ARM sin resolver otros digests. Reservar aproximadamente 4 GiB de RAM libres y
8 GiB de disco para construcción/datos; el consumo depende de los builds.
En Windows usar PowerShell 7; en Linux usar Bash/sh y Python 3.

## Crear

Desde la raíz del repositorio, PowerShell 7:

```powershell
./ci/jenkins/start.ps1
```

Linux:

```sh
sh ci/jenkins/start.sh
```

Los scripts construyen las imágenes y ejecutan únicamente el proyecto Compose
`l4-c01`. No arrancan Minikube, no cambian SCM del curso y no ejecutan trabajos.
Esperar el mensaje `Jenkins is fully up and running` en los logs del controlador.
Abrir [Jenkins dedicado](http://localhost:18080), usuario `bruno`, clave generada
en `ci/jenkins/.local/admin-password.txt`. Abrir ese archivo localmente para
copiar la clave; no pegarla en chats, capturas o reportes. `.local/` está excluido
de Git y del contexto Docker. En Linux se crea con permisos 600; en Windows
proteger la carpeta con la cuenta local de Bruno. El archivo solo inicializa
la cuenta; al conservar el volumen una contraseña cambiada en Jenkins sigue vigente.

Archivos entregados: `images.env` fija Jenkins LTS 2.580.2 y Docker 29.7.2;
`plugins.txt` fija el cierre completo de plugins, `plugins.lock.json` conserva
metadatos oficiales y `plugins.sha256` permite comprobar cada descarga durante
la construcción. No instalar/actualizar plugins manualmente: el inicio comprueba
las versiones y detiene la configuración del laboratorio si encuentra diferencias.
Revisar los logs ante ese error; no equivale a una migración automática del volumen.

## Qué se configura

`init.groovy` crea la cuenta local, elimina acceso anónimo, conserva CSRF,
establece cero ejecutores en el controlador y un agente con un ejecutor.
Repetir el inicio conserva cuenta, trabajos, parámetros e historial existentes;
los cambios posteriores del archivo no sobrescriben trabajos ya creados.
El agente usa WebSocket; no hay puerto de agentes publicado. El secreto del
agente se genera desde Jenkins y se comparte mediante un volumen dedicado,
legible por UID 1000; nunca se imprime ni se guarda en Git.

| Servicio | Identidad y acceso | Datos persistentes |
|---|---|---|
| controller | UID/GID 1000, cero builds, sin socket ni certificados Docker, HTTP solo 127.0.0.1:18080 | `l4-c01_controller-home` |
| agent | UID/GID 1000, sin capacidades ni escalada, único ejecutor, cliente Docker con TLS | `l4-c01_agent-home` |
| docker | Docker-in-Docker privilegiado, root, sin puertos publicados ni socket del host | `l4-c01_docker-data`, certificados cliente |

Las redes `l4-c01_control` y `l4-c01_builds` separan controlador y motor Docker;
solo el agente está en ambas. El agente controla **todo el motor dedicado**,
no solo una imagen. DinD requiere `privileged: true`: es una excepción explícita
y comparte kernel con Docker Desktop. No es una frontera de seguridad para código
hostil ni una solución multiusuario de producción. Ejecutar solo código confiable.
El controlador y agente Jenkins sí ejecutan como no root. No se monta
`/var/run/docker.sock`, el home del curso ni directorios personales del equipo.
HTTP y el control administrativo están pensados para este laboratorio local.

El agente incluye Java de la base versionada, Python/venv, curl, Git y CA del
repositorio Debian; registra sus versiones efectivas. Maven 3.9.16, Snyk 1.1308.4,
Helm 4.3.1, kubectl 1.37.0 y Semgrep 1.184.0 se instalan con el bootstrap entregado.
Cada reutilización comprueba las cinco versiones exactas y rechaza diferencias.
Los paquetes apt y dependencias transitivas Python pueden variar en reconstrucciones
futuras: sus inventarios efectivos se registran; este alcance no afirma reproducibilidad
bit a bit. Los binarios Maven/Helm/kubectl verifican checksums de sus sitios oficiales;
Snyk usa el SHA256 ya fijado en bootstrap.

## Primera prueba en pantalla

1. Entrar a **L4-C01-preflight → Build Now**.
2. Esperar `SUCCESS` y revisar los artefactos `evidence/`.
3. Comprobar UID 1000, herramientas fijadas, commit remoto
   `50a0eb53e7a1152fbe0e4f26252fac2380403fc3`, Docker con TLS y build local
   `l4-c01-smoke:local`. No hace push, análisis de seguridad ni despliegue.

`L4-integral` ya está declarado como **deshabilitado**, con Pipeline from SCM,
el Jenkinsfile publicado y SOURCE_URL/SOURCE_REF/IMAGE_REPOSITORY explícitos.
Apunta al commit publicado anterior para que C01 no requiera publicar cambios.
El Jenkinsfile de esa fuente todavía contiene defaults históricos B05:
antes de C07 revisar los valores explícitos del formulario y coordinar C08.
El job existente del curso conserva su configuración. No habilitar ni ejecutar
el integral por la sola preparación de C01: publica una imagen y despliega.

## Secretos y Kubernetes para la etapa integral

Bruno realiza las altas/accesos a cuentas y guarda los secretos en Jenkins:
**Manage Jenkins → Credentials → System → Global credentials → Add Credentials**.

| ID | Tipo | Contenido local |
|---|---|---|
| `l4-snyk-token` | Secret text | Token Snyk de Bruno |
| `l4-dockerhub` | Username with password | Usuario Docker Hub y token con permisos sobre el repositorio elegido |

No copiar el volumen del curso ni exportar sus credenciales. La fuente Git actual
es pública; para una fuente privada configurar una credencial Git específica.
No se necesitan Snyk/Docker Hub para el preflight de C01.

La conexión Kubernetes es **opcional y explícita**. Con Minikube ya iniciado,
contexto/namespace/release revisados y permiso para preparar RBAC, ejecutar en
PowerShell 7:

```powershell
./ci/jenkins/connect-kubernetes.ps1
```

Este script no inicia el clúster ni instala la aplicación. Crea ServiceAccount,
Role y RoleBinding `jenkins-c01` en `laboratorio4`, y un permiso de lectura por
nombre sobre el RBAC de monitoreo existente. Une **solo el agente** a la red
Minikube y guarda un token de 24 h en su volumen, con permisos 600. Prueba lectura
de deployments y rechazo de crear ClusterRoles/leer Secrets en kube-system.
El rol puede leer/escribir Secrets del namespace para Helm: no es permiso de
administrador, pero exige confiar en los jobs de ese agente. Los parámetros
permiten elegir otro contexto/red/API/namespace/release; no usar otro destino
sin revisar el chart y los nombres RBAC. El pipeline integral actual despliega
`l4` en `laboratorio4`; cambiar los parámetros de conexión no cambia ese pipeline.

Renovar antes de C07, y repetir tras recrear el agente: una conexión Docker
adicional no está declarada en Compose. No publicar kubeconfig, tokens ni el
contenido del volumen. La credencial no se renueva por reiniciar Jenkins.

## Reinicio y diagnóstico

Desde `ci/jenkins`:

```sh
docker compose --env-file images.env -f compose.yaml ps
docker compose --env-file images.env -f compose.yaml logs --tail=80 controller agent
docker compose --env-file images.env -f compose.yaml restart
```

Repetir el preflight tras el reinicio: conservar historial de builds y obtener
`PERSISTENCE_REUSED`. `stop` conserva datos y `up -d` los reutiliza. Para parada
comprobada, copia en frío con clave separada, restauración en proyecto vacío y
purga explícita usar la [guía de recuperación C03](RECUPERACION.md).

Verificación técnica desde la raíz del repo: `./ci/jenkins/verify.ps1`. Comprueba
configuración/plugins, UID, ausencia del socket, separación de motores, TLS y
rechazo de versión incorrecta; guarda reportes sin secretos en `reports/l4-c01/`.
No inicia trabajos ni renueva credenciales. Para otra instalación de prueba se
admiten `-ProjectName l4-c01-repro` y `-OutputDirectory` explícitos. Al reproducir
en paralelo usar otro proyecto y `JENKINS_HTTP_PORT=18081` en el entorno; los
volúmenes y redes quedan separados por Compose. `images.env` no contiene secretos.

Si el agente queda offline, revisar logs del controlador (plugins/init) y del
agente (secreto/permisos/red). Si Docker rechaza el acceso, comprobar que DinD
terminó de generar sus certificados y que DOCKER_TLS_VERIFY sea 1; no desactivar
TLS ni montar el socket del equipo como recuperación. Si una herramienta tiene
otra versión, reconstruir una imagen revisada o usar un volumen dedicado nuevo;
el error no autoriza borrar datos existentes. Si 18080 está ocupado, elegir otro
puerto loopback en Compose y registrar el cambio.

Fuentes del diseño: [imagen oficial Jenkins](https://github.com/jenkinsci/docker),
[Docker/TLS en Jenkins](https://www.jenkins.io/doc/book/installing/docker/),
[agentes Jenkins](https://www.jenkins.io/doc/book/using/using-agents/),
[scripts de inicialización](https://www.jenkins.io/doc/book/managing/groovy-hook-scripts/).
