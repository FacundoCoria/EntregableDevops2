# Handoff maestro — Entregable 3 DevSecOps

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

**L4-11 completa como revisión documental, 11/11/2026; entrega parcial.**
Consigna de cinco páginas contrastada con archivos/resultados L4-01 a L4-10.
Evidencias íntegras: 33 artefactos Jenkins, 6 scripts/guía y 77 archivos del
snapshot; 531 archivos de repo/Word/consigna preservados. Brechas: análisis de
imagen publicada, alcance Docker/no root, configuración Helm y reproducción/
limpieza total, entrega Git e informe. Sin controles nuevos, implementación,
publicación ni escritura del informe. [Handoff L4-11](handoffs/HANDOFF_L4_11_REVISION_INTEGRAL_2026-11-11.md).
Siguiente recomendado: **L4-11B — cierre de brechas técnicas**, Sol/esfuerzo alto;
L4-12 queda para redacción con alcance propio. Podés cerrar este chat.

## Antecedentes hasta L4-10 (prevalece el cierre L4-11 anterior)

**L4-10 completa localmente, 11/11:** scripts Bash de inicio, tráfico, acceso y
limpieza con guía; inicio/seguridad PASS, 20 pedidos correlacionados (+1 final),
ciclo temporal con retención de tres PVC, reinstalación y purga PASS. Túneles
finales comprobados cerrados; 211 reportes/Word previos intactos. Sin GitHub ni
informe final. [Handoff L4-10](handoffs/HANDOFF_L4_10_SCRIPTS_2026-11-11.md). Siguiente L4-11, Sol/esfuerzo alto.
Límites: entorno existente; retiro de seguridad solo planificado, no ejecutado.

## Antecedentes L4-09 (prevalece el cierre L4-10 anterior)

**L4-09 completa localmente, 11/11:** Jenkins #7 SUCCESS (97 s), seis etapas
comprobadas; Semgrep 0 hallazgos, Snyk 0 críticos/1 alto/8 medios/1 bajo, Maven
1 prueba sin fallos, imagen publicada Docker Hub y Helm revisión 8 con API UP y
3 Pods Ready. Bloqueo real previo por siete críticos conservado (#3). Fuente Git
local aislada 0f47780: publicación del código/reportes en GitHub pendiente.
[Handoff de cierre](handoffs/HANDOFF_L4_09_CIERRE_JENKINS_2026-11-11.md). Siguiente L4-10 — scripts/guía, Sol/esfuerzo medio.

## Antecedentes L4-09 (prevalece el cierre anterior)

**L4-09 #6 y recuperación, 11/11:** publicación Docker completada, scan sin
críticos. #6 falló en Helm por intento de patch de roles del clúster. Corrección
probada sin ampliar permisos: release l4 revisión 7 deployed, API UP/métricas,
roles idénticos. Recuperación por comandos, no SUCCESS del job. Fuente local
0f47780 lista; falta Bruno repetir Build with Parameters y éxito integral.
[Continuidad](handoffs/HANDOFF_L4_09_CONTINUACION_2026-11-11.md).

**L4-09 builds #4/#5, 11/11:** #4 falló por parámetro inicial ausente; #5
pasó Semgrep/Snyk/Maven, gate PASS: 0 críticos, 1 alto, 8 medios, 1 bajo. Imagen
construida y login/upload parcial Docker; Bruno canceló durante push. Sin digest
final, Helm omitido: etapa sigue parcial. Corrección de progreso visible/defaults
preparada, pendiente próxima ejecución. [Continuidad](handoffs/HANDOFF_L4_09_CONTINUACION_2026-11-11.md).

**L4-09 continuación, 11/11:** pipeline final preparado; correcciones candidatas
Tomcat 11.0.27/Jackson 3.1.8 con Maven SUCCESS (1 prueba) y Semgrep 0 hallazgos
por comandos en Jenkins. Acceso limitado a Minikube instalado; Helm lint/dry-run
PASS. Snyk posterior y ejecución del job final todavía pendientes. Destino elegido
`brunovitola/pedidos-api-l4`; Bruno debe confirmar creación/guardar credencial.
Fuente Git local aislada 470c74d; sin publicación GitHub ni Word. [Continuidad](handoffs/HANDOFF_L4_09_CONTINUACION_2026-11-11.md).

Actualizado: 11 de noviembre de 2026, Uruguay.

## Propósito y forma de uso

Este es el handoff principal del proyecto: conserva qué está realizado, qué contenido ya puede incorporarse al informe y qué falta para completar la entrega. Recoge la revisión comunicada a Bruno y permite continuar en esta conversación o en otra.

El [mapa de consigna y evidencias](MAPA_CONSIGNA_EVIDENCIAS.md) sigue siendo el índice de análisis, archivos, ramas y ubicaciones por apartado. Este maestro organiza el estado y las tareas; no sustituye las evidencias originales ni constituye el informe final.

Las reglas de actualización están en [AGENTS.md](AGENTS.md). Para trabajos posteriores se podrán crear handoffs específicos en `handoffs/` y enlazarlos aquí. Al resolver un pendiente, marcarlo `[x]`, tachar su texto y registrar fecha y evidencia. Mantener abiertos los pendientes que solo tengan avance parcial.

## Estado general

Estado vigente: **L4-11B parcial; B01/B03 completas, B04 Kubernetes verificada con límite global Jenkins; B02 literal parcial**, según resumen inicial. L4-11 conserva su cierre documental. El cierre L4-10 es antecedente. Los
estados L4-09 «en curso» que siguen son antecedentes conservados.

**L4-09 en curso, 11/11:** Bruno opera Jenkins guiado; trabajo
`L4-09-pedidos-api`, diagnóstico #1 SUCCESS (herramientas, clonación y Docker).
Herramientas instaladas/versionadas en l4-tools; Bruno confirmó credencial
Snyk, acceso aún no probado. Gate Python: seis pruebas locales PASS;
pendiente ejecución de seguridad en Jenkins y pipeline final.
Actualización: build #2 ejecutado, Snyk exit 2/-13 sin JSON; gate detuvo por
error técnico, no por críticos. Diagnóstico en curso, sin reanálisis exitoso.
Diagnóstico autorizado posterior: `spawn ./mvnw EACCES` localizado; permiso
ejecutable corregido en pipeline y wrapper probado, exit 0. Falta actualizar
script en UI y repetir Jenkins con credencial para confirmar scan/gate.
**Estado vigente build #3:** acceso Snyk y scan completados, 7 críticas/11 altas/
24 medias/2 bajas; gate BLOCKED_CRITICAL y continuación omitida. FAILURE
esperado, evidencias security-3 guardadas. L4-09 parcial: seis etapas y éxito
integral pendientes, críticos sin remediar.
Main observado en Jenkins `ee6bc93` («Conexion ucu»), sin integrar en local.
No acredita CI/CD completo. [Continuidad L4-09](handoffs/HANDOFF_L4_09_JENKINS_2026-11-11.md).


**L4-08 completa localmente, 11/11:** Falco 0.45.2/chart 9.2.2 instalado
en Minikube con modern eBPF; una alerta Warning `Read sensitive file untrusted`
correlacionada con `cat /etc/shadow` sobre fixture ficticio, UID 10001, sin shell.
Control sin esa alerta; Pod/ConfigMap retirados. 60 reportes previos intactos;
servicios y Kyverno saludables. [Handoff L4-08](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md),
[log](EntregableDevops2/reports/falco-event.log) y
[explicación](EntregableDevops2/reports/falco-event.md). Sin commit/publicación
ni Word. Siguiente **L4-09 — Jenkins, GPT-6.1 Sol, esfuerzo alto**.

**Antecedente L4-07 (continuado por L4-08):**

**L4-07 completa localmente, 11/11:** Kyverno v1.20.0-rc.4 (chart 3.10.0-rc.4)
instalado en Minikube; cuatro ValidatingPolicy CEL Ready/Deny para laboratorio4.
16/16 pruebas de admisión, cuatro rechazos con create real y Pod conforme
Succeeded como UID 10001, luego retirado. Chart L4 admitido y tres servicios
saludables; 34 reportes previos intactos. Versión candidata/una réplica, límites
explícitos; antecedentes ClusterPolicy E3 conservados. [handoff L4-07](handoffs/HANDOFF_L4_07_KYVERNO_2026-11-11.md) y
[log](EntregableDevops2/reports/kyverno-validation.log). Sin commit/publicación ni
Word. Siguiente **L4-08 — Falco, GPT-6.1 Sol, esfuerzo alto**.

**Antecedente L4-06 (continuado por L4-07):**

**L4-06 completa localmente, 11/11:** Snyk 1.1308.4 sobre Maven, 130
dependencias incluyendo test; 44 IDs/rutas (7 CRITICAL, 11 HIGH, 24 MEDIUM,
2 LOW), exit 1 por hallazgos. Siete críticos documentados con propuestas;
sin correcciones aplicadas. 35 reportes previos intactos, POM/Java iguales a HEAD.
[Reporte](EntregableDevops2/reports/snyk-report.txt) y [handoff](handoffs/HANDOFF_L4_06_SNYK_2026-11-10.md).
Sin commit/publicación ni Word. Siguiente **L4-07 — Kyverno, Sol/alto**.

**Antecedente de preparación L4-06 del 10/11 (resuelto el 11/11):**


**L4-06 en curso, 10/11:** Snyk 1.1308.4 descargado y SHA256 oficial
verificado; Maven 3.9.16/Java 21.0.12.1 y resolución de dependencias exitosos.
Falta autenticar Snyk con participación de Bruno; **análisis Snyk aún no ejecutado**.
No hay resultado de vulnerabilidades Snyk ni reporte final. 35 reportes previos
intactos. [Continuidad L4-06](handoffs/HANDOFF_L4_06_SNYK_2026-11-10.md). Sin cambios de dependencias,
commit, publicación ni Word. L4-05 completa permanece como antecedente.


**L4-05 completa localmente, 10/11:** Semgrep 1.184.0, dos reglas Java oficiales
identificadas (CWE-78/CWE-89), ocho archivos de producción, cero hallazgos/errores,
exit 0; pruebas de reglas 2/2 aprobadas. Excluido src/test/java por defecto.
[Reporte](EntregableDevops2/reports/semgrep-report.txt) y
[handoff](handoffs/HANDOFF_L4_05_SEMGREP_2026-11-10.md). Reportes anteriores intactos;
sin cambios Java, commit, publicación ni Word. Once HIGH/CRITICAL L4-02 abiertos.
Siguiente **L4-06 — Snyk sobre Maven, GPT-6.1 Sol, esfuerzo alto**.

**Antecedente L4-04 (L4-05 desarrollada después):**

**L4-04 completa localmente, 10/11:** release l4 revisión 4, chart 0.2.1.
Scrapes API/kubelet UP, datasource OK y seis paneles comprobados por consulta y
confirmados visualmente por Bruno. Dashboard exportado; 17 pedidos correlacionados
con contador 17. Caída posterior al primer PASS por límite Grafana 256 MiB corregida
a request 512 MiB/limit 1 GiB: 360 consultas en cinco minutos, cero reinicios.
[Handoff](handoffs/HANDOFF_L4_04_OBSERVABILIDAD_2026-11-10.md). 26 reportes previos
intactos, once HIGH/CRITICAL abiertos. Todo local sin commit/publicación ni Word.
Siguiente **L4-05 — Semgrep, GPT-6.1 Sol, esfuerzo medio**.

**Antecedente L4-03 (L4-04 desarrollada después):**

**L4-03 completa localmente, 10/11:** chart Helm validado e instalado como release `l4`, revisión 2, namespace `laboratorio4` en Minikube. Tres pods Ready, tres PVC Bound, acceso HTTP a API/Prometheus/Grafana y persistencia H2 tras recrear pod comprobados. Valores dev efectivos y once recursos aceptados por servidor; [handoff](handoffs/HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md). Instalación previa en default conservada. Sin commit/publicación ni cambios Word; once HIGH/CRITICAL L4-02 siguen abiertos. Siguiente **L4-04, Sol/alto**.

**L4-02 completa localmente, 10/11:** Dive Windows 0.13.1 y Trivy 0.76.1 sobre la misma imagen de L4-01, identificada por índice/manifiesto/configuración OCI. Ocho capas, 150,57 MB almacenados, 346,86 MB de contenido Dive, eficiencia 98,67 %. Trivy: 52 hallazgos (4 CRITICAL, 7 HIGH, 25 MEDIUM, 16 LOW), 41 identificadores; once prioritarios documentados con propuestas, **sin corrección aplicada**. [Reporte](EntregableDevops2/reports/image-analysis.md) y [handoff](handoffs/HANDOFF_L4_02_DIVE_TRIVY_2026-11-10.md). Trece reportes históricos intactos; sin commit/publicación ni cambios Word. Siguiente L4-03, Sol/alto.

**L4-01 completa localmente, 10/11:** rama `lab4/l4-01-docker-manifiestos` preparada desde origin/main `489f9f3`, reportes históricos intactos (13 huellas iguales). Docker multi-stage construido: una prueba Maven sin fallos; API no root, salud/métricas y persistencia H2 después de recrear contenedor comprobadas. Once recursos renderizados y válidos contra esquemas Kubernetes; sin despliegue al clúster. Cambios sin commit ni publicación. [Handoff L4-01](handoffs/HANDOFF_L4_01_DOCKER_MANIFIESTOS_2026-11-10.md). Continuación prevista entonces: L4-02, completada después según el estado vigente anterior. Nueva preferencia: Bruno opera interfaces guiado paso a paso; el agente realiza archivos/comandos/verificaciones. Registrada en AGENTS.md. Los diagnósticos anteriores sobre la copia local atrasada describen el estado previo a esta etapa.

**Prioridad vigente del 10 de noviembre de 2026:** por indicación expresa de Bruno, **Entregable 3 en pausa y Laboratorio 4 como trabajo prioritario**. El nuevo [Laboratorio 4.pdf](Laboratorio%204.pdf) es el integrador final. Se completó su lectura y el cruce requisito por requisito con GitHub, las cuatro ramas disponibles y las evidencias locales previas. Continuar por [MAPA_LABORATORIO_4_EVIDENCIAS.md](MAPA_LABORATORIO_4_EVIDENCIAS.md) y [handoff de transición](handoffs/HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md). Los pendientes E3 se conservan; las propuestas de retomar E3 de las secciones anteriores quedan pausadas, no resueltas.

**Novedad remota del 10 de noviembre:** main `489f9f37a2275a5e284769fdbb511c0855c1c384`, «evento falco», publica `pedidos-api/pedidos-api/reports/falco-event.txt` y actualiza el Pod de prueba. El log acredita arranque Falco y alertas, incluida shell en falco-test y ejecución de plugins Grafana fuera de la imagen base. La ausencia de evento informada el 9/11 es histórica. Formato `.log`, comandos/correlación e interpretación todavía por completar; para L4 la prueba debe ser una acción distinta de abrir shell. Los eventos Grafana existen, pero la acción deliberada de prueba no está documentada. No se modificaron los Word ni se ejecutaron controles.

### Etapa de transición a Laboratorio 4

- [x] ~~L4-08 — Falco: acción no shell, correlación, log y explicación.~~ **11/11:** prueba real PASS y limpieza; [handoff L4-08](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md).

- [x] ~~L4-07 — Kyverno: cuarta política, instalación y validación por política.~~ **11/11:** cuatro reglas CEL, 16/16 pruebas y creates reales; [handoff L4-07](handoffs/HANDOFF_L4_07_KYVERNO_2026-11-11.md).

- [x] ~~L4-05 — Semgrep, reglas Java y reporte.~~ **10/11:** dos reglas, ocho fuentes, cero hallazgos/errores; pruebas 2/2. [Handoff](handoffs/HANDOFF_L4_05_SEMGREP_2026-11-10.md).

- [x] ~~Ejecutar L4-02: Dive, Trivy y reporte de imagen.~~ **10/11:** análisis reales completados; [handoff](handoffs/HANDOFF_L4_02_DIVE_TRIVY_2026-11-10.md) y [reporte](EntregableDevops2/reports/image-analysis.md). Los once HIGH/CRITICAL siguen abiertos.
- [ ] Remediar vulnerabilidades L4-02 tras revisar compatibilidad de BOM/base, probar y reescanear una nueva imagen; [diagnóstico](handoffs/HANDOFF_L4_02_DIVE_TRIVY_2026-11-10.md). Pendiente nuevo separado del análisis concluido; no acredita corrección por documentarla.
- [x] ~~L4-03, Helm/configuración/instalación/acceso.~~ **10/11:** instalación y pruebas reales exitosas; [handoff](handoffs/HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md).
- [x] ~~L4-04, observabilidad y dashboard.~~ **10/11:** seis paneles comprobados y confirmados visualmente; OOM Grafana corregido, revisión 4 y prueba posterior sin reinicios. [Handoff](handoffs/HANDOFF_L4_04_OBSERVABILIDAD_2026-11-10.md).

- [x] ~~Implementar y verificar L4-01: Docker y manifiestos.~~ **10/11:** construcción y pruebas locales exitosas, H2 persistente comprobada, 11 recursos válidos; [handoff](handoffs/HANDOFF_L4_01_DOCKER_MANIFIESTOS_2026-11-10.md). Sin instalación en clúster ni publicación.

- [x] ~~Localizar y resumir la nueva consigna.~~ **10/11:** PDF de cinco páginas leído completo.
- [x] ~~Revisar GitHub y asociar cada requisito con avances, evidencia y faltantes.~~ **10/11:** main y tres ramas adicionales revisados; matriz detallada y copias verificadas en el [handoff de diagnóstico](handoffs/HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md).
- [x] ~~Registrar como prioridad Laboratorio 4 y pausar Entregable 3.~~ **10/11:** maestro, AGENTS y ambos mapas sincronizados por solicitud de Bruno.
- [x] ~~Acordar la siguiente etapa concreta de implementación del integrador a partir del mapa.~~ **10/11, continuación:** Bruno acepta Docker/manifiestos; antes de implementar solicita organizar conversaciones y recomendar modelo/esfuerzo. Creado [plan de etapas](PLAN_TRABAJO_LABORATORIO_4.md): siguiente inicial L4-01, GPT-6.1 Sol/alto; implementación entonces pendiente, completada posteriormente según el cierre vigente de esta etapa. Al cerrar cada etapa, informar siguiente tarea/modelo/esfuerzo y posibilidad de cerrar el chat, con handoff guardado.

Los estados con fecha 9/11 y anteriores que siguen se conservan como antecedentes del Entregable 3; consultar las novedades anteriores antes de usar sus frases de ausencia de Falco o su orden de continuidad.

**Escritura vigente del 9 de noviembre de 2026:** Bruno autorizó crear un nuevo Word usando el borrador como punto de partida. Completado `Entregable 3 - Informe redactado.docx`: ocho páginas en formato académico, cuatro apartados, conclusiones y referencias; todas revisadas visualmente en Word. Incorpora el Pod Falco y el ajuste booleano Kyverno de la revisión previa, sin inventar detección ni nuevas pruebas. El borrador `Entregable 3 - Informe.docx` se conserva intacto como antecedente. Véase [redacción académica del 9 de noviembre](handoffs/HANDOFF_REDACCION_ACADEMICA_INFORME_2026-11-09.md). La redacción disponible está completa; Falco, npm audit, datos de presentación, revisión con Bruno y consolidación siguen pendientes.

**Actualización vigente del 9 de noviembre de 2026:** revisión remota realizada en esta conversación: main `2310ac5fa1ab2a51387e02a72b848b64e0ddbbde`, commit de Facundo del 8 de noviembre, «Analisis con falco». Añade `pedidos-api/pedidos-api/k8s/tests/falco-test.yaml` y ajusta la comparación booleana de `runAsNonRoot` en `k8s/kyverno-policies.yaml`. El evento `reports/falco-event.log` sigue **no localizado en lo revisado**; el manifiesto no acredita ejecución ni detección. El Word anterior conserva el estado del 3 de noviembre; la nueva versión académica del 9 de noviembre es la indicada arriba. Véase [plan de cierre y revisión](handoffs/HANDOFF_PLAN_CIERRE_INFORME_2026-11-09.md).

**Orden propuesto por Bruno para continuar:** empezar por la escritura y revisión de lo ya respaldado; Bruno consultará al compañero si existe el resultado de Falco, para incorporarlo después y cerrar esa parte. La lista conserva el orden de la propuesta original, pero no obliga a esperar Falco para avanzar con la escritura disponible. Esa sesión de planificación solo registró pendientes. La escritura fue autorizada posteriormente y se completó el 9 de noviembre en el archivo nuevo, sin ejecutar controles.

| Contenido | Estado técnico y de evidencia | Preparación para el Word |
|---|---|---|
| Introducción, objetivo y alcance | Consigna y contexto disponibles | Redacción académica del 9 de noviembre completa; datos de presentación pendientes |
| Parte 1: código | Siete alertas corregidas en remoto; Semgrep posterior: 0 hallazgos. npm audit sigue fallido | Redacción académica del 9 de noviembre: correcciones, comparación 7 → 0 y límites; npm audit pendiente |
| Parte 2: imagen | Trivy ejecutado dos veces; nueve HIGH/CRITICAL documentados y abiertos | Redacción académica del 9 de noviembre: metodología, nueve hallazgos, tratamiento y repetición |
| Parte 3: Kubernetes | Pruebas del compañero aceptadas por Bruno; revisión cerrada. Ajuste booleano publicado sin prueba posterior acreditada | Redacción académica del 9 de noviembre: políticas, rechazos, KubeLinter, confirmación atribuida y ajuste booleano, con límites |
| Parte 4: ejecución | Actualización 10/11: arranque y alertas Falco publicados en `.txt`; correlación/formato/explicación por completar | El Word del 9/11 conserva el estado anterior; actualización pendiente y E3 pausado |
| Conclusión general | Describe el estado parcial y los controles pendientes | Actualizada el 9 de noviembre; no declara cierre total |

**Antecedente del informe conservado:** `Entregable 3 - Informe.docx` actualizado por solicitud expresa de Bruno el **3 de noviembre de 2026**. Incorpora correcciones Semgrep y comparación 7 → 0; políticas, rechazos y seis hallazgos KubeLinter; aceptación de las pruebas del compañero atribuida a Bruno, con límites conservados. Actualizados alcance, procedencia de imagen, referencias y conclusión. Revisadas visualmente las once páginas en Word; original guardado y verificado. Véase [actualización del informe](handoffs/HANDOFF_ACTUALIZACION_INFORME_2026-11-03.md). Siguen pendientes Falco, tratamiento npm audit y consolidación final; la escritura no los completa. El primer borrador del 2 de noviembre se conserva en su [handoff histórico](handoffs/HANDOFF_PRIMER_BORRADOR_INFORME_2026-11-02.md).

**Pendiente editorial del 3 de noviembre resuelto en la nueva versión:** el 9 de noviembre se reformuló el contenido como informe académico, sin resaltados ni notas de coordinación. El borrador histórico conserva su formato anterior. Faltan los datos de presentación y el cierre con las evidencias todavía pendientes; véase [redacción académica del 9 de noviembre](handoffs/HANDOFF_REDACCION_ACADEMICA_INFORME_2026-11-09.md).

**Preparación desarrollada:** el 2 de noviembre se creó [HANDOFF_ARMADO.md](handoffs/HANDOFF_ARMADO.md), a pedido de Bruno, como paso intermedio previo a redactar. Desarrolla qué explicar por apartado, los resultados y evidencias disponibles, las siete alertas de Semgrep, los nueve hallazgos prioritarios de Trivy y la información faltante para Kubernetes y Falco. La lista está desarrollada; los controles pendientes siguen abiertos. No se modificó el Word.

**Revisión vigente del 3 de noviembre:** se consultó GitHub en vivo y se comparó el nuevo main con la base local. Las correcciones de Semgrep y las incorporaciones Kyverno/KubeLinter ya están integradas en el main remoto, pero no en la copia de trabajo local. Ver [handoff de revisión](handoffs/HANDOFF_REVISION_REPO_2026-11-03.md). El Word incorporó estos resultados en la actualización autorizada del 3 de noviembre, enlazada arriba. Los límites de consulta remota de las preparaciones anteriores son históricos.

**Decisión final y continuidad vigente:** [cierre de etapa](handoffs/HANDOFF_CIERRE_ETAPA_CONTINUIDAD_2026-11-03.md). Bruno comunica que su compañero corrigió Semgrep, aplicó Kyverno y realizó las pruebas; Falco le queda pendiente. No hay registros adicionales disponibles. Bruno acepta esas pruebas e indica que no es necesario validar nuevamente en su entorno. Se cierra la búsqueda y la propuesta de repetición/ampliación de Kubernetes; los límites documentales se conservan sin declararlos resueltos. Retomar por Falco, tratamiento npm audit, consolidación de entrega. La actualización del Word ya se completó el 3 de noviembre; ver el estado vigente arriba. Esta decisión reemplaza los próximos pasos de recuperación/revalidación indicados en los handoffs anteriores.

## Fuentes y ubicación del trabajo

**Primer paso de Kubernetes completado el 3 de noviembre:** se revisaron las políticas, los dos Pods, rechazos y reporte KubeLinter; se precisó la hipótesis de tipos sin confirmar su causa y se preparó el paquete de evidencia faltante. Ver [handoff específico de revisión YAML](handoffs/HANDOFF_PARTE_3_REVISION_YAML_2026-11-03.md). Siguiente paso: recuperar entorno, políticas efectivas, comandos y salidas originales; decidir nuevas pruebas después si hacen falta. No se ejecutaron controles ni se modificó el Word.

**Continuación del mismo día, búsqueda de registros:** se revisaron archivos disponibles, README, los dos commits de Kyverno y PR #2 con sus comentarios/revisiones; ramas reconsultadas sin cambios. La anomalía ya existe en el primer commit y el siguiente solo añade KubeLinter. Los comandos, versiones de entorno y aceptación conforme siguen sin localizarse. [Handoff de recuperación](handoffs/HANDOFF_PARTE_3_RECUPERACION_REGISTROS_2026-11-03.md) con respuestas API conservadas y solicitud preparada para el autor, no enviada. Próximo paso: obtener esos datos de quien realizó las pruebas o decidir una nueva etapa de ejecución; no repetir la búsqueda sobre las mismas fuentes.

Los dos párrafos anteriores conservan el avance histórico. Su propuesta de recuperar registros o realizar pruebas quedó **retirada del seguimiento activo por la decisión final de Bruno** enlazada arriba; no volver a solicitarla para continuar.

- Consigna original: [Entregable 3 DevSecOps(1).docx](Entregable%203%20DevSecOps%281%29.docx).
- Informe académico vigente: [Entregable 3 - Informe redactado.docx](Entregable%203%20-%20Informe%20redactado.docx).
- Borrador anterior conservado: [Entregable 3 - Informe.docx](Entregable%203%20-%20Informe.docx).
- Índice de evidencias: [MAPA_CONSIGNA_EVIDENCIAS.md](MAPA_CONSIGNA_EVIDENCIAS.md).
- Contexto e historia: [CONTEXTO_PROYECTO.md](CONTEXTO_PROYECTO.md). Sus notas iniciales son históricas; consultar las actualizaciones y el mapa antes de concluir que algo falta.
- Procedimiento y repetición de Trivy: [REGISTRO_TRIVY.md](REGISTRO_TRIVY.md).
- Repositorio local: `EntregableDevops2/`; aplicación: `EntregableDevops2/pedidos-api/pedidos-api/`.
- Remoto: [FacundoCoria/EntregableDevops2](https://github.com/FacundoCoria/EntregableDevops2).
- Base local revisada: rama `main`, commit `695072de8a64a0770de2af3346d85cfaae397922`.
- Main remoto revisado el 3 de noviembre: `37a452e7e45a03832c90bca9d65285bda14f0b34`. Ramas `semgrep` (`4e559bc`) y `kyverno` (`453e049`) integradas. Copias verificables fuera del repositorio: [evidencias de revisión](handoffs/evidencias_revision_2026-11-03/).
- Reportes remotos del apartado 1: rama `semgrep`, commit previamente verificado `d7e8c3d2e27a07193f966aec0f33816c5e4e9f4c`.
- Hay dos ubicaciones de reportes: los del compañero están en `pedidos-api/pedidos-api/reports/` en esa rama; los de Trivy están en `EntregableDevops2/reports/` localmente. No están unificados.

## 1. Introducción, objetivo y alcance

### Ya se puede registrar

- Se trabaja sobre la API de pedidos del entregable anterior, desarrollada con Java/Maven y Spring Boot.
- El objetivo es evaluar cuatro capas: código, imagen Docker, Kubernetes y ejecución.
- Cada capa tiene herramientas y evidencias exigidas por la consigna.
- Detectar un problema, documentarlo y corregirlo son resultados distintos.
- El material disponible respalda análisis estático inicial y posterior, análisis de imagen y evidencia documental parcial de Kubernetes. Todavía no respalda presentar como completos todos los controles de Kubernetes ni la detección en ejecución.

### Pendientes

- [ ] Completar datos de presentación que se decida incluir: integrantes, materia, docente y fecha de entrega.
- [x] ~~Redactar la introducción y el alcance en el Word cuando Bruno lo solicite.~~ **2 de noviembre de 2026:** primer borrador escrito por solicitud de Bruno; ver [handoff de redacción](handoffs/HANDOFF_PRIMER_BORRADOR_INFORME_2026-11-02.md). Pendiente su revisión.

## 2. Parte 1 de la consigna — Seguridad en el código

### Ya se puede registrar

Diagnóstico inicial conservado, complementado por la revisión remota del 3 de noviembre:

- Existen `semgrep.txt` y `npm-audit.txt` en la rama `semgrep`.
- Semgrep terminó correctamente: 208 reglas, 37 archivos analizados y siete hallazgos.
- El reporte informa archivos omitidos por tamaño y patrones de exclusión; no acredita cobertura total del repositorio.
- Los siete hallazgos se distribuyen así:

| Archivo relativo a la raíz de la aplicación | Hallazgos |
|---|---|
| `Dockerfile` | Falta una instrucción `USER` explícita |
| `k8s/deployment.yaml` | No exige `runAsNonRoot`; falta `allowPrivilegeEscalation: false` |
| `monitoring/grafana/grafana-deployment.yaml` | Los mismos dos problemas |
| `monitoring/prometheus/prometheus-deployment.yaml` | Los mismos dos problemas |

- `blocking` es una etiqueta del reporte de Semgrep: no equivale a HIGH/CRITICAL de Trivy ni demuestra un bloqueo real del despliegue.
- `npm-audit.txt` registra `ENOLOCK` por falta de archivo de bloqueo. Acredita un intento fallido, no una auditoría completada ni ausencia de vulnerabilidades.
- La aplicación identificada es Java/Maven; no se encontraron `package.json` ni `package-lock.json` en la revisión local. Esto permite explicar la dificultad de aplicar npm audit, pero no constituye por sí solo una justificación aceptada del requisito.
- El commit remoto revisado agrega los dos reportes; no incluye cambios que resuelvan las alertas.

La frase anterior describe el commit inicial `d7e8c3d`. Los commits posteriores `f8db1f8` y `4e559bc`, ya integrados en main, agregan usuario explícito en Dockerfile y contextos de seguridad en los tres Deployments. `reports/semgrepFixed.txt` registra una nueva ejecución exitosa: 208 reglas, 37 archivos, cero hallazgos y exclusiones por tamaño/patrones. Se conservan ambos diagnósticos; cero hallazgos corresponde al alcance de esa ejecución, no a ausencia general de vulnerabilidades. npm audit mantiene ENOLOCK.

### Pendientes

- [x] ~~Verificar si hay cambios remotos posteriores y localizar correcciones o justificaciones de las siete alertas.~~ **3 de noviembre:** correcciones y reporte posterior publicados; ver [revisión](handoffs/HANDOFF_REVISION_REPO_2026-11-03.md#1-código).
- [x] ~~Registrar una corrección o justificación concreta para cada alerta relevante que se mantenga.~~ **3 de noviembre:** siete alertas tratadas en Dockerfile y tres Deployments; correspondencia detallada en el handoff.
- [ ] Definir y documentar el tratamiento del requisito de npm audit en esta aplicación Java/Maven; no crear archivos npm solo para simular una auditoría.
- [ ] Confirmar si el compañero realizó otro análisis de dependencias y obtener su nombre, comando, alcance y evidencia, si existe. No asumir que Semgrep o el error de npm lo demuestran.
- [x] ~~Si se corrigen alertas, guardar una nueva ejecución que permita comprobar el resultado y conservar el diagnóstico inicial.~~ **3 de noviembre:** `semgrepFixed.txt` registra 0 frente a los 7 de `semgrep.txt`; ambos publicados y copiados como evidencia, sin repetir el análisis.
- [x] ~~Actualizar el apartado 1 del Word y su conclusión con las correcciones y la comparación 7 → 0 cuando Bruno solicite escritura; documentar también los límites de trazabilidad del reporte posterior.~~ **3 de noviembre de 2026:** contenido incorporado y revisado; ver [actualización del informe](handoffs/HANDOFF_ACTUALIZACION_INFORME_2026-11-03.md). npm audit sigue pendiente.
- [x] ~~Redactar esta parte del informe con sus límites y decisiones cuando Bruno lo solicite.~~ **2 de noviembre de 2026:** primer borrador del apartado 1 escrito con siete alertas, error ENOLOCK, límites metodológicos y decisiones todavía pendientes; no se cerró el apartado técnico.

## 3. Parte 2 de la consigna — Seguridad en la imagen

### Trabajo realizado y contenido listo para registrar

- Fecha de las pruebas: 1 de noviembre de 2026.
- Imagen original: `pedidos-api:trivy-20261101`; analizador: Trivy 0.76.1.
- Se conserva la identificación del código, imágenes, JAR y bases de vulnerabilidades utilizadas.
- Procedimiento documentado: comprobar Docker, compilar y probar Java, construir la imagen, obtener Trivy, exportar la imagen, analizar el TAR, guardar JSON, convertirlo a texto y revisar los hallazgos.
- La compilación completada ejecutó una prueba, con cero fallos y cero errores. No se omitieron las pruebas; el primer intento había fallado al descargar una dependencia por permisos.
- Se guardaron el reporte solicitado, datos originales y registros complementarios.

| Gravedad | Hallazgos |
|---|---:|
| CRITICAL | 4 |
| HIGH | 5 |
| MEDIUM | 55 |
| LOW | 4 |
| **Total** | **68** |

Los totales cuentan hallazgos por paquete y vulnerabilidad; no equivalen necesariamente a 68 CVE distintas. Hay 57 hallazgos del sistema Ubuntu y 11 en bibliotecas Java; el binario Go analizado no registra hallazgos.

| Dependencia | Versión registrada | Hallazgos prioritarios |
|---|---|---|
| `tomcat-embed-core` | 11.0.24 | 4 CRITICAL |
| `jackson-core` | 3.1.5 | 2 HIGH |
| `jackson-databind` | 3.1.5 | 3 HIGH |

- Los nueve prioritarios ya están documentados individualmente con identificador, dependencia, versión instalada, gravedad, impacto descrito y versión corregida indicada por Trivy.
- Se eligió documentarlos, alternativa permitida por la consigna. Siguen abiertos: no se actualizaron dependencias, no se agregaron exclusiones ni se declararon falsos positivos.
- **3 de noviembre:** el Dockerfile remoto añade USER no root. El reporte Trivy permanece referido a la imagen original; no se localizó un escaneo de una imagen reconstruida con el cambio. `pom.xml` no cambió. No trasladar automáticamente el análisis previo a la nueva imagen.
- El análisis no demuestra que la API haya sido atacada ni que se cumplan todas las condiciones de explotación. No hubo pruebas de explotación.
- Bruno repitió el procedimiento. Los resultados coincidieron y los dos reportes de texto tienen la misma huella SHA256, comprobada nuevamente el 2 de noviembre. Se analizó el mismo contenido de imagen, aunque se usaron etiquetas distintas; no presentarlo como dos imágenes de contenido diferente.

### Evidencias principales

- [Resultados y tratamiento de los nueve hallazgos](EntregableDevops2/reports/RESULTADOS-TRIVY.md).
- [Comandos y explicación del procedimiento](EntregableDevops2/reports/COMANDOS-TRIVY.md).
- [Reporte de texto original](EntregableDevops2/reports/trivyreport.txt) y [JSON original](EntregableDevops2/reports/trivyreport.json).
- [Reporte de la repetición](EntregableDevops2/reports/repeticion/trivyreport.txt) y [JSON de la repetición](EntregableDevops2/reports/repeticion/trivyreport.json).
- `docker-build.txt`, `prueba-maven.txt`, `trivy-ejecucion.txt`, `ejecucion.json`, `imagen-analizada.json`, `imagen-trivy.json` y `trivy-version.txt`, todos en `EntregableDevops2/reports/`.
- [Registro completo de la ejecución y repetición](REGISTRO_TRIVY.md). Las capturas compartidas en el chat no se copiaron al repositorio; la evidencia persistente son los reportes y registros.

### Pendientes

- [x] ~~Redactar esta parte en el Word cuando Bruno lo solicite: metodología, resultados, nueve hallazgos, tratamiento documental y repetición.~~ **2 de noviembre de 2026:** contenido incorporado al primer borrador; los nueve prioritarios continúan abiertos.
- [ ] Incorporar las evidencias locales al conjunto final de entrega. En la revisión, Git muestra `reports/` sin versionar; no se acreditó su publicación en GitHub.

**Criterio de cierre técnico:** la ejecución y documentación cubren la alternativa de documentar HIGH/CRITICAL prevista por la consigna. No hace falta corregirlos para presentar esa alternativa, pero tampoco afirmar que están resueltos.

**Mejora eventual, no requisito pendiente de esta alternativa:** si Bruno decide corregirlos, evaluar versiones compatibles, actualizar, compilar, probar la API, reconstruir y volver a analizar. Conservar los reportes actuales como diagnóstico inicial. Las versiones de corrección citadas en los resultados provienen del reporte y deben revisarse al actualizar.

## 4. Parte 3 de la consigna — Seguridad en Kubernetes

### Ya se puede registrar como contexto

- Existen manifiestos de la API en `k8s/` y de Grafana y Prometheus en `monitoring/`, dentro de la aplicación.
- En los tres Deployments locales antiguos faltan solicitudes/límites y contexto no root. En el main remoto del 3 de noviembre ya se exige ejecución no root; siguen faltando solicitudes/límites.
- Las imágenes de Grafana y Prometheus no tienen etiqueta explícita. Considerarlas al preparar la validación de imágenes.
- Las seis alertas de Semgrep sobre esos Deployments orientan el trabajo, pero no acreditan Kyverno ni KubeLinter.

### Evidencia localizada el 3 de noviembre y pendientes

`k8s/kyverno-policies.yaml` contiene las tres ClusterPolicy en Enforce, sobre containers e initContainers, con exclusiones `kyverno`, `falco` y `kube-system`. Los YAML de `k8s/tests/` guardan rechazos como comentarios: latest y no root en `latest.yaml`; recursos y no root en `resources.yaml`. Este último declara `runAsNonRoot: true`, por lo que su rechazo adicional requiere aclaración. `reports/kubelinter.txt` registra KubeLinter 0.8.3 y seis hallazgos identificados únicamente en esos dos Pods de prueba. Fuentes, interpretación y límites en el [handoff de revisión](handoffs/HANDOFF_REVISION_REPO_2026-11-03.md#3-kubernetes).

- [x] ~~Localizar o preparar la política Kyverno que prohíba imágenes con etiqueta `latest`.~~ **3 de noviembre:** `deny-latest-images` localizada y leída en el YAML publicado; imágenes sin etiqueta no probadas.
- [x] ~~Localizar o preparar la política que exija solicitudes y límites de recursos en todos los pods.~~ **3 de noviembre:** `require-container-resources` localizada; registrar las exclusiones, sin afirmar cobertura universal.
- [x] ~~Localizar o preparar la política que impida ejecutar contenedores como root.~~ **3 de noviembre:** `disallow-root-containers` localizada; correcto funcionamiento completo pendiente por la anomalía documentada.
- **Límite conservado; fuera del seguimiento activo por decisión de Bruno del 3 de noviembre:** el pendiente anterior «Registrar el clúster utilizado y la aplicación efectiva de las tres políticas» no se completó documentalmente. Aplicación y pruebas confirmadas por el compañero a través de Bruno; clúster no identificado. No se exige recuperar registros para continuar.
- [x] ~~Conservar el manifiesto no conforme utilizado para validarlas.~~ **3 de noviembre:** copias de `k8s/tests/latest.yaml` y `resources.yaml` en la carpeta de evidencias del handoff.
- **Límite conservado; fuera del seguimiento activo:** el pendiente anterior de demostrar los rechazos con trazabilidad completa conserva avance parcial: transcripciones con nombres de las tres políticas, sin aclaración del rechazo no root adicional ni entorno. Bruno acepta las pruebas realizadas por su compañero; no se repetirá la validación en su entorno.
- **Límite conservado; fuera del seguimiento activo:** del pendiente anterior de recuperar/ejecutar KubeLinter y acreditar alcance/comando se recuperó el reporte, con seis hallazgos en dos Pods de prueba. Comando y cobertura de API/monitoreo no acreditados; no se agenda ampliación o repetición para continuar.
- [x] ~~Guardar el resultado solicitado en `reports/kubelinter.txt` y explicar sus hallazgos.~~ **3 de noviembre:** publicado dentro de la aplicación y copiado fuera de la copia de trabajo; seis hallazgos interpretados en el handoff. No equivale a un análisis completo de todos los manifiestos.
- **Límite conservado; fuera del seguimiento activo:** la anomalía de `resources.yaml`, comparación de tipos y aceptación de un caso conforme no se verificaron. Bruno decidió aceptar las pruebas del compañero sin validación nueva; no marcar la anomalía como corregida ni el caso conforme como ejecutado.
- [x] ~~Revisar las políticas y los dos Pods conservados, contrastar los rechazos y precisar la evidencia que falta recuperar.~~ **3 de noviembre de 2026:** etapa documental solicitada por Bruno completada; [diagnóstico y lista de recuperación](handoffs/HANDOFF_PARTE_3_REVISION_YAML_2026-11-03.md). La consulta puede producir booleano true o cadena 'false', frente a valor textual "true"; hipótesis para investigar, sin causa ni corrección confirmadas. Incluye matriz futura de aceptación/rechazos, no ejecutada. Los pendientes técnicos anteriores siguen abiertos.
- [x] ~~Buscar comandos y registros originales en los archivos disponibles, documentación e historial público de Kubernetes.~~ **3 de noviembre de 2026:** búsqueda completada en README, commits eef912d/453e049 y PR #2; [fuentes y resultados](handoffs/HANDOFF_PARTE_3_RECUPERACION_REGISTROS_2026-11-03.md). Se recuperó trazabilidad de publicación, no los datos del clúster. No cierra los pendientes técnicos anteriores; solicitud para el autor preparada y sin enviar.
- [x] ~~Registrar la confirmación del compañero y la decisión de Bruno de cerrar esta revisión sin repetir pruebas ni buscar registros adicionales.~~ **3 de noviembre de 2026:** completado en [cierre y continuidad](handoffs/HANDOFF_CIERRE_ETAPA_CONTINUIDAD_2026-11-03.md). Los límites anteriores se conservan como tales, fuera del seguimiento activo; no se presentan como verificaciones exitosas. La solicitud al autor y matriz de nuevas pruebas quedan históricas, sin ejecutar.
- [x] ~~Actualizar esta parte del informe cuando Bruno solicite escritura, con políticas, rechazos y KubeLinter publicados y confirmación del compañero atribuida, conservando los límites.~~ **3 de noviembre de 2026:** políticas, pruebas, seis hallazgos KubeLinter, confirmación atribuida y límites incorporados al Word; ver [actualización del informe](handoffs/HANDOFF_ACTUALIZACION_INFORME_2026-11-03.md). Se conservó la aceptación sin repetición ni recuperación de registros.

Los rechazos publicados aportan evidencia documental; no se reprodujeron en vivo. Bruno confirma lo informado por su compañero y acepta el trabajo para avanzar. **Revisión de Kubernetes cerrada para esta etapa**, con límites de evidencia conservados. No declarar ausencia de pruebas ni convertir la aceptación de Bruno en acreditación independiente de todos los detalles. Los estados «siguen abiertos» de las entradas históricas anteriores describen el momento previo a esta decisión; ya no constituyen tareas activas de recuperación o revalidación.

## 5. Parte 4 de la consigna — Seguridad en tiempo de ejecución

**Estado vigente 10/11, E3 pausado:** evidencia publicada localizada y conservada en [falco-event.txt](handoffs/evidencias_laboratorio_4_2026-11-10/main/pedidos-api/pedidos-api/reports/falco-event.txt). Arranque Falco 0.45.2 y alerta identificada en falco-test; detalles y límites en el [diagnóstico L4](handoffs/HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md). Las afirmaciones de ausencia en los párrafos fechados anteriores se conservan como historia y quedan superadas por esta revisión.

### Ya se puede registrar

**9 de noviembre:** publicado el manifiesto `k8s/tests/falco-test.yaml` en main `2310ac5`; evento real no localizado en lo revisado. La confirmación del 3 de noviembre que sigue es histórica; no se concluye que la prueba siga sin realizarse, sino que falta su evidencia disponible.

La consigna exige instalar Falco o usar una instalación existente, realizar una acción sospechosa dentro de un pod, verificar el evento y guardar el log. Todavía no se localizó evidencia para describir esta prueba como ejecutada. **Confirmación comunicada por Bruno el 3 de noviembre:** a su compañero le falta Falco. Es el siguiente control por retomar; no se autoriza su ejecución por este registro.

### Pendientes

- [ ] Identificar el clúster y la instalación/configuración de Falco utilizada. **Avance 10/11:** log identifica minikube, kernel WSL2, Falco 0.45.2, configuración y modern eBPF. Falta el procedimiento reproducible de instalación.
- [x] ~~Conservar evidencia de que Falco estaba funcionando.~~ **10/11:** log publicado de inicialización y alertas, copiado y verificado contra GitHub; [handoff](handoffs/HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md). No es una ejecución independiente local.
- [ ] Identificar el pod, fecha y acción sospechosa realizada, por ejemplo una shell interactiva. **Avance 10/11:** log del 10/11, alerta 15:01:35 con falco-test/default/busybox:1.36/UID 1000 y shell. Falta comando original y zona horaria confirmada.
- [ ] Conservar el evento real detectado y relacionarlo con la acción. **Avance 10/11:** evento conservado y pod identificado; falta documentar comando/acción original. Para L4 la acción debe ser distinta de abrir shell.
- [ ] Guardar la evidencia solicitada en `reports/falco-event.log`.
- [ ] Explicar qué detectó la alerta y el resultado de la prueba.
- [ ] Redactar esta parte del informe cuando existan las evidencias y Bruno lo solicite. **Avance parcial del 2 de noviembre:** objetivo y prueba requerida ya escritos en el apartado 4; sigue faltando el evento real y su interpretación.

Semgrep y Trivy no sustituyen esta evidencia de detección en ejecución.

## 6. Organización y cierre de la entrega

### Plan de cierre registrado el 9 de noviembre de 2026

Lista conservada de la propuesta compartida con Bruno. El 9 de noviembre se completó la redacción académica disponible; los pasos compuestos siguen abiertos cuando faltan evidencias o datos. **10/11: este plan E3 queda pausado por prioridad de Laboratorio 4.**

- [ ] **Conseguir la evidencia de la parte 4.** Tu compañero publicó `falco-test.yaml`, pero en el `main` revisado no aparece `reports/falco-event.log`. Necesitamos el evento detectado y saber qué acción realizó dentro del pod. Si ya hizo la prueba, alcanza con recuperar y revisar esos resultados; no hace falta repetirla por ahora. **Avance 10/11:** encontrado y conservado `falco-event.txt` con eventos; siguen formato `.log`, comando/correlación y explicación. Paso compuesto parcial, pausado.

- [ ] **Definir el tratamiento de npm audit.** El reporte disponible contiene un error `ENOLOCK`; no acredita una auditoría completada. Como la aplicación es Java/Maven, debemos explicar esa situación y acordar cómo atender lo pedido por la consigna. No podemos presentarlo como un análisis sin vulnerabilidades.

- [ ] **Actualizar el informe con las novedades verificadas.** Incorporar Falco cuando esté su evidencia y el ajuste reciente de Kyverno. Para este último, podemos describir el cambio publicado, pero no afirmar que fue probado nuevamente sin resultados que lo respalden. Mantendríamos las pruebas anteriores de Kubernetes que ya aceptaste, sin reabrir esa revisión. **Avance del 9 de noviembre:** ajuste booleano y Pod Falco incorporados a la nueva versión académica; resta el evento Falco y su interpretación. Véase [redacción académica del 9 de noviembre](handoffs/HANDOFF_REDACCION_ACADEMICA_INFORME_2026-11-09.md).

- [ ] **Preparar la versión final del Word.** Revisar los resaltados amarillos, retirar las notas internas de coordinación, completar los datos de presentación y ajustar la conclusión al resultado final. Conservar la numeración: **1. Código; 2. Imagen; 3. Kubernetes; 4. Tiempo de ejecución**. **Avance del 9 de noviembre:** redacción académica disponible terminada, sin resaltados ni coordinación interna, numeración conservada y conclusión ajustada al estado real. Faltan los datos de presentación y actualización final tras Falco/npm audit; no se marca completo el paso compuesto.

- [ ] **Consolidar la entrega.** Comprobar que cada apartado tenga su evidencia accesible y que se incluyan los reportes locales de Trivy, cuya publicación aún no está acreditada. Los nueve hallazgos HIGH/CRITICAL ya están documentados: esa alternativa está permitida por la consigna y no exige corregirlos para cerrar el informe.

### Pendientes transversales

- [x] ~~Preparar la versión final académica del informe: revisar los resaltados amarillos y retirar o reformular notas internas, decisiones de seguimiento y tareas dirigidas al equipo. Conservar brevemente las limitaciones y requisitos no completados que afecten el cumplimiento, sin presentarlos como realizados.~~ **9 de noviembre de 2026:** adaptación editorial completada en el Word nuevo, con ocho páginas revisadas. Se cierra la redacción disponible, no los controles ni la entrega integral; ver [redacción académica del 9 de noviembre](handoffs/HANDOFF_REDACCION_ACADEMICA_INFORME_2026-11-09.md). **Antecedente del 3 de noviembre:** se había registrado el pendiente sin modificar el Word.
- [x] ~~Desarrollar la lista del maestro en una base de contenido por apartado antes de escribir el informe.~~ **2 de noviembre de 2026:** completado en [HANDOFF_ARMADO.md](handoffs/HANDOFF_ARMADO.md); contrastado con la consigna, el mapa y fuentes locales. Se diferenciaron contenido respaldado y fichas pendientes, sin ejecutar controles ni cerrar requisitos técnicos adicionales.
- [ ] Reunir los reportes remotos de código y los reportes locales de imagen, conservando su origen.
- [ ] Definir una ubicación consistente para los archivos exigidos en `/reports/` y actualizar las referencias sin perder los originales.
- [ ] Mantener separados los diagnósticos iniciales y los resultados posteriores a correcciones, si los hubiera.
- [ ] Vincular las afirmaciones del informe con sus evidencias y distinguir decisiones documentadas de cambios aplicados. **Avance parcial del 2 de noviembre:** primer borrador con referencias de archivos y enlaces históricos; falta consolidar las evidencias finales y actualizarlo al cerrar los controles.
- [x] ~~Redactar una conclusión que distinga lo ejecutado, documentado, corregido y pendiente; no afirmar cumplimiento de los cuatro apartados mientras falten evidencias.~~ **2 de noviembre de 2026:** conclusión del primer borrador escrita para el estado parcial actual; no afirma cumplimiento completo. Requiere actualización si aparecen evidencias nuevas.
- [ ] Revisar con Bruno el primer borrador del Word y aplicar sus sugerencias; actualizar la conclusión al cambiar el estado de los controles. **9 de noviembre:** nuevo informe académico disponible para su revisión; el borrador anterior se conserva. Falta la devolución de Bruno.
- [ ] Revisar el informe completo contra la consigna y las evidencias finales.

## Índice de handoffs específicos

- [HANDOFF_L4_08_FALCO_2026-11-11.md](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md) — instalación y acción no shell con evento correlacionado, explicación y limpieza comprobadas; local sin publicación.

- [HANDOFF_L4_04_OBSERVABILIDAD_2026-11-10.md](handoffs/HANDOFF_L4_04_OBSERVABILIDAD_2026-11-10.md) — seis paneles/17 pedidos comprobados, revisión visual confirmada y OOM corregido con prueba posterior; sin publicación.

- [HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md](handoffs/HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md) — chart, valores dev, instalación real, tres servicios saludables y persistencia H2 probados; sin publicación.

- [HANDOFF_L4_01_DOCKER_MANIFIESTOS_2026-11-10.md](handoffs/HANDOFF_L4_01_DOCKER_MANIFIESTOS_2026-11-10.md) — Docker/manifiestos implementados y verificados localmente, persistencia H2, once recursos válidos y reportes preservados. Sin publicación ni despliegue.

- [HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md](handoffs/HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md) — prioridad L4, revisión de cuatro ramas, matriz de requisitos, novedad Falco y evidencias publicadas copiadas/verificadas; sin implementación ni cambios del informe.

- [HANDOFF_REDACCION_ACADEMICA_INFORME_2026-11-09.md](handoffs/HANDOFF_REDACCION_ACADEMICA_INFORME_2026-11-09.md) — escritura autorizada completada en un archivo nuevo; ocho páginas revisadas, borrador previo intacto y pendientes técnicos/entrega conservados.

- [HANDOFF_PLAN_CIERRE_INFORME_2026-11-09.md](handoffs/HANDOFF_PLAN_CIERRE_INFORME_2026-11-09.md) — revisión remota de Falco/Kyverno y plan de cierre registrado; sin escritura del Word ni ejecución de controles.

- [HANDOFF_ACTUALIZACION_INFORME_2026-11-03.md](handoffs/HANDOFF_ACTUALIZACION_INFORME_2026-11-03.md) — **3 de noviembre de 2026, escritura autorizada completada.** Word actualizado, once páginas revisadas, respaldo previo conservado y registros sincronizados. Falco, npm audit y consolidación pendientes.

- [HANDOFF_CIERRE_ETAPA_CONTINUIDAD_2026-11-03.md](handoffs/HANDOFF_CIERRE_ETAPA_CONTINUIDAD_2026-11-03.md) — **3 de noviembre de 2026, decisión final vigente.** Confirmación del compañero comunicada por Bruno, aceptación sin repetir pruebas y cierre de búsqueda/revisión Kubernetes. Límites conservados fuera de tareas activas; Falco, npm audit, Word y consolidación siguen pendientes.

- [HANDOFF_PARTE_3_RECUPERACION_REGISTROS_2026-11-03.md](handoffs/HANDOFF_PARTE_3_RECUPERACION_REGISTROS_2026-11-03.md) — **3 de noviembre de 2026.** Búsqueda en archivos, README, commits y PR; copias API y contraste histórico. Faltan comandos/entorno originales; solicitud al autor preparada, no enviada. No hubo controles nuevos ni escritura del Word.

- [HANDOFF_PARTE_3_REVISION_YAML_2026-11-03.md](handoffs/HANDOFF_PARTE_3_REVISION_YAML_2026-11-03.md) — **3 de noviembre de 2026.** Primer paso documental de Kubernetes completado: contraste de políticas/tests/rechazos, hipótesis de tipos, alcance acreditado de KubeLinter, paquete de evidencia a recuperar y matriz futura sin ejecutar. No cierra la parte 3.

- [HANDOFF_REVISION_REPO_2026-11-03.md](handoffs/HANDOFF_REVISION_REPO_2026-11-03.md) — **3 de noviembre de 2026.** Revisión de once archivos incorporados/modificados en main remoto; correcciones y repetición Semgrep, políticas/pruebas Kyverno y KubeLinter, con copias de fuentes y límites. Actualiza registros; Word pendiente de revisión autorizada.

- [HANDOFF_PRIMER_BORRADOR_INFORME_2026-11-02.md](handoffs/HANDOFF_PRIMER_BORRADOR_INFORME_2026-11-02.md) — **2 de noviembre de 2026.** Primer borrador desarrollado directamente en el Word original. Se separó contenido escrito de controles técnicos y evidencias todavía pendientes. Incluye verificaciones de guardado, limitaciones de revisión y siguiente paso con Bruno.

- [HANDOFF_ARMADO.md](handoffs/HANDOFF_ARMADO.md) — **2 de noviembre de 2026; todos los apartados.** Base desarrollada para la redacción: hechos, explicaciones, resultados, decisiones, evidencias y faltantes. Completa la etapa de desarrollo de la lista; transfiere sin cerrar los pendientes técnicos y de entrega de las partes 1, 3 y 4 y la incorporación final de evidencias de Trivy. No constituye texto ya escrito en el informe.

El registro previo `REGISTRO_TRIVY.md` sigue siendo la memoria detallada de Trivy; no duplicar su contenido sin necesidad.

## Historial de actualizaciones

- **11/11/2026 — L4-09 build #3:** Snyk autenticado completado con 44 hallazgos;
  siete críticos detuvieron el gate real, continuación omitida. Artefactos
  preservados. Publicación, Helm, Semgrep CI y build/test todavía pendientes.

- **11/11/2026 — diagnóstico autorizado L4-09:** error -13 localizado en
  permiso de mvnw (Git 100644), corrección preparada y wrapper ejecutado
  correctamente. Autenticación/scan/gate en Jenkins aún pendientes.

- **11/11/2026 — L4-09 build #2:** error Snyk CLI -13/exit 2, sin JSON.
  Gate detuvo por error, no acredita bloqueo de vulnerabilidades. Evidencia
  security-2 conservada; diagnóstico local en curso. Repetición de scan
  diagnóstico rechazada por revisión automática, no ejecutada.

- **11/11/2026 — L4-09 parcial:** Bruno creó el job y ejecutó diagnóstico #1
  SUCCESS; clon remoto ee6bc93/Docker comprobados. Herramientas L4 instaladas
  y cinco versiones verificadas; credencial Snyk confirmada por Bruno, acceso
  pendiente. Gate local 6/6 PASS, prueba Jenkins de seguridad preparada.
  Sin integración, publicación ni Word. [Handoff L4-09](handoffs/HANDOFF_L4_09_JENKINS_2026-11-11.md).

- **10/11, cierre L4-04 tras recuperación:** Bruno reportó caída de acceso. OOMKilled Grafana, 256 MiB insuficientes, corregido en Helm/base a request 512 MiB y limit 1 GiB, chart 0.2.1/revisión 4. Prueba posterior de 360 consultas durante cinco minutos sin reinicios; Bruno confirma seis paneles con datos. Diagnóstico inicial y posterior separados, handoff/mapa/plan sincronizados. Etapa completa localmente; siguiente L4-05 Sol/medio. Reutilizar evidencia existente y verificar faltantes/cambios/fallas, según aclaración a Bruno; sin publicación ni Word.

- **10/11, L4-04:** Helm revisión 3, datasource/dashboard reproducibles, kubelet resource para CPU/memoria, dos targets UP y seis consultas exitosas en Prometheus/Grafana. 17 pedidos correlacionados con contador, export JSON normalizado comprobado y 26 reportes previos intactos. Bruno abre el dashboard; pendiente confirmar los seis paneles. Handoff, mapa y plan guardados; sin publicación, informe ni integración de métricas-nuevas.

- **10/11, cierre L4-03:** Helm 4.3.1 oficial verificado; Minikube existente iniciado, imagen local cargada y release l4 instalado en laboratorio4. Dos pruebas de recreación/persistencia H2 exitosas, servicios accesibles y valores dev comprobados. Reportes preservados; [handoff](handoffs/HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md), mapa y plan actualizados. Sin publicación ni Word. Siguiente L4-04, Sol/alto.

- **10/11, cierre L4-02:** Dive y Trivy exitosos; reporte image-analysis.md, resultados brutos, trazabilidad OCI y propuestas guardados. 52 hallazgos, incluidos once HIGH/CRITICAL abiertos; no se modificó imagen ni dependencias. Trece reportes históricos iguales. [Handoff](handoffs/HANDOFF_L4_02_DIVE_TRIVY_2026-11-10.md). Siguiente L4-03, Sol/alto; E3 en pausa y Word intactos.

- **10/11, implementación L4-01:** etapa solicitada completada con build/test y prueba real de API/H2 no root; 11 recursos válidos por esquema. Rama local desde origin/main, cambios sin commit y sin push; 13 reportes históricos intactos. Documentación de base, verificador y handoff guardados; maestro, mapa y plan actualizados. Bruno abrió Docker tras el error interno inicial y pide operar las interfaces con guía en adelante; preferencia en AGENTS. Siguiente L4-02, Sol/medio. E3 sigue pausado, sin cambios Word ni nuevos controles de seguridad.

- **10/11, organización de implementación:** Bruno acepta empezar por Docker/manifiestos y pide recomendaciones de conversación/modelo/esfuerzo por tarea. Guardado PLAN_TRABAJO_LABORATORIO_4.md con doce tareas, dependencias, criterios de cierre y formato de continuidad; AGENTS y mapa L4 enlazados. Recomendaciones basadas en documentación oficial actual y criterio práctico, sin cambiar el modelo ni crear otro chat. Implementación L4-01 pendiente; sin cambios técnicos ni controles nuevos en esta actualización.

- **10 de noviembre de 2026, transición solicitada por Bruno:** localizado y leído Laboratorio 4.pdf; pausa del trabajo activo de E3 y prioridad del integrador registradas. GitHub consultado en vivo: main `489f9f3`, tres ramas adicionales y comparación de métricas; 32 fuentes de main y cinco de métricas copiadas fuera del repositorio. Nuevo log Falco localizado con arranque, shells y eventos Grafana; no se declara cerrada la prueba no shell de L4. Creado mapa requisito por requisito y handoff; maestro, mapa E3 y AGENTS actualizados. Sin controles nuevos, integración local, publicación ni modificación de Word/PDF.

- **9 de noviembre de 2026, escritura académica autorizada:** confirmado que la siguiente etapa era redactar lo respaldado. Creado `Entregable 3 - Informe redactado.docx` a partir del borrador y evidencias: ocho páginas revisadas en Word, cinco tablas, nueve CVE y 17 vínculos. Incorporados Pod Falco y ajuste booleano Kyverno desde la revisión previa, sin detección ni nuevas pruebas acreditadas. Borrador anterior intacto. Handoff específico, maestro y mapa sincronizados. Completada la adaptación editorial; Falco, npm audit, presentación, revisión con Bruno y consolidación siguen abiertos. Sin controles nuevos, cambios de aplicación, consulta remota nueva, integración ni publicación.

- **9 de noviembre de 2026:** a pedido de Bruno se registra íntegra la lista de cinco pasos para completar el informe y su preferencia de empezar por la escritura respaldada mientras consulta al compañero por Falco. Se incorpora la revisión remota ya realizada: commit `2310ac5`, pod de prueba añadido y comparación booleana Kyverno modificada; log Falco no localizado. Maestro, mapa y handoff específico actualizados. No se modificó el Word, no se ejecutaron pruebas ni se integraron o publicaron cambios.

- **3 de noviembre de 2026, pendiente editorial:** Bruno solicita dejar anotada la adaptación del borrador a informe final académico, revisando los resaltados amarillos y retirando las notas internas del equipo, con las limitaciones relevantes conservadas. Pendiente abierto en organización y cierre; no se modificó el Word.

- **3 de noviembre de 2026, actualización del informe:** Bruno solicita incorporar los nuevos hallazgos de su compañero. Se actualizan apartados 1 y 3, alcance, nota sobre la imagen original, Falco, referencias y conclusiones a partir de las fuentes documentadas. Se conservan los nueve hallazgos Trivy abiertos y la aceptación de Kubernetes con límites. Original guardado; once páginas revisadas mediante imágenes de Word, tras fallar el renderizador por ausencia de LibreOffice. Maestro y mapa actualizados; ver [actualización del informe](handoffs/HANDOFF_ACTUALIZACION_INFORME_2026-11-03.md). Sin controles nuevos, cambios de aplicación, integración ni publicación.

- **3 de noviembre de 2026, cierre por decisión de Bruno:** informa que su compañero corrigió Semgrep y aplicó/probó Kyverno, y que Falco le falta. No hay registros adicionales disponibles; Bruno indica que no se necesita validar nuevamente en su entorno y solicita registrar continuidad para otra conversación. Se acepta ese trabajo para avanzar, se cierra la búsqueda/revalidación de Kubernetes y se conservan sus límites documentales sin declararlos corregidos. Actualizados maestro, mapa, contexto, armado y avisos de handoffs; creado handoff de cierre. Sin controles nuevos, cambios del Word, integración ni publicación.

- **3 de noviembre de 2026, búsqueda de registros Kubernetes:** Bruno pidió continuar en esta conversación. Se consultaron las ramas sin cambios, detalles de los dos commits de Kyverno y PR #2 con sus listas vacías de comentarios/revisiones. La anomalía figura ya en el agregado inicial de resources.yaml; el commit posterior solo agrega KubeLinter. README de métricas identificado por objeto Git; comandos y datos de entorno no localizados. Respuestas y verificaciones conservadas fuera del repositorio. Se preparó solicitud al autor sin enviarla; maestro y mapa actualizados. No se ejecutaron controles, integraron ramas, publicaron cambios ni modificó el Word.

- **3 de noviembre de 2026, revisión documental de Kubernetes:** por solicitud de Bruno de avanzar con el primer siguiente paso, se completó la lectura y contraste de YAML, rechazos y KubeLinter, con consulta de documentación oficial. Se creó el handoff específico y se actualizaron maestro y mapa. Se confirmó localmente HEAD 695072d, `?? reports/` y huella previa del Word. Los rechazos siguen siendo transcripciones publicadas; falta identificar entorno/política efectiva y resolver la anomalía con evidencia. Sin nuevos controles, correcciones, integración, publicación o escritura del informe.

- **3 de noviembre de 2026, preparación del cambio de conversación:** a pedido de Bruno, se añadió al handoff de revisión un punto de entrada con lecturas, oportunidad nueva, pasos priorizados y límites para retomar sin depender del chat. Se enlazó desde este maestro; no se ejecutaron controles ni se modificó el Word.

- **3 de noviembre de 2026, nuevas incorporaciones:** consigna releída y GitHub consultado en vivo mediante API; main remoto `37a452e` incorpora las ramas semgrep y kyverno. Siete alertas corregidas y reporte posterior con cero hallazgos; tres políticas y rechazos publicados como comentarios, con anomalía no root; KubeLinter con seis hallazgos en dos Pods de prueba. npm audit sigue fallido y Falco no localizado. Se actualizaron maestro, mapa, contexto, armado, aviso del handoff de redacción y registro Trivy, y se creó el handoff específico con copias verificadas. Sin controles nuevos, cambios de aplicación, integración local, publicación ni escritura del Word. El borrador y sus conclusiones requieren actualización futura.

- **2 de noviembre de 2026, primer borrador del informe:** por solicitud expresa de Bruno y después de aclarar los faltantes, se escribió `Entregable 3 - Informe.docx` con aproximadamente 4.300 palabras en párrafos, dos tablas y los cuatro apartados de la consigna. Se desarrollaron los resultados disponibles y se declararon pendientes de código, Kubernetes y Falco sin inventar ejecuciones. Word reconoció el archivo guardado y se inspeccionaron visualmente sus once páginas mediante imágenes obtenidas directamente de Word, tras fallar las rutas de exportación PDF y LibreOffice. Se creó el handoff de redacción y se actualizó el mapa. No hubo nuevos análisis de seguridad, correcciones, integración ni publicación. La revisión final de entrega continúa pendiente.

- **2 de noviembre de 2026, preparación de la escritura:** se creó `handoffs/HANDOFF_ARMADO.md` a pedido de Bruno. Se releyeron el maestro, el mapa, el texto de la consigna y fuentes locales de contexto, Trivy y configuración. Se comprobó la base local `main`/`695072de8a64a0770de2af3346d85cfaae397922` y que `reports/` sigue sin versionar. Los resultados remotos de código se tomaron de la verificación previa, sin consulta remota nueva. Se completó la lista desarrollada, no los controles pendientes. No se modificó el Word, no se ejecutaron controles ni se corrigió, integró o publicó el repositorio.
- **2 de noviembre de 2026:** creación del handoff maestro a pedido de Bruno a partir del diagnóstico compartido en la conversación. Se separaron trabajo listo para redactar, cierre técnico y pendientes de entrega. Se creó `AGENTS.md` para mantener el maestro y los futuros handoffs específicos. No se modificó el Word, no se ejecutaron controles nuevos ni se integraron o publicaron cambios del repositorio.

## Historial — cierre L4-05, 10/11/2026

**L4-05 completa localmente, 10/11:** Semgrep 1.184.0, dos reglas Java oficiales
identificadas (CWE-78/CWE-89), ocho archivos de producción, cero hallazgos/errores,
exit 0; pruebas de reglas 2/2 aprobadas. Excluido src/test/java por defecto.
[Reporte](EntregableDevops2/reports/semgrep-report.txt) y
[handoff](handoffs/HANDOFF_L4_05_SEMGREP_2026-11-10.md). Reportes anteriores intactos;
sin cambios Java, commit, publicación ni Word. Once HIGH/CRITICAL L4-02 abiertos.
Siguiente **L4-06 — Snyk sobre Maven, GPT-6.1 Sol, esfuerzo alto**.

### 10/11/2026 — L4-06, preparación y acceso pendiente

- [x] ~~Snyk sobre Maven: preparar CLI y resolución, autenticar y ejecutar análisis.~~ **11/11:** completado; 44 IDs/rutas, siete críticos con propuestas. Estado parcial del 10/11 superado. [Handoff](handoffs/HANDOFF_L4_06_SNYK_2026-11-10.md).

## Historial — cierre L4-06, 11/11/2026

- [x] ~~L4-06 — análisis Maven Snyk, reporte y propuestas para críticos.~~
  130 dependencias incluyendo test, 44 IDs/rutas, siete críticas/once altas;
  ejecución completada con exit 1 por hallazgos. [Handoff](handoffs/HANDOFF_L4_06_SNYK_2026-11-10.md).
- [ ] Remediar 18 HIGH/CRITICAL Snyk L4-06: **parcialmente resuelto en L4-09**;
  siete críticos y diez altas dejaron de aparecer tras cambios/pruebas. Persiste
  una alta; conservar seguimiento residual y diagnóstico inicial. Los once
  HIGH/CRITICAL Trivy L4-02 son históricos; nueva imagen sin scan, no sumar IDs.
- 35 reportes previos intactos; POM/Java iguales a HEAD. Sin commit/publicación
  ni cambios Word. Bruno hizo acceso de interfaz; scan real confirmó autorización.
- Podés cerrar el chat. Siguiente L4-07 — Kyverno, GPT-6.1 Sol/esfuerzo alto.

## Historial — cierre L4-07, 11/11/2026

- [x] ~~L4-07 — Kyverno: instalación, cuarta política y validaciones/log.~~
  Cuatro ValidatingPolicy (CEL por cambio Kyverno 1.20), Ready/Deny, alcance
  laboratorio4. 16/16 pruebas; cuatro rechazos create real y un Pod conforme
  Succeeded UID 10001, retirado. Chart completo admitido; 34 reportes preservados.
  [handoff L4-07](handoffs/HANDOFF_L4_07_KYVERNO_2026-11-11.md). Candidato de lanzamiento y una réplica: límites registrados.
- [x] ~~L4-08 — Falco con acción deliberada distinta de abrir shell y correlación.~~ Resuelto el 11/11 en [handoff L4-08](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md).

Registros/mapa/plan actualizados; sin commit, publicación, remediación de
vulnerabilidades ni Word. Podés cerrar este chat; siguiente L4-08, Sol/alto.

## Historial — cierre L4-08, 11/11/2026

- [x] ~~L4-08 — Falco: instalar, acción distinta de shell, correlación y log.~~
  Chart 9.2.2/Falco 0.45.2, modern eBPF en WSL2. Una alerta Warning por lectura
  directa del fixture /etc/shadow, cat/UID 10001/pod/container/UTC coincidentes.
  Control sin esa alerta, recursos de prueba eliminados, 60 reportes intactos.
  [Handoff](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md),
  [log](EntregableDevops2/reports/falco-event.log),
  [explicación](EntregableDevops2/reports/falco-event.md).
- [x] ~~L4-09 — Jenkins: integración local, destino/credenciales, gate por críticos y registros.~~ **11/11:** #7 SUCCESS; [cierre](handoffs/HANDOFF_L4_09_CIERRE_JENKINS_2026-11-11.md). Código GitHub pendiente separado.

E3 continúa pausado; Word, vulnerabilidades y publicación sin cambios por esta
etapa. Podés cerrar este chat. Siguiente L4-09, GPT-6.1 Sol/esfuerzo alto.

## Historial — continuación L4-09, 11/11/2026

Pipeline y remediaciones candidatas preparados; pruebas por comandos Maven/Semgrep
y simulación Helm PASS. Acceso limitado instalado. Repo Docker Hub elegido por
delegación de Bruno; creación/credencial y ejecución integral pendientes. No se
marca cierre ni críticos resueltos. [Handoff](handoffs/HANDOFF_L4_09_CONTINUACION_2026-11-11.md).

## Historial — L4-09 ejecuciones #4/#5, 11/11/2026

Snyk posterior confirma 7 → 0 críticos; queda 1 alto/8 medios/1 bajo. #5
abortada por Bruno durante push activo, sin despliegue ni éxito integral.
Evidencias preservadas; progreso Docker visible y defaults corregidos para
próxima ejecución guiada. Etapa parcial; sin GitHub/Word.

## Historial — L4-09 #6/recuperación Helm, 11/11/2026

Push real completo con digest; #6 falla en Helm por RBAC. Cliente diff/espera
legacy permite upgrade y salud sin permisos adicionales, roles preservados.
Recuperación separada del job; siguiente ejecución integral pendiente.

## Historial — cierre técnico L4-09, 11/11/2026

- [x] ~~Completar pipeline Jenkins de seis etapas y comprobar éxito integral.~~
  #7 SUCCESS, 97 s; imagen publicada, Helm revisión 8 y tres Pods Ready.
- [x] ~~Eliminar siete críticos Snyk del diagnóstico L4-06/#3.~~ Overrides
  Tomcat/Jackson probados, scans #5/#6/#7 con cero críticos. El pendiente anterior
  de 18 HIGH/CRITICAL queda parcialmente resuelto; persiste una alta y otros niveles.
- [ ] Remediar alta restante Snyk y conservar seguimiento de medios/baja; Trivy
  de nueva imagen completado en B01: dos HIGH Ubuntu abiertos; diagnóstico L4-02 histórico.
- [ ] Publicar rama L4/Jenkinsfile/reportes y conectar fuente remota del pipeline;
  fuente actual local aislada, sin merge/push del repo de trabajo.

[Handoff de cierre](handoffs/HANDOFF_L4_09_CIERRE_JENKINS_2026-11-11.md), evidencia reports/l4-09/integral-7. Word intacto,
E3 pausado. Podés cerrar el chat; siguiente L4-10, Sol/esfuerzo medio.

## Historial — cierre L4-10, 11/11/2026

- [x] ~~L4-10 — scripts Bash de inicio, tráfico y limpieza y guía reproducible.~~
  Inicio/seguridad PASS, tráfico correlacionado, ciclo temporal con retención,
  reinstalación/purga y cierre de puertos comprobados. 211 reportes/Word intactos.
  [Handoff](handoffs/HANDOFF_L4_10_SCRIPTS_2026-11-11.md) y [verificación](EntregableDevops2/reports/l4-10/VERIFICACION.md).
- [x] ~~L4-11 — revisión integral contra consigna y coherencia de evidencias.~~ **11/11:** revisión completa, entrega parcial; [handoff L4-11](handoffs/HANDOFF_L4_11_REVISION_INTEGRAL_2026-11-11.md).
- [ ] L4-12 — redacción final cuando Bruno la solicite; publicación con alcance propio.

Límites: infraestructura existente; retiro seguridad no ejecutado. Fuente GitHub,
alta Snyk/seguimiento Trivy y token 24 h conservan pendientes propios. Podés cerrar
el chat; siguiente L4-11, GPT-6.1 Sol/esfuerzo alto.

## Historial — cierre L4-11, 11/11/2026

- [x] ~~Revisar integralmente consigna, arquitectura, resultados y rutas.~~
  Cinco páginas completas, matriz por cláusula vigente, análisis iniciales separados
  de posteriores; registros generales sincronizados. [Handoff L4-11](handoffs/HANDOFF_L4_11_REVISION_INTEGRAL_2026-11-11.md).
- [ ] L4-11B — cerrar brechas técnicas B01 (imagen publicada, completada posteriormente), B02 (Docker/no root),
  B03 (configuración Helm), B04 (reproducción/limpieza) y B08 (guías históricas),
  con alcance de implementación/verificación propio. No se ejecutaron por L4-11.
- [ ] B05 — consolidar/publicar código/reportes y conectar fuente Git de Jenkins;
  mantener revisión de diferencias con main. Publicación requiere alcance propio.
- [ ] B06/L4-12 — README.md o PDF integrador, diagrama y fragmentos de salida,
  cuando Bruno solicite escritura; dashboard local ya disponible.
- [ ] B07/B09 — seguimiento alta Snyk/medios/baja, imagen histórica y límites
  Kyverno; no afirmar remediación global ni cobertura universal.

Las etapas L4-01 a L4-10 conservan resultados de su alcance probado. L4-11 no
las anula ni declara entrega completa: identifica diferencias contra texto literal.
La tarea inicial “remediar 18 HIGH/CRITICAL Snyk” queda parcialmente resuelta por
L4-09: siete críticos y diez altas dejaron de aparecer; persiste una alta. Trivy de
imagen nueva pendiente separado, sin extrapolar ni sumar IDs entre herramientas.

Revisión local: 33/33 artefactos Jenkins, 6/6 scripts/guía, 77/77 archivos snapshot
con LF normalizado, dashboard consistente; 531 archivos de repo/Word/consigna
preservados. Copias de registros anteriores en handoffs/evidencias_l4_11_2026-11-11/.
Sin controles nuevos, cambios de aplicación, interfaces, GitHub/merge/push ni
informe. Datos operativos previos, no salud en vivo de esta sesión.

Podés cerrar este chat. Siguiente recomendado **L4-11B — cierre de brechas técnicas**,
GPT-6.1 Sol/esfuerzo alto, según criterio del plan; modelo no cambiado. Después
L4-12 con autorización propia. Leer maestro, mapa L4 y handoff L4-11.

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

## Historial — L4-11B/B02, 11/11/2026

- [x] ~~Verificar alcance Docker, versiones, UID y excepciones de terceros/Jenkins.~~
  Matriz actual y capturas runtime; [handoff B02](handoffs/HANDOFF_L4_11B_B02_DOCKER_VERSIONES_2026-11-11.md).
- [x] ~~Agregar control de identidad antes del inicio de Jenkins existente.~~
  Lock local, aceptación real y rechazo simulado comprobados; sintaxis PASS.
- [ ] B02 literal global: Dockerfile por herramienta y Jenkins no root siguen
  sin satisfacer; decisión upstream/excepciones documentadas, no aceptación docente.
- [ ] Migración Jenkins no root/agentes aislados y reproducción desde cero;
  pendiente separado, sin alteración de instalación del curso.
- [ ] B03 Helm; B04 reproducción/limpieza; B08 guías. Sin cambios de alcance para
  B05 publicación, B06 informe o seguimiento de vulnerabilidades.

438 reportes previos intactos. Evidencias/código locales; clúster/Jenkins solo
consultados. Podés cerrar el chat; siguiente B03, GPT-6.1 Sol/esfuerzo alto.

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
