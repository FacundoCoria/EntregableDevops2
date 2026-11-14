# C04 — Dockerfiles y excepciones

Fecha: **14/11/2026, Uruguay**. **Decisión técnica acordada con Bruno:** conservar
las imágenes oficiales de Prometheus, Grafana, Kyverno y Falco; documentar el
alcance y las excepciones. C04 cerrada como decisión/documentación local.
**La conformidad literal global y la aceptación docente siguen pendientes.**
No se construyeron imágenes ni se consultaron servicios en esta etapa.

## Consigna y alcance adoptado

La página 1 de la consigna pide Dockerfile por componente, versiones específicas,
procesos no root y optimización mediante multi-stage. La consigna no contiene una
exención expresa para herramientas oficiales. La decisión del proyecto no cambia
ese texto ni equivale a una aprobación académica.

Se entrega un Dockerfile real para la API propia y dos derivados reales para
Jenkins dedicado. H2 está embebida en la API; no hay frontend propio ni servidor
de base separado. Las otras herramientas se instalan con imágenes/charts upstream
versionados y configuración local. No se añaden Dockerfiles que solo repitan FROM
ni se atribuye un multi-stage a una imagen upstream sin verificar su construcción.

## Matriz por componente

Los UID de Kubernetes proceden del inventario **11/11**; Jenkins dedicado fue
probado en C01 **13/11** y confirmado en C03 **14/11**. Se releyeron esas evidencias;
no son una comprobación en vivo del estado actual.

| Componente | Dockerfile / construcción local | Usuario de ejecución y límite |
|---|---|---|
| API Java + H2 | [Dockerfile](../../pedidos-api/pedidos-api/Dockerfile): build Maven/test JDK → JRE con JAR; multi-stage real | UID/GID 10001; pruebas L4-01 y #7/B01. Bases Temurin 21.0.13_9 por digest. |
| Jenkins controlador | [Dockerfile.controller](../../ci/jenkins/Dockerfile.controller): plugins fijados/hash, init y configuración; una etapa | USER final 1000:1000, cero ejecutores. Jenkins 2.580.2-jdk21 por digest. No multi-stage ni análisis de tamaño propio acreditado. |
| Jenkins agente | [Dockerfile.agent](../../ci/jenkins/Dockerfile.agent): dos etapas; copia Docker CLI/Buildx desde imagen externa | USER final 1000:1000, un ejecutor; conserva JDK/herramientas requeridos por CI. Multi-stage de transferencia, no compilación propia de Docker ni prueba de reducción cuantitativa de tamaño. |
| Motor Docker dedicado | Imagen oficial docker:29.7.2-dind por digest; sin Dockerfile derivado | Root y privileged:true: excepción explícita. TLS y volúmenes/redes propios; comparte kernel y el agente puede controlar ese motor. |
| Prometheus | Imagen oficial v3.16.0 por digest en Helm; sin derivado local | UID/GID 65534 en B02; sin multi-stage local acreditado. |
| Grafana | Imagen oficial 13.0.12 por digest en Helm; sin derivado local | UID/GID 472 en B02; grupo suplementario 0 no implica UID root. Sin multi-stage local acreditado. |
| Kyverno | Chart 3.10.0-rc.4 / imágenes 1.20.0-rc.4; sin derivados locales | UID/GID 65534 según runtime/contextos B02, incluidos init/job inventariados; `id` no disponible. Versión candidata/una réplica: C05. |
| Falco | Chart 9.2.2 / sensor 0.45.2 e init falcoctl 0.14.3; sin derivados locales | Sensor UID 0; init UID 65532 en B02. Excepción de sensor del host; sin multi-stage local acreditado. |

Semgrep, Snyk, Maven, Helm y kubectl son herramientas del agente, no servicios
contenedorizados separados en esta arquitectura. Sus versiones efectivas fueron
verificadas en C01; no se inventan componentes adicionales para darles Dockerfile.

## Excepciones y controles compensatorios

**Jenkins dedicado:** el root usado durante instrucciones de construcción no es
el usuario final del controlador/agente. Ambos terminan en 1000:1000 y Compose
lo exige también. Tienen capacidades eliminadas y no-new-privileges; el
controlador no ejecuta builds y no tiene acceso al motor Docker. El agente accede
por TLS al DinD propio, sin socket del equipo. Eso separa el motor del curso,
pero permite al agente controlar contenedores privilegiados en su motor y no
demuestra aislamiento frente a código hostil. DinD permanece como excepción;
un motor rootless exigiría otro diseño y pruebas, fuera de esta decisión.

**Falco:** se conserva `modern_ebpf` y `leastPrivileged: true` de la configuración
probada L4-08. B02 registra UID 0, capacidades BPF, SYS_RESOURCE, PERFMON y
SYS_PTRACE, AppArmor Unconfined y ausencia de privileged:true en el principal.
Necesita observación del host para detectar eventos del kernel; esos accesos
son sensibles y amplían el impacto de una vulnerabilidad. `leastPrivileged` no
significa no root. No se afirma que root sea inevitable en todo despliegue de
Falco: esta es la excepción de la configuración probada, sin rediseño en C04.

**Jenkins del curso:** conserva su identidad histórica, UID 0 y socket Docker rw.
No fue migrado ni eliminado. Es antecedente externo a la instalación nueva C01;
su estado no debe atribuirse al controlador/agente dedicados.

## Estado de conformidad y aceptación pendiente

| Cláusula | Conclusión C04 |
|---|---|
| 1.b Dockerfile por componente | API y dos imágenes Jenkins propias disponibles; herramientas oficiales sin derivados. Interpretación técnica acordada; literal global parcial. |
| 1.c.a Versiones específicas | Jenkins nuevo resuelve la etiqueta móvil del curso para la instalación dedicada; bases/CLI/DinD por digest en images.env. No implica fijación bit a bit de apt/Python o reglas Falco. |
| 1.c.b No root | API/monitoreo/Kyverno y controlador/agente dedicados respaldados; excepciones Falco/DinD. No conformidad universal. |
| 1.c.c Multi-stage/tamaño | API build/runtime y agente con etapa externa; controlador de una etapa y oficiales sin construcción local. No conformidad literal global ni medición de optimización Jenkins. |

Bruno aceptó conservar oficiales y documentar este criterio. **No se localizó
aceptación del docente en lo revisado.** Queda abierta la validación académica de
1.b–c, incluyendo la excepción DinD incorporada en C01. Si exige derivados o
multi-stage adicional, precisar qué componentes y qué transformación real se
requiere; construir, verificar usuarios/función y comparar tamaño/capas antes de
actualizar las conclusiones. Un derivado por sí solo no resuelve no root ni
demuestra optimización. No se envió ninguna consulta a terceros.

## Evidencias y fuentes

- [B02 e inventario original](../l4-11b/b02-componentes.md), [inventario JSON](../l4-11b/b02/inventario.json).
- [Pruebas C01](../l4-c01/VERIFICACION.md), [contenedores C01](../l4-c01/verification-final-after-cold/containers.json).
- [Resultado C03](../l4-c03/primary-final/result.json): controlador/agente UID 1000, TLS y motor propio.
- [Compose](../../ci/jenkins/compose.yaml), [bases fijadas](../../ci/jenkins/images.env).
- [Configuración Falco](../../pedidos-api/pedidos-api/security/falco/values-minikube.yaml), [evento L4-08](../falco-event.md).
- [Verificación documental C04](VERIFICACION.md), [resultado automático](verificacion.json).

Fuentes primarias consultadas el 14/11/2026:
[Docker multi-stage](https://docs.docker.com/build/building/multi-stage/) explica
etapas y copia selectiva, incluyendo una imagen externa como etapa;
[Jenkins Docker](https://www.jenkins.io/doc/book/installing/docker/) muestra
personalización de imagen con cambio de usuario;
[Falco en contenedor](https://falco.org/docs/setup/container/) describe capacidades
modern eBPF. Respaldan mecanismos técnicos, no una excepción académica.

README/informe y diagrama publicados quedan intactos; C09 debe incorporar estas
decisiones y superar sus referencias históricas a Jenkins root. C07 integral,
C05 Kyverno y C06 residuales conservan su alcance. Sin commit/push/merge.
