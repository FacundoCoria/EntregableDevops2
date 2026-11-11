# B04 — reproducción y limpieza en un perfil descartable

Este ciclo crea un clúster Kubernetes independiente llamado `minikube-l4-b04`.
Instala API/H2, Prometheus, Grafana, Kyverno, sus cuatro políticas y Falco con
los archivos del repositorio. No opera interfaces ni crea Jenkins.

Requiere Docker iniciado, Bash, Python, curl, kubectl, Minikube 1.39.0 y Helm
4.3.1 disponibles; en Windows, consultar el PATH de [GUIA.md](GUIA.md).
Usa Kubernetes v1.37.0, containerd, dos CPUs y 2800 MiB. Necesita capacidad
libre adicional y acceso a los registros de imágenes y repositorios Helm.
No modifica la capacidad del clúster principal ni instala herramientas del host.

Desde la raíz del repositorio:

```bash
bash scripts/l4/sandbox.sh
L4_CONFIRM=minikube-l4-b04/laboratorio4/l4 bash scripts/l4/sandbox.sh create
```

Sin argumento muestra el plan. `create` rechaza un perfil o registro de
propiedad existente antes de arrancar. Guarda la identidad Docker del perfil;
`--keep-context` conserva el contexto activo del usuario. Si la creación falla
antes de registrar esa identidad, conservar el intento y revisar el perfil:
no quitar el registro ni volver a crear a ciegas.

Para acceder o generar tráfico exclusivamente en este perfil:

```bash
L4_CONTEXT=minikube-l4-b04 bash scripts/l4/access.sh
L4_CONTEXT=minikube-l4-b04 L4_ITERATIONS=2 bash scripts/l4/traffic.sh
```

Bruno abre las direcciones que muestra `access.sh`; Ctrl+C cierra los túneles.
El nodo para métricas se configura según el contexto; el principal sigue
usando `minikube`. Los recursos del perfil descartable usan namespace
`laboratorio4` y release `l4`, independientes de los del mismo nombre en el
perfil principal. Las políticas conservan así su selector original.

Limpieza por etapas, con el mismo alcance explícito:

```bash
L4_CONTEXT=minikube-l4-b04 L4_CONFIRM=minikube-l4-b04/laboratorio4/l4 bash scripts/l4/clean.sh --apply --purge-data --security
L4_CONFIRM=minikube-l4-b04/laboratorio4/l4 bash scripts/l4/sandbox.sh delete
```

El primer comando retira aplicación, sus tres PVC, políticas y releases de
seguridad; verifica propiedad de todos los PVC antes de desinstalar. Conserva
namespaces y los recursos que Helm retiene (algunas CRD/ConfigMap y un hook
completado en la prueba); otras CRD del chart se retiran. El segundo elimina
**todo el perfil descartable**, incluidos
CRD, namespaces, volúmenes y datos restantes de ese clúster. Comprueba el ID
del contenedor contra el registro local y rechaza identidades diferentes.
También sirve para retirar un perfil creado cuyo despliegue haya fallado.
No acepta nombres arbitrarios de perfil. Restaura el contexto anterior si era
otro perfil: Minikube puede vaciar esa selección al eliminar un clúster.
Conserva evidencia y copia del registro
de propiedad al eliminarlo; no borra archivos del host ni datos de Jenkins.

`sandbox.sh delete` no pretende ser idempotente: sin perfil/registro devuelve
error. `clean.sh` sí puede repetirse sobre un clúster accesible ya limpio.
El informe de verificación B04 distingue cada comprobación real de las
capacidades implementadas y de las pruebas anteriores L4-10.

## Límites de reproducción

Una instalación nueva de Jenkins con plugins, jobs y credenciales sigue
pendiente de B02/B05. `--jenkins-existing` verifica/reutiliza el contenedor
heredado; no lo reproduce. No se declara una máquina nueva totalmente
aprovisionada ni limpieza de recursos ajenos en `default` del principal.
Las versiones de charts están fijadas; imágenes/reglas transitivas de seguridad
no son todas inmutables. Esta guía operativa no es el informe final.
