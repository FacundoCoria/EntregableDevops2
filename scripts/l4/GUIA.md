# L4-10 — Inicio, tráfico, acceso y limpieza

**Ampliación B04:** para crear, recuperar y eliminar un clúster descartable
con seguridad y almacenamiento, consultar [B04-REPRODUCCION.md](B04-REPRODUCCION.md).
El contexto adicional admitido es exclusivamente `minikube-l4-b04`.
Las instrucciones del entorno principal de esta guía conservan ese alcance.

Ejecutar desde la raíz de **EntregableDevops2**, en Bash (Linux o Git Bash en
Windows). Los scripts resuelven sus archivos desde su propia ubicación y toleran
rutas con espacios. No abren interfaces. Bruno abre las direcciones que muestra
`access.sh` y opera Jenkins/Grafana cuando corresponda.

## Requisitos

- Docker Engine/Docker Desktop iniciado; Minikube con perfil/contexto `minikube`
  y runtime containerd. Para el entorno existente no recrear el perfil.
- Bash, curl, Python 3, kubectl, Helm **4.3.1** y minikube disponibles en PATH.
  Las opciones `--server-side=false --wait=legacy` corresponden al Helm usado
  en L4-09. No intercambiar por Helm 3 sin adaptar/verificar esas opciones.
- Credenciales de administrador local de Minikube para instalar componentes y
  RBAC. El kubeconfig limitado de Jenkins sirve para CI, no para todo este ciclo.
- Imagen API publicada en L4-09 accesible o imagen indicada en `L4_IMAGE`.
  No hacen falta Maven/Snyk para estos scripts; los controles siguen en Jenkins.
- En Windows: usar `export L4_PYTHON=python` si `python3` apunta al acceso de
  Microsoft Store. Agregar al PATH la carpeta que contiene `helm.exe`. En este
  proyecto se encuentra en `../.tools/helm/windows-amd64`:

```bash
export PATH="$(cd ../.tools/helm/windows-amd64 && pwd):$PATH"
export L4_PYTHON=python
```

El contexto se pasa explícitamente a todos los comandos; se admite `minikube`
+y, exclusivamente para B04, `minikube-l4-b04`. El namespace por defecto es `laboratorio4` y el release `l4`.
Para ensayos se admiten namespaces `laboratorio4-l4test...` y releases `l4-...`.
No se instala un segundo stack de seguridad en los namespaces de ensayo.

## 1. Inicio

```bash
bash scripts/l4/start.sh --jenkins-existing --security
```

`--jenkins-existing` inicia el contenedor **jenkins** ya creado y espera su
respuesta solo después de verificar su imageId contra `ci/jenkins-image.lock.json`.
Una diferencia detiene el script antes de modificar Minikube/Kubernetes o iniciar
Jenkins. Comprobación independiente de lectura: `bash scripts/l4/verify-jenkins.sh`.
El lock identifica la imagen local; no reproduce la capa escribible, plugins ni
credenciales. `lts` sigue siendo una etiqueta móvil y no debe usarse para recrearlo.
Detalle de alcance/excepciones: [B02](../../reports/l4-11b/b02-componentes.md).

El script espera su
respuesta en `http://127.0.0.1:8080/login`. No reemplaza contenedor, volumen,
plugins, trabajos ni credenciales. En una máquina nueva, crear primero Jenkins
según la configuración del curso; el script falla si falta, sin inventar una
instalación equivalente. El Jenkins observado usa `ucu-devops/jenkins:lts`,
volumen `00-setup_jenkins_home` y socket Docker: es un prerrequisito heredado,
no un aprovisionamiento desde cero acreditado por L4-10. Sin esa opción solo
inicia el stack Kubernetes.

`--security` instala o actualiza Kyverno chart 3.10.0-rc.4 y Falco chart 9.2.2
mediante Helm y aplica las cuatro políticas CEL. Usa los valores ya comprobados
en `pedidos-api/pedidos-api/security/`. Espera CRD establecida, políticas Ready
y DaemonSet Falco disponible. Kyverno es un controlador de admisión; Falco un
DaemonSet eBPF. Prometheus/Grafana se despliegan directamente con el chart de la
aplicación: **no se necesita Prometheus Operator** ni añadir un operador sin uso.
Kyverno es una versión candidata, para este laboratorio; Falco requiere acceso
al kernel/recursos del host y compatibilidad modern eBPF. Detalle en sus README.
Las versiones de charts se fijan, pero no todas las imágenes/reglas transitivas
son inmutables; conservar las identidades efectivas al hacer una instalación nueva.

Para pedir además el arranque del perfil existente, con Docker ya iniciado:

```bash
L4_START_MINIKUBE=1 bash scripts/l4/start.sh --jenkins-existing --security
```

No cambia automáticamente memoria, CPUs ni versión de Kubernetes de un perfil
existente. No instala Docker, abre Docker Desktop ni inicia sesión por Bruno.

El inicio conserva la imagen del Deployment existente. Si no existe, usa el
digest publicado en L4-09. `L4_IMAGE` permite elegir otra referencia explícita.
La API, Prometheus y Grafana se instalan/actualizan con espera de rollout y
comprobaciones HTTP: salud API `UP`, Prometheus ready y base Grafana `ok`.
Resultado esperado: `PASS`, tres Deployments disponibles y tres PVC Bound.
Repetir el inicio genera otra revisión Helm; no borra datos.

## 2. Tráfico y paneles

```bash
bash scripts/l4/traffic.sh
```

Por defecto: 60 iteraciones, dos lecturas y un pedido por iteración, con pausa
de un segundo. Usa/reutiliza el producto `l4-10-trafico`, precio 42.5. Comprueba
IDs de pedidos distintos y que el incremento de `pedidos_creados_total` del
producto sea exactamente igual al número de pedidos creados. Cualquier error
HTTP, JSON o discrepancia termina con error y registra `FAIL`.
La API debe estar saludable. No ejecutar dos generadores simultáneos sobre
el mismo producto: la correlación estricta detectaría sus pedidos adicionales.

```bash
L4_ITERATIONS=90 L4_INTERVAL=1 bash scripts/l4/traffic.sh
bash scripts/l4/access.sh
```

Límites: 1–300 iteraciones y pausa 1–5 segundos; sin concurrencia. Es tráfico
demostrativo para los paneles, no una medición de capacidad. Los pedidos quedan
en H2. Reutilizar el producto limita la cardinalidad de la métrica; los registros
siguen creciendo según el número explícito de pedidos.

`access.sh` muestra direcciones en puertos locales libres asignados por el
sistema: API, Prometheus y Grafana (`/d/l4-observabilidad`). Dejarlo activo y
abrir esas direcciones. Generar tráfico en otra terminal. Revisar RPS, latencia,
CPU/memoria por pod y pedidos. El dashboard refresca cada 5 s; seleccionar el
intervalo de generación si el tráfico ya terminó. Con Ctrl+C se cierran solo
los túneles de esa ejecución. Si reinicia un Pod, repetir `access.sh`.

## 3. Limpieza con alcance explícito

```bash
bash scripts/l4/clean.sh
```

Por defecto solo escribe el **plan**, `PLAN_ONLY`. Para ejecutarlo:

```bash
L4_CONFIRM=minikube/laboratorio4/l4 bash scripts/l4/clean.sh --apply
```

Retira el release de aplicación: API, Prometheus, Grafana, Services, ConfigMaps,
ServiceAccount y RBAC de métricas. Los tres PVC llevan `helm.sh/resource-policy:
keep`; conservan H2, TSDB y Grafana. Reinstalar con el mismo release/namespace
reutiliza esos volúmenes. No confundir desinstalar con borrar los datos.

Para eliminar también **todos los datos de esos tres PVC**:

```bash
L4_CONFIRM=minikube/laboratorio4/l4 bash scripts/l4/clean.sh --apply --purge-data
```

Solo borra los nombres exactos del release tras comprobar su propietario Helm;
un PVC ajeno/sin propietario provoca error. El borrado del volumen físico depende
de la política de recuperación del StorageClass/PV. No elimina directorios del host.

Para retirar además los componentes de seguridad de este laboratorio:

```bash
L4_CONFIRM=minikube/laboratorio4/l4 bash scripts/l4/clean.sh --apply --purge-data --security
```

Retira las cuatro políticas del archivo L4 y los releases `falco/falco` y
`kyverno/kyverno`. Usar solo si estas instalaciones siguen dedicadas al laboratorio.
No ejecuta borrado adicional de CRD ni namespaces. Helm puede retirar CRD del
chart sin política keep; en B04 conservó algunas CRD, un ConfigMap y un hook
completado. Por eso el retiro de seguridad requiere instalaciones dedicadas.
Tampoco toca `default`, Minikube, imágenes, Jenkins, credenciales,
volumen Jenkins, repositorios o reportes. El Jenkins heredado y el clúster son
infraestructura compartida; para detenerlos sin borrar sus datos, al terminar
**todos** los trabajos, los comandos separados son `docker stop jenkins` y
`minikube stop -p minikube`. No se ejecutan como efecto lateral de la limpieza.

Los scripts se invocan con `bash`, sin requerir permisos ejecutables de Windows.
No usan eliminación recursiva de archivos ni `kubectl delete all --all`.

## Evidencias y diagnóstico

Cada ejecución crea un directorio nuevo en `reports/l4-10/`, con UTC, operación
y PID. `L4_EVIDENCE_DIR` permite otro destino **que todavía no exista**. Se guarda
alcance, resultados HTTP, valores Helm, pedidos/contadores o plan de limpieza.
Nunca reutilizar un directorio ni interpretar una ejecución sin PASS como éxito.
Los túneles temporales se cierran al terminar o fallar. No se guardan tokens.

Si falta Docker, acceso al clúster o herramienta, corregir ese prerrequisito y
repetir en otro directorio. Si Snyk/Kubernetes de Jenkins deja de autenticar,
consultar `ci/connect-minikube.ps1` y el cierre L4-09 (token Kubernetes de 24 h);
estos scripts no renuevan credenciales ni vuelven a ejecutar los análisis.

Referencias: [Helm uninstall](https://helm.sh/docs/helm/helm_uninstall/),
[conservación de recursos](https://v3.helm.sh/docs/intro/using_helm/),
[kubectl port-forward](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_port-forward/).
Resultados comprobados y límites: [L4-10](../../reports/l4-10/VERIFICACION.md),
[B03 Helm](../../reports/l4-11b/b03-helm.md) y
[B04 reproducción](../../reports/l4-11b/b04-reproduccion.md).
El chart local es 0.3.0; el principal conservado en B04 sigue en 0.2.1,
revisión 10. Ejecutar start.sh puede actualizarlo al chart local: no es una
consulta de estado. Para crear un entorno aislado usar la guía B04.
Resultados de seguridad e identidades: [índice vigente](../../reports/ESTADO-EVIDENCIAS-L4.md).
Esta guía operativa no sustituye el informe final L4-12 ni publica los archivos.
