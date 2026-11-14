# Laboratorio 4 — Requisitos, avances y evidencias

**L4-11B/B04, 11/11/2026: reproducción y limpieza Kubernetes verificadas;
alcance global parcial por Jenkins heredado.** Perfil descartable nuevo con
API/Prometheus/Grafana/Kyverno/Falco; reinicio en frío, H2 y targets UP;
limpieza real de seguridad/datos y eliminación total de perfil/volumen. Segundo
ciclo completo con scripts finales PASS. Principal revisión 10 y Jenkins
preservados; 525 reportes/Word/PDF previos intactos. Intento inicial fallido
conservado y recuperación separada.
[Handoff B04](handoffs/HANDOFF_L4_11B_B04_REPRODUCCION_2026-11-11.md) y
[registro técnico](EntregableDevops2/reports/l4-11b/b04-reproduccion.md).
Siguiente: **B08 — coherencia de guías y evidencias**, GPT-6.1 Sol/esfuerzo medio.
Podés cerrar este chat. B04 global/Jenkins desde cero, B02 literal, B05 publicación,
B06 informe y residuales de seguridad siguen pendientes; E3 pausado.

Los cierres anteriores son antecedentes; prevalece este estado.

**L4-11B/B03 completa, 11/11/2026: Helm 0.3.0 parametrizado y probado.**
Puertos HTTP 1024–65535; réplicas 0/1 con Recreate y único escritor por PVC.
Tres lint, cuatro renders, 15 rechazos y dos dry-run servidor PASS; variante
temporal con tres servicios saludables y scrape API UP. Release/PVC temporales
retirados, túneles cerrados y principal l4 revisión 10 preservado. 464 archivos
previos de reportes/Word/PDF intactos. [Handoff B03](handoffs/HANDOFF_L4_11B_B03_HELM_2026-11-11.md)
y [registro técnico](EntregableDevops2/reports/l4-11b/b03-helm.md).
Siguiente: **B04 — reproducción y limpieza**, GPT-6.1 Sol/esfuerzo alto.
Podés cerrar este chat. B02 literal, B08 global, publicación e informe siguen
pendientes; E3 pausado. El release principal conserva chart 0.2.1: 0.3.0 fue
probado en release temporal, no instalado como actualización del principal.

Los cierres anteriores siguientes son antecedentes; prevalece este estado.

**L4-11B/B02, 11/11/2026: verificación y control de identidad completados;
conformidad literal parcial.** API/Prometheus/Grafana no root comprobados;
Kyverno UID 65534 por runtime; Jenkins/Falco UID 0 como excepciones explícitas.
Jenkins existente protegido contra imagen distinta en inicio (PASS/rechazo probado),
sin migración ni reinicio. Imágenes oficiales conservadas sin Dockerfiles vacíos;
no implica aceptación literal de Dockerfile por herramienta. 438 reportes previos
intactos. [handoff B02](handoffs/HANDOFF_L4_11B_B02_DOCKER_VERSIONES_2026-11-11.md) y [registro técnico](EntregableDevops2/reports/l4-11b/b02-componentes.md).
B01 completa; B02 literal, B03–B04/B08 y migración Jenkins pendientes.
Siguiente: **B03 — Helm**, GPT-6.1 Sol/esfuerzo alto. Podés cerrar este chat.
Sin publicación GitHub, cambios de clúster ni informe final.


**L4-11B parcial, 11/11/2026: B01 completada sobre imagen publicada #7.**
Pull por digest confirmado; Trivy **0 críticos, 2 altos, 23 medios, 16 bajos**
(41 filas/30 IDs); ocho capas, **150.630.157 bytes Docker**, Dive **98,6734 %**.
Once hallazgos Java de L4-02 ya no aparecen; persisten dos HIGH Ubuntu.
Snyk conserva su alta independiente. Diagnóstico anterior preservado.
[Reporte actual](EntregableDevops2/reports/l4-11b/image-analysis.md) y [handoff B01](handoffs/HANDOFF_L4_11B_IMAGEN_PUBLICADA_2026-11-11.md).
B02–B04/B08 siguen abiertos; E3 pausado, sin GitHub/push ni informe final.
Siguiente: **L4-11B/B02**, GPT-6.1 Sol/esfuerzo alto según el plan.
Podés cerrar el chat con B01 guardada.

## Antecedente L4-11 (prevalece el avance B01 anterior)

Actualizado: **11/11/2026, Uruguay, cierre L4-11**.

**L4-11 completa como revisión documental, 11/11/2026; entrega parcial.**
Consigna de cinco páginas contrastada con archivos/resultados L4-01 a L4-10.
Evidencias íntegras: 33 artefactos Jenkins, 6 scripts/guía y 77 archivos del
snapshot; 531 archivos de repo/Word/consigna preservados. Brechas: análisis de
imagen publicada, alcance Docker/no root, configuración Helm y reproducción/
limpieza total, entrega Git e informe. Sin controles nuevos, implementación,
publicación ni escritura del informe. [Handoff L4-11](handoffs/HANDOFF_L4_11_REVISION_INTEGRAL_2026-11-11.md).
Siguiente recomendado: **L4-11B — cierre de brechas técnicas**, Sol/esfuerzo alto;
L4-12 queda para redacción con alcance propio. Podés cerrar este chat.

## Lectura y criterio

Consultar primero [maestro](HANDOFF_MAESTRO.md), [mapa histórico E3](MAPA_CONSIGNA_EVIDENCIAS.md)
y [plan L4](PLAN_TRABAJO_LABORATORIO_4.md). E3 permanece pausado. Este mapa es
la matriz de revisión; no es el informe final del apartado 6.

- **V**: contenido/ejecución específica verificados en archivos guardados.
- **P**: cumplimiento parcial, excepción o alcance que impide afirmar conformidad total.
- **PD**: pendiente; evidencia no localizada en lo revisado o contenido aún no redactado.
- **NC**: condicional que no corresponde al alcance local documentado.

B02 agrega inventario actual y usuarios runtime del stack L4; evidencias en reports/l4-11b/b02/. Las demás comprobaciones operativas de clúster son anteriores, conservadas en las etapas.
B01 agrega pull remoto, Dive y Trivy reales del 11/11; no salud actual del clúster.
L4-11 revisó sus archivos; no acredita salud actual ni consultas remotas nuevas.
La [consigna original](Laboratorio%204.pdf) fue leída completa (páginas 1–5).
`A/` significa `EntregableDevops2/pedidos-api/pedidos-api/`; `R/` significa
`EntregableDevops2/reports/`. Las rutas requeridas `/reports` y `/grafana` se
interpretan desde la raíz del repositorio, no desde el filesystem del sistema.

El [mapa anterior íntegro](handoffs/evidencias_l4_11_2026-11-11/MAPA_LABORATORIO_4_EVIDENCIAS-antes.md)
conserva diagnóstico remoto del 10/11, copias de fuentes y todos los avances.
Sus tablas de estado antiguo quedan sustituidas por las de este mapa. El
[diagnóstico original](handoffs/HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md)
mantiene las fuentes remotas; no se consultaron nuevamente en L4-11.

## 1. Contenerización — páginas 1–2

| Cláusula | Estado | Evidencia, alcance y brecha |
|---|---|---|
| 1.a Componentes contenedorizados | V para entorno implementado | API/H2 embebida, Prometheus, Grafana, Jenkins existente, Kyverno/Falco. Sin frontend ni servidor H2 separado. Inventario L4-01 y arquitectura L4-11; no implica Dockerfile propio para todos. |
| 1.b Dockerfile por componente | P literal — B02 documentada | API propia con Dockerfile; terceros upstream sin derivados vacíos por decisión técnica. No prueba aceptación literal global. [B02](EntregableDevops2/reports/l4-11b/b02-componentes.md). |
| 1.c.a Versiones específicas, no latest | V stack L4; P Jenkins — B02 | Herramientas L4 con versiones específicas, inventario real guardado. Jenkins lts sigue móvil; lock local imageId y rechazo en inicio probados, sin reproducir instalación. Reglas Falco no inmutables. |
| 1.c.b No root | V API/monitoreo/Kyverno; P global — B02 | UID exec 10001/65534/472; Kyverno runtime 65534 (exec id ausente). Jenkins/Falco UID 0; sensor con capacidades específicas, sin privileged:true principal. Excepciones, no conformidad global. |
| 1.c.c Multi-stage/tamaño | V API; P literal global — B02 | API JDK→JRE/JAR único comprobado L4-01/B01; terceros upstream sin build artificial. Alcance técnico decidido, aceptación literal pendiente. |
| 1.d.a Snyk o Trivy sobre imagen | V B01 | Imagen #7 por digest: Trivy 0.76.1, 41 filas/30 IDs (0 críticos/2 altos/23 medios/16 bajos). [Reporte](EntregableDevops2/reports/l4-11b/image-analysis.md); L4-02 preservado. Snyk Maven sigue separado. |
| 1.d.b Dive Windows | V B01 | Dive Windows 0.13.1 sobre mismo TAR publicado: ocho capas, 98,6734 % eficiencia, CI PASS (2/1 desactivada). |
| 1.e.a Tamaño en image-analysis.md | V B01 | Docker 150.630.157 bytes, Dive 346.922.869 bytes de contenido; mediciones distintas. Índice actual y comparación en reports/image-analysis.md. |
| 1.e.b Cantidad de capas | V B01 | Ocho capas, blobs OCI y DiffIDs verificados Docker/Trivy/Dive; dos sin contenido de archivos. |
| 1.e.c Optimizaciones | V B01 | Multi-stage/JAR único comprobado; propuestas de no-log-init/runtime menor con pruebas. Dos HIGH Ubuntu abiertos; nueve HIGH/CRITICAL Java históricos ya no detectados. |

Fuentes: [L4-01](handoffs/HANDOFF_L4_01_DOCKER_MANIFIESTOS_2026-11-10.md),
[L4-02](handoffs/HANDOFF_L4_02_DIVE_TRIVY_2026-11-10.md),
[reporte imagen](EntregableDevops2/reports/image-analysis.md),
[Trivy JSON](EntregableDevops2/reports/l4-02/trivyreport.json),
[Dive JSON](EntregableDevops2/reports/l4-02/dive.json),
[Dockerfile](EntregableDevops2/pedidos-api/pedidos-api/Dockerfile).

## 2. Orquestación y despliegue — página 2

| Cláusula | Estado | Evidencia, alcance y brecha |
|---|---|---|
| 2.a Helm Chart | V | `A/helm-chart/`, chart local **0.3.0** probado temporalmente en B03, principal **0.2.1**; dieciséis recursos; appVersion l4-01 es metadato histórico, no identifica por sí solo imagen desplegada. |
| 2.b.a Deployment, Service, ConfigMap | V | 3 Deployment, 3 Service ClusterIP, 4 ConfigMap, 3 PVC y 3 SA/RBAC en render #7. |
| 2.b.a Ingress si corresponde | NC | Acceso local loopback por port-forward probado; no requiere Ingress en este alcance. |
| 2.b.b values configurables | V acotada — B03 | Imágenes/recursos/storage/entorno, puertos HTTP 1024–65535 y réplicas 0/1 configurables en 0.3.0. Variante real con scrape UP; pausa solo renderizada. Recreate/un escritor; 2+ rechazadas, sin HA. [Registro](EntregableDevops2/reports/l4-11b/b03-helm.md). |
| 2.c helm install | V | Instalación real L4-03 revisión 1; revisión 2 tras upgrade. Posteriores: #7 revisión 8 y L4-10 revisión 10, no confundir número de revisión con versión del chart. |
| 2.d values-dev o prod | V | `A/helm-chart/values-dev.yaml`: título/perfil dev/pullPolicy Never; CI/scripts sobrescriben imagen/pullPolicy para registro. No hay prod acreditado ni es obligatorio tener ambos. |
| 2.e Pods y acceso | V anterior | Tres Pods Ready/PVC Bound y HTTP API/Prometheus/Grafana; H2 recuperado tras recrear Pod. L4-10 final conserva imagen #7. No comprobado en vivo por L4-11. |

Fuentes: [L4-03](handoffs/HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md),
[Chart](EntregableDevops2/pedidos-api/pedidos-api/helm-chart/Chart.yaml),
[values](EntregableDevops2/pedidos-api/pedidos-api/helm-chart/values.yaml),
[render #7](EntregableDevops2/reports/l4-09/integral-7/helm-rendered.yaml),
[cierre L4-10](EntregableDevops2/reports/l4-10/final-verification.json).

## 3. Jenkins — página 2

| Cláusula | Estado | Evidencia, alcance y brecha |
|---|---|---|
| 3.a Automatizar integración/despliegue | V local | Job L4-09-pedidos-api, #7 SUCCESS/97,054 s; seis etapas reales. |
| 3.b.a Clonar repositorio | V Git local — B05 entrega | `git clone /var/jenkins_home/l4-source.git`, commit 0f47780b51b3711763d6aebf4a9791d5d1edee28. No fue GitHub; clonación remota no exigida expresamente. |
| 3.b.b Semgrep | V | Dos reglas, ocho fuentes Java, 0 hallazgos/errores. |
| 3.b.c Snyk dependencias | V | 130 dependencias con test, 0 críticos/1 alto/8 medios/1 bajo; exit 1 por hallazgos, gate PASS por ausencia de críticos. |
| 3.b.d Build/test | V | Maven clean verify, una prueba/0 fallos/0 errores; JUnit archivado. |
| 3.b.e Imagen y publicación | V anterior | Docker build multi-stage desde caché en #7, push final; etiqueta l4-7-0f47780b51b3 y digest 48b65d… en Docker Hub. No publicación de código. |
| 3.b.f Helm automático | V | #7 desplegó revisión 8, salud UP, tres Pods Ready; client-side/legacy wait sin ampliar RBAC. |
| 3.c Jenkinsfile en repo | V archivo local; P entrega — B05 | `EntregableDevops2/Jenkinsfile` sin commit en repo de trabajo; incluido en snapshot local probado. No conectado a fuente GitHub. |
| 3.d Éxito y registros por fase | V | Consola, logs de herramientas, JUnit, digest, render/status/values, salud/métricas; 33 huellas sin diferencias. |
| 3.e Detener/reportar críticos | V | #3 BLOCKED_CRITICAL con siete críticos; continuación omitida. #2 fue error técnico de wrapper, no detección; #3/#7 y gate-tests conservados separados. |

Fuentes: [cierre L4-09](handoffs/HANDOFF_L4_09_CIERRE_JENKINS_2026-11-11.md),
[Jenkinsfile](EntregableDevops2/Jenkinsfile),
[consola #7](EntregableDevops2/reports/l4-09/integral-7/jenkins-console.txt),
[verificación #7](EntregableDevops2/reports/l4-09/integral-7/verification.json),
[gate #3](EntregableDevops2/reports/l4-09/security-3/gate-summary.json).

## 4. Observabilidad — página 3

| Cláusula | Estado | Evidencia y límites |
|---|---|---|
| 4.a–b Instrumentación/endpoint | V | Micrometer, `/actuator/prometheus`; métricas HTTP/negocio, sin integrar rama métricas-nuevas. |
| 4.c Prometheus en clúster/scrape | V anterior | API y kubelet-resource UP en L4-04, configuración Helm. |
| 4.d Grafana conectado | V anterior | Datasource uid l4-prometheus, salud OK y consultas Grafana/Prometheus correlacionadas. |
| 4.e.a RPS | V | Panel 1, rate del contador HTTP de `/api/.*`. |
| 4.e.b Latencia promedio | V | Panel 2, rate(sum)/rate(count); no confundir con minutos de espera de negocio. |
| 4.e.c CPU y memoria por pod | V | Paneles 3–4, kubelet resource; tres Pods principales, nodo Minikube. |
| 4.e.d Negocio | V | Paneles 5–6, pedidos por producto/tasa; 17 pedidos correlacionados en L4-04, 20+1 en L4-10. Contadores se reinician con proceso, no total histórico H2. |
| 4.f Export /grafana/dashboard.json | V local | Seis paneles; idéntico a copia Helm, equivalente a export tras normalizar id; adjunto local pendiente entrega. |

Fuentes: [L4-04](handoffs/HANDOFF_L4_04_OBSERVABILIDAD_2026-11-10.md),
[consultas verificadas](handoffs/evidencias_l4_04_2026-11-10/verification.json),
[recuperación OOM](handoffs/evidencias_l4_04_2026-11-10/reconexion/recovery-verification.json),
[confirmación de Bruno](handoffs/evidencias_l4_04_2026-11-10/reconexion/visual-confirmation.json),
[dashboard](EntregableDevops2/grafana/dashboard.json).

## 5. Seguridad integrada — páginas 3–4

| Cláusula | Estado | Evidencia y límites |
|---|---|---|
| 5.1.a Semgrep sobre fuentes | V | L4-05 y Jenkins #7, ocho Java productivos; test omitido por patrón default. |
| 5.1.b Dos reglas de lenguaje | V | Java CWE-78/CWE-89, YAML oficiales identificados y pruebas de reglas 2/2. |
| 5.1.c /reports/semgrep-report.txt | V local | Reporte más JSON/log; 0 hallazgos/errores, no ausencia universal de vulnerabilidades. |
| 5.1.d Corregir/justificar hallazgos | V por resultado sin hallazgos | Ningún hallazgo de estas dos reglas requiere remediación. Diagnósticos E3 conservados aparte. |
| 5.2.a Snyk dependencias | V | L4-06 inicial y Jenkins #7 posterior, ambos con test. |
| 5.2.b /reports/snyk-report.txt | V diagnóstico; P contexto vigente — B08 | Reporte inicial conserva 44 rutas/IDs y propuestas; resultado posterior en integral-7. Falta enlazar comparación desde documento entregable, sin sobrescribir inicial. |
| 5.2.c Críticos/propuestas | V | Siete críticos iniciales identificados; remediaciones Tomcat 11.0.27/Jackson BOM 3.1.8 probadas en CI, cero críticos posteriores. Una alta y otros niveles abiertos — B07. |
| 5.3.a Instalar Kyverno | V anterior | 1.20.0-rc.4/chart 3.10.0-rc.4; candidato/una réplica, no configuración productiva. |
| 5.3.b.a Prohibir latest | V alcance probado; P literal — B09 | Deny para latest/sin tag probados; admite digest como alternativa, incluso combinación latest@digest no probada. |
| 5.3.b.b Recursos CPU/memoria | V Pods de proyecto; P global — B09 | Requests/limits containers/initContainers en laboratorio4; no todos los namespaces/ephemeralContainers. |
| 5.3.b.c No root | V alcance probado | runAsNonRoot efectivo/UID distinto de 0, herencia y overrides probados. |
| 5.3.b.d Política adicional | V | Prohíbe privileged en containers/initContainers. |
| 5.3.c Aplicar y rechazar | V anterior | 16/16 server dry-run, cuatro creates reales denegados y conforme Succeeded UID 10001, retirado. |
| 5.3.d /reports/kyverno-validation.log | V local | Log con comandos, expected, exit, rechazo y PASS; no solo manifiestos. |
| 5.4.a Instalar Falco | V anterior | Falco 0.45.2/chart 9.2.2, modern eBPF en Minikube/WSL2. |
| 5.4.b Acción distinta de shell | V anterior | Exec directo `cat /etc/shadow` con fixture ficticio ConfigMap; no shell/TTY, UID 10001. |
| 5.4.c Evento /reports/falco-event.log | V local | Una alerta Warning Read sensitive file untrusted, UTC/Pod/container/comando correlacionados; control sin esa alerta. |
| 5.4.d Descripción | V local | `R/falco-event.md`, acción/evento/límites/limpieza; no incidente real acreditado. |

Fuentes: [Semgrep](EntregableDevops2/reports/semgrep-report.txt),
[L4-05](handoffs/HANDOFF_L4_05_SEMGREP_2026-11-10.md),
[Snyk inicial](EntregableDevops2/reports/snyk-report.txt),
[Snyk posterior](EntregableDevops2/reports/l4-09/integral-7/snyk.json),
[Kyverno log](EntregableDevops2/reports/kyverno-validation.log),
[políticas](EntregableDevops2/pedidos-api/pedidos-api/security/kyverno/policies.yaml),
[L4-07](handoffs/HANDOFF_L4_07_KYVERNO_2026-11-11.md),
[Falco log](EntregableDevops2/reports/falco-event.log),
[descripción](EntregableDevops2/reports/falco-event.md),
[L4-08](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md).

## 6. Reporte técnico final — página 4

| Cláusula | Estado | Trabajo pendiente — B06 |
|---|---|---|
| 6.a README.md o PDF | PD | ReadMe.md actual es de métricas y guía enlazada; Word E3 no sustituye reporte integrador. No se exige nuevo Word. |
| 6.a.a Descripción general | PD redacción final | Inventario/objetivo respaldados en handoffs. |
| 6.a.b Arquitectura con diagrama | PD | Inventario de relaciones L4-11 disponible; diagrama final no localizado en lo revisado. |
| 6.a.c Pipeline | PD redacción final | #3/#7 y etapas respaldados; indicar clonación local y publicación pendiente. |
| 6.a.d Métricas/dashboard | PD redacción final | Seis paneles/JSON y consultas disponibles. |
| 6.a.e Seguridad | PD integración final | Resultados y comparación disponibles; declarar imagen antigua/nueva y hallazgos residuales. |
| 6.a.f Problemas/soluciones | PD integración final | OOM, wrapper, gate, parámetros, push abortado, Helm/RBAC y túneles documentados. |
| 6.a.g Conclusiones/mejoras | PD | Basarlas en resultado parcial y brechas, sin declarar cumplimiento total. |
| 6.b Capturas o fragmentos | V fuentes; PD incorporación | Salidas de herramientas principales existen; seleccionar/extractar en L4-12. No exigir capturas extra si salidas cumplen la alternativa. |
| 6.c Adjuntar dashboard | V local; P entrega | `EntregableDevops2/grafana/dashboard.json` válido y consistente. |

## Consideraciones adicionales — página 5

| Cláusula | Estado | Evidencia y brecha |
|---|---|---|
| a Bash inicialización | V Kubernetes aislado; P global — B04 | sandbox.sh crea perfil nuevo; start.sh instala cinco componentes; recuperación en frío comprobada. Docker/CLI preinstalados; Jenkins desde cero pendiente. [B04](EntregableDevops2/reports/l4-11b/b04-reproduccion.md). |
| a Solicitudes automáticas | V | traffic.sh, 20 pedidos/40 lecturas y contador exacto; +1 final, sin repetirlos por revisión. |
| a Borrar todos los recursos | V perfil Kubernetes dedicado; P global — B04 | Retiro real de seguridad/datos y eliminación total de perfil/CRD/namespaces/volumen comprobados. Jenkins y principal compartidos conservados; no limpieza global de máquina. |
| a Instalación operadores/controladores | V comandos/ejecución aplicable | start.sh --security instala Kyverno/Falco y políticas; no Prometheus Operator porque chart usa recursos directos. Si se pide un Operator específico, no localizado. |
| b Iniciar todos los componentes | V Kubernetes nuevo; P Jenkins — B04 | API/Prometheus/Grafana/Kyverno/Falco disponibles en perfil nuevo y tras reinicio. Jenkins/plugins/jobs/credenciales desde cero pendientes; reutilización anterior separada. |
| c Documentación paso a paso/resultados | V guía operativa; P consistencia — B08 | GUIA.md y VERIFICACION.md; guías históricas del chart necesitan contexto vigente. Informe final separado. |

Fuentes: [guía](EntregableDevops2/scripts/l4/GUIA.md),
[pruebas L4-10](EntregableDevops2/reports/l4-10/VERIFICACION.md),
[handoff L4-10](handoffs/HANDOFF_L4_10_SCRIPTS_2026-11-11.md).

## Evidencia local, publicación y continuidad

Repo de trabajo: rama `lab4/l4-01-docker-manifiestos`, HEAD
`489f9f37a2275a5e284769fdbb511c0855c1c384`; cambios acumulados sin commit/push.
Snapshot Git aislado Jenkins `0f47780b51b3711763d6aebf4a9791d5d1edee28`, bundle
local conservado en handoffs. Imagen #7 publicada según evidencia L4-09; L4-11 no consultó
Docker Hub; L4-11B confirmó después disponibilidad por pull del digest. Código/reportes L4 sin publicar.
Main remoto ee6bc93 es referencia histórica de Jenkins, no consulta nueva.

L4-11 verificó 33 huellas de artefactos, seis de scripts/guía, 77 archivos del
snapshot con LF normalizado; preservó 531 archivos de repo/Word/consigna.
[Verificación documental](handoffs/evidencias_l4_11_2026-11-11/verificacion-documental.json).
Las diferencias SHA crudas POM/Dockerfile son CRLF/LF; contenido normalizado
coincidente. Dashboard export normalizado coincide, no igualdad del envoltorio.

**Pendientes nuevos de entrega:** B01–B09 detallados en el
[handoff L4-11](handoffs/HANDOFF_L4_11_REVISION_INTEGRAL_2026-11-11.md).
Siguiente recomendado L4-11B (brechas técnicas, Sol/alto); después L4-12
(redacción, Sol/medio según el plan), con publicación de alcance propio.
No heredar npm audit de E3; KubeLinter es evidencia adicional, no requisito L4.
No se crean chats automáticamente. Podés cerrar este chat y continuar con el handoff.

## Historial — L4-11B/B01, 11/11/2026

- [x] ~~B01 — analizar por digest la imagen publicada con Trivy/Dive y comparar.~~
  **L4-11B parcial, 11/11/2026: B01 completada sobre imagen publicada #7.**
Pull por digest confirmado; Trivy **0 críticos, 2 altos, 23 medios, 16 bajos**
(41 filas/30 IDs); ocho capas, **150.630.157 bytes Docker**, Dive **98,6734 %**.
Once hallazgos Java de L4-02 ya no aparecen; persisten dos HIGH Ubuntu.
Snyk conserva su alta independiente. Diagnóstico anterior preservado.
[Reporte actual](EntregableDevops2/reports/l4-11b/image-analysis.md) y [handoff B01](handoffs/HANDOFF_L4_11B_IMAGEN_PUBLICADA_2026-11-11.md).
B02–B04/B08 siguen abiertos; E3 pausado, sin GitHub/push ni informe final.
Siguiente: **L4-11B/B02**, GPT-6.1 Sol/esfuerzo alto según el plan.
Podés cerrar el chat con B01 guardada.

- [ ] L4-11B restante: B02 Docker/no root/versiones; B03 Helm;
  B04 reproducción/limpieza; B08 guías (image-analysis ya contextualizado).
- [ ] Remediación residual imagen: dos HIGH apt/libapt-pkg6.0, CVE-2026-109518;
  revisar base/parche, reconstruir, probar y reescanear con alcance propio.

424 reportes inventariados; 423 intactos, image-analysis con cuerpo histórico
íntegro y copia previa. Identidad OCI/DiffIDs y salidas de herramientas comprobadas.
Resultados nuevos locales; disponibilidad remota de la imagen confirmada por pull,
sin publicación nueva ni cambio de despliegue. No atribuir a Snyk el scan de imagen.

## Historial — L4-11B/B03, 11/11/2026

- [x] ~~B03 — configuración Helm de puertos/réplicas y verificación segura.~~
  Chart 0.3.0, procesos/Service/sondas/scrape/datasource coherentes;
  réplicas 0/1, sin escalado horizontal libre. Variante real saludable y
  retirada completa; principal preservado. [Handoff B03](handoffs/HANDOFF_L4_11B_B03_HELM_2026-11-11.md).
- [ ] B04 — reproducción/limpieza completa; siguiente etapa.
- [ ] B08 — guías globales; guía Helm contextualizada en B03, resto pendiente.
- [ ] B02 literal global/Jenkins no root; B05 publicación/B06 informe y
  vulnerabilidades conservan sus pendientes propios.

Pausa (0 réplicas) solo renderizada; scripts con sintaxis comprobada, sin repetir
ciclo completo L4-10 ni persistencia L4-03. Evidencia nueva solo local, sin
commit/push, nuevo scan, imagen, Jenkins ni Word. Podés cerrar este chat.
Siguiente B04 — reproducción y limpieza, GPT-6.1 Sol/esfuerzo alto.

## Historial — L4-11B/B04, 11/11/2026

- [x] ~~B04 — reproducción/recuperación y limpieza de Kubernetes aislado.~~
  Perfil nuevo, reinicio frío, servicios/seguridad/targets y limpieza total,
  dos ciclos; [handoff B04](handoffs/HANDOFF_L4_11B_B04_REPRODUCCION_2026-11-11.md).
- [ ] B04 global — reproducción Jenkins/plugins/jobs/credenciales y retiro de
  infraestructura heredada; límite ligado a B02/B05, sin borrar compartidos.
- [ ] Siguiente B08 — coherencia de guías, GPT-6.1 Sol/esfuerzo medio.

Sin publicación/informe ni modificación del principal. Evidencias locales.
Podés cerrar este chat con los resultados y límites guardados.
