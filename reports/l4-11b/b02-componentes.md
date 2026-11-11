# B02 — Dockerfiles, versiones y usuarios

Fecha: 11/11/2026, Uruguay. Cierre técnico con excepciones documentadas;
**cumplimiento literal global de 1.b–c parcial**. Este registro no constituye
aceptación docente ni informe final. No se recreó Jenkins ni se cambió el clúster.

## Alcance adoptado

El único componente de software propio es la API Java con H2 embebida.
No existen frontend propio ni servidor H2 separado en esta arquitectura.
Se mantiene su Dockerfile multi-stage JDK → JRE con Maven/test en build y solo
JAR en runtime. Sus bases Temurin 21.0.13+9 JDK/JRE están fijadas por digest.
L4-01 acredita build/test/persistencia; B01 acredita composición de la imagen #7.
No se reconstruyó la API en B02.

Prometheus, Grafana, Kyverno y Falco se consumen como imágenes de terceros y
charts versionados. Decisión: conservar esos artefactos upstream y las
configuraciones locales, sin agregar Dockerfiles que únicamente repitan FROM
ni etapas de build sin una compilación real. Jenkins es infraestructura heredada
del curso. Esto explica la decisión técnica, pero **no prueba el requisito literal
de un Dockerfile propio por cada herramienta**. Si se exige literalmente, queda
pendiente acordar/ampliar ese alcance y construir/probar los derivados necesarios.

## Versiones y usuarios comprobados ahora

Evidencia de lectura del clúster y Docker en [b02/](b02/); `inventario.json`
guarda referencias, imageID efectivo, securityContext, estado y usuario que
reporta el runtime, incluyendo contenedores init y job conservado de Kyverno.

| Componente | Versión/referencia | Usuario/alcance |
|---|---|---|
| API | Jenkins #7 `l4-7-0f47780b51b3`; digest publicado en B01 | UID/GID 10001, confirmado por exec y runtime |
| Prometheus | v3.16.0 + digest en values.yaml | UID/GID 65534, exec y runtime |
| Grafana | 13.0.12 + digest en values.yaml | UID/GID 472, exec y runtime; grupo suplementario 0 presente, no UID root |
| Kyverno | chart 3.10.0-rc.4; kyverno, kyvernopre, reports-controller y kyverno-cli v1.20.0-rc.4 | UID/GID 65534 según runtime y contextos; incluye init/job terminado |
| Falco | chart 9.2.2; falco 0.45.2; falcoctl init 0.14.3 | sensor UID 0 por exec/runtime; init UID 65532 por runtime |
| Jenkins | core 2.568.3; referencia heredada `ucu-devops/jenkins:lts` | UID 0 por exec; socket Docker rw y volumen existente |

Kyverno no contiene el ejecutable `id`: el intento falló y se conserva separado.
La confirmación de UID procede de `status.*ContainerStatuses.user.linux` y
securityContext, no de ese exec fallido. El init/job terminado no fue reejecutado.
El inventario completo de Pods incluye namespace default/kube-system como
antecedente observado: no forma parte del stack L4 ni fue corregido en B02.
Default aún tiene imágenes sin versión de monitoreo; no extender la conclusión
de versionado a esos despliegues históricos.

Las referencias de las herramientas L4 observadas tienen versión específica.
Los charts fijados controlan sus defaults; registrar un imageID no fija por sí
solo una instalación futura ni hace inmutables las reglas descargadas por Falco.
No se modificaron los charts ni las reglas en B02. Las versiones candidatas de
Kyverno siguen siendo una limitación de laboratorio, como documenta L4-07.

## Corrección acotada de Jenkins

`ci/jenkins-image.lock.json` conserva el imageId local exacto:
`sha256:99ea0037369f4639f495e5646bfef6b1820aa1b714a95b0e23e2edea1da76702`.
`scripts/l4/verify-jenkins.sh` compara ese ID con el contenedor existente sin
leer variables de entorno, credenciales ni contenido del volumen. `start.sh
--jenkins-existing` llama al verificador antes de iniciar Minikube, aplicar
recursos Kubernetes o iniciar Jenkins. No resuelve ni descarga `lts`.

El ID identifica la configuración de imagen local; no confundirlo con un digest
de manifiesto de registro, aunque la salida local de RepoDigests muestre la
misma cadena. No se comprobó pull remoto de Jenkins por digest. El lock no
reproduce la capa escribible con herramientas añadidas, plugins/jobs ni volumen.
`lts` continúa siendo móvil: **no se declara corregida su etiqueta ni un Jenkins
reproducible desde cero**. Esta corrección detecta cambios de imagen en el inicio
del entorno existente. La guía operativa enlaza estas limitaciones.

Pruebas: verificador real PASS, sintaxis Bash PASS; Docker simulado devolviendo
otra imagen → exit 1 y mensaje de rechazo. La prueba negativa no llama al Docker
real. Primer intento negativo falló por acceso local al proceso Bash; conservado
como intento, repetido con acceso suficiente. No se ejecutó `start.sh` completo
porque instala/actualiza recursos ajenos a esta comprobación de identidad.

## Excepciones no root y pasos pendientes

API/Prometheus/Grafana tienen runAsNonRoot, capacidades eliminadas y escalada
deshabilitada; Kyverno declara además filesystem de solo lectura. No extrapolar
esto a todos los contenedores del host o del clúster.

Falco modern eBPF usa `leastPrivileged: true`: contenedor principal sin
`privileged: true`, pero UID 0, AppArmor Unconfined y capacidades BPF,
SYS_RESOURCE, PERFMON y SYS_PTRACE. Es una excepción de sensor de host,
no ejecución no root. Se preserva la configuración probada L4-08.

Jenkins root + socket rw permite controlar Docker y no satisface no root.
Cambiar únicamente USER no aísla ese acceso. La migración propuesta es separar
controlador no root y agente de build con acceso Docker acotado, conservando y
probando trabajos, permisos de volúmenes/herramientas y credenciales. No se
implementó una migración del Jenkins del curso ni se demuestra aislamiento.

- [x] Inventariar componentes propios/terceros, versiones y usuarios reales.
- [x] Mantener Docker multi-stage real de API y documentar decisión upstream.
- [x] Controlar identidad de Jenkins existente y probar aceptación/rechazo.
- [x] Explicitar excepciones Falco/Jenkins sin afirmar conformidad universal.
- [ ] Conformidad literal de Dockerfile por herramienta y multi-stage global:
  decisión técnica documentada; aceptación o ampliación pendiente.
- [ ] Jenkins no root/aislado y aprovisionamiento reproducible desde cero:
  migración pendiente, fuera del cambio acotado aplicado aquí.

438 archivos previos de reports intactos por SHA256. No nuevos scans de
vulnerabilidades, build/push, despliegue, merge, commit ni Word.

Referencias primarias consultadas el 11/11/2026:
[Docker: versiones y digest](https://docs.docker.com/build/building/best-practices/),
[Jenkins sobre Docker](https://www.jenkins.io/doc/book/installing/docker/),
[Jenkins Pipeline y daemon Docker](https://www.jenkins.io/doc/book/pipeline/docker/),
[Falco en contenedor y least privilege](https://falco.org/docs/setup/container/).
Las decisiones de alcance son del proyecto, no una exención otorgada por esas fuentes.
