# Laboratorio 4 — Etapas, conversaciones y modelo recomendado

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

**L4-09 vigente, continuación 11/11:** seis etapas preparadas y fuente local aislada;
Maven/Semgrep y Helm dry-run comprobados por comandos. Falta ejecución Jenkins,
confirmar Snyk después de actualizaciones candidatas, credencial/publicación Docker
Hub y despliegue real. Usuario brunovitola confirmado. [Continuidad](handoffs/HANDOFF_L4_09_CONTINUACION_2026-11-11.md).

Actualizado: 11 de noviembre de 2026, Uruguay.

## Acuerdo de trabajo

Bruno acepta empezar por Docker y manifiestos. Antes de implementar solicita organizar tareas, recomendar modelo/esfuerzo y registrar cuándo conviene cerrar una conversación y pasar a la siguiente. La organización inicial no implementó cambios. Continuación del 10/11: L4-01 implementada y verificada localmente; ver su handoff. Bruno realizará las acciones de interfaz guiado paso a paso y el agente continuará con archivos, comandos y verificaciones técnicas.

Consultar primero HANDOFF_MAESTRO.md, después MAPA_CONSIGNA_EVIDENCIAS.md y MAPA_LABORATORIO_4_EVIDENCIAS.md. Este plan agrega ejecución por etapas; el mapa sigue siendo el detalle de requisitos y evidencias. E3 permanece pausado.

## Modelo y esfuerzo

Recomendación de trabajo, no garantía de rendimiento ni cambio automático de configuración. Los nombres deben estar disponibles en el selector de la cuenta; no se comprobó ese selector. El usuario selecciona modelo y esfuerzo. No afirmar que fueron cambiados sin evidencia.

- **GPT-6.1 Sol + medio:** opción habitual para cambios acotados, documentación basada en resultados y scripts simples.
- **GPT-6.1 Sol + alto:** cuando hay varias piezas que deben funcionar juntas, decisiones de configuración y diagnóstico de errores.
- **GPT-6 Astra + alto:** alternativa para bloqueos difíciles que persistan tras investigar con Sol: integración, fallos de entorno o contradicciones de seguridad. Usarlo por problema concreto; no es obligatorio para todo el integrador.
- **GPT-6 Luna + medio:** alternativa para ordenar evidencias o actualizar texto con hechos ya comprobados. Mantener Sol si cambiar de modelo agrega fricción.
- No usar extra alto/máximo por defecto. Evaluar extra alto para un bloqueo concreto si alto resulta insuficiente y hay motivo para esperar una mejora. Más razonamiento no corrige credenciales ausentes, un servicio caído ni falta de evidencia.

Base consultada: [selección de modelos](https://developers.openai.com/api/docs/guides/model-selection) y [esfuerzo de razonamiento](https://developers.openai.com/api/docs/guides/reasoning), documentación oficial de OpenAI consultada el 10/11/2026. La asignación por tarea es criterio práctico para este proyecto; no es una receta oficial ni una comparación medida con este repositorio.

## Etapas y puntos de cierre

Los criterios de cierre indican resultados a verificar, no resultados ya obtenidos. L4-01, L4-02 y L4-03 se completaron localmente el 10/11; L4-04 está completada técnica y visualmente, con caída de memoria corregida y comprobada; L4-05 a L4-08 completadas localmente; L4-09 completa localmente; L4-10 completa localmente con límites; L4-11 completa como revisión; L4-11B y L4-12 pendientes. Ver cierre vigente inicial. La remediación de hallazgos L4-02 queda abierta por separado. Ver estados al pie y límites del handoff de L4-01.

| ID | Tarea | Modelo inicial | Esfuerzo | Cuándo se puede cerrar la etapa |
|---|---|---|---|---|
| L4-01 | Base de trabajo, inventario de componentes, Docker multi-stage y manifiestos compatibles: versiones, recursos, permisos y persistencia | GPT-6.1 Sol | Alto | Base remota/local reconciliada sin perder reportes; imagen construida y API probada, escritura H2 comprobada, manifiestos revisados; cambios y límites guardados. |
| L4-02 | Dive, análisis de vulnerabilidades de la imagen final y image-analysis.md | GPT-6.1 Sol | Medio | Imagen identificada, tamaño/capas/observaciones medidos, reportes reales conservados y hallazgos tratados/documentados según consigna. Subir a alto si exige decidir cambios de dependencias/base o investigar fallos. |
| L4-03 | Helm Chart, configuración por entorno, instalación y acceso | GPT-6.1 Sol | Alto | Chart validado e instalación real documentada; pods saludables, servicio accesible y persistencia/configuración coherentes. |
| L4-04 | Prometheus/Grafana: datasource, RPS, latencia HTTP, CPU/memoria por pod y negocio, dashboard JSON | GPT-6.1 Sol | Alto | Scrape y consultas comprobados, cuatro grupos de métricas visibles, dashboard exportado y evidencia guardada. Decidir antes si se necesitan cambios de métricas-nuevas; no integrar automáticamente. |
| L4-05 | Semgrep: dos reglas Java identificadas, análisis y reporte requerido | GPT-6.1 Sol | Medio | Reglas y alcance acreditados, reporte real guardado, hallazgos corregidos/justificados sin perder diagnóstico previo. |
| L4-06 | Snyk sobre Maven, reporte y propuestas para críticos | GPT-6.1 Sol | Alto | Ejecución exitosa y alcance documentados, críticos identificados y correcciones propuestas. Si acceso/configuración faltan, registrar el bloqueo; no inventar resultados. |
| L4-07 | Cuarta política Kyverno y evidencia de validación por política | GPT-6.1 Sol | Alto | Política adicional definida, aplicación y rechazos exigidos acreditados, log guardado; límites/exclusiones explícitos. No reabrir búsquedas históricas E3 retiradas. |
| L4-08 | Falco: acción deliberada distinta de shell, correlación y explicación | GPT-6.1 Sol | Alto | Acción y evento relacionados, entorno identificado, log con nombre requerido y explicación. Escalar a Astra alto si la captura eBPF/WSL2/clúster presenta un bloqueo difícil. |
| L4-09 | Jenkins: clonación, Semgrep, Snyk, build/test, publicación Docker y Helm; bloqueo por críticos | GPT-6.1 Sol | Alto | Jenkinsfile y flujo real exitoso con registros por etapa; bloqueo por críticos comprobado. Escalar a Astra alto si persisten problemas entre credenciales, registro, Jenkins y clúster. |
| L4-10 | Scripts Bash de inicio de componentes/operadores aplicables, tráfico y limpieza, y guía de uso | GPT-6.1 Sol | Medio | Inicio y tráfico reproducibles, alcance de limpieza seguro y probado, comandos/resultados documentados. Subir a alto para coordinación del ciclo completo. Se desarrollan progresivamente durante las etapas previas. |
| L4-11 | Revisión integral contra consigna, arquitectura y resultados finales | GPT-6.1 Sol | Alto | Matriz sin afirmaciones sin respaldo, artefactos/rutas consistentes y faltantes identificados. Astra alto es opcional para contradicciones difíciles, no una revisión obligatoria adicional. |
| L4-11B | Cierre de brechas técnicas identificadas en L4-11: imagen publicada, alcance de componentes, configuración Helm, reproducción/limpieza y guías | GPT-6.1 Sol | Alto | B01–B04/B08 corregidas y probadas o excepciones explícitamente resueltas; diagnóstico histórico conservado. Publicación e informe tienen alcance propio. Etapa propuesta por la revisión; implementación todavía no solicitada. |
| L4-12 | Redacción del README o informe final cuando Bruno solicite escritura | GPT-6.1 Sol | Medio | Texto cotejado con evidencias, diagrama y dashboard adjuntos; si se genera PDF/Word, revisión visual completada. Luna medio puede encargarse de edición simple con contenido ya validado. |

Dependencias principales: L4-01 → L4-02/L4-03; observabilidad después de una base desplegable; Jenkins integra comandos de construcción, seguridad y Helm que ya funcionen. Scripts y documentación se registran durante cada etapa y se consolidan en L4-10. No esperar al final para guardar comandos o salidas.

## Conversaciones

**Recomendación inicial:** abrir una conversación nueva para L4-01, separando el diagnóstico anterior de la implementación. Es una decisión de orden; esta conversación también puede continuar y no hay una obligación técnica de cambiarla. No se crea una conversación automáticamente.

Usar una conversación por etapa con un resultado verificable. L4-01 y L4-02 pueden compartir conversación si el trabajo sigue siendo claro. Cambiar de conversación al cerrar una etapa o si se acumulan varios intentos y rutas descartadas. Mantener el mismo chat mientras se resuelve un problema activo; no reiniciar simplemente por el primer error.

Antes de sugerir el cierre:

1. Guardar cambios, resultados, evidencias y límites; comprobar lo realizado.
2. Crear o actualizar el handoff específico con fecha, objetivo, archivos, resultados, pendientes, rama/commit y procedencia local/publicada.
3. Actualizar maestro, matriz y estado de esta lista; no marcar completado lo parcial.
4. Informar a Bruno qué quedó terminado, si puede cerrar el chat, el ID/título de la siguiente tarea y modelo/esfuerzo recomendado según su dificultad real.
5. Dejar una instrucción breve de continuación que enlace los registros necesarios, sin depender de recordar el chat.

Formato de cierre esperado: «Etapa [ID] [completa/parcial]. [Resultado y pendientes]. [Podés cerrar este chat / conviene continuar con el problema actual]. Siguiente: [ID y tarea]. Modelo recomendado: [nombre], esfuerzo [nivel]. Leer [handoff y mapa]».

## Estado actual y arranque siguiente

- [x] ~~L4-09 — ejecución integral y gate por críticos.~~ **11/11:** #7 SUCCESS, #3 BLOCKED_CRITICAL conservado; [cierre](handoffs/HANDOFF_L4_09_CIERRE_JENKINS_2026-11-11.md). GitHub pendiente separado.

- [x] ~~L4-09 — herramientas, credenciales y seis etapas.~~ **11/11:** comprobadas en #7; [cierre](handoffs/HANDOFF_L4_09_CIERRE_JENKINS_2026-11-11.md).

- [x] ~~Diagnóstico y matriz del integrador.~~ 10/11: [handoff de revisión](handoffs/HANDOFF_LABORATORIO_4_DIAGNOSTICO_2026-11-10.md).
- [x] ~~Elegir primera etapa y registrar modelo/esfuerzo por tarea.~~ 10/11: Bruno acepta Docker/manifiestos; plan guardado.
- [x] ~~L4-01 — Docker y manifiestos.~~ 10/11: imagen construida/testeada, API no root y persistencia H2 comprobadas; 11 recursos válidos por esquema. Cambios locales sin commit/publicación; instalación en clúster en L4-03. [Handoff](handoffs/HANDOFF_L4_01_DOCKER_MANIFIESTOS_2026-11-10.md).
- [x] ~~L4-02 — Dive y análisis de vulnerabilidades de la imagen final.~~ 10/11: Dive/Trivy exitosos, [reporte](EntregableDevops2/reports/image-analysis.md), [handoff](handoffs/HANDOFF_L4_02_DIVE_TRIVY_2026-11-10.md); 52 hallazgos, once HIGH/CRITICAL abiertos/documentados.
- [ ] Remediación de vulnerabilidades detectadas en L4-02: revisar BOM/base, pruebas y reescaneo; pendiente separado, sin iniciar cambios por el cierre de análisis.
- [x] ~~L4-03 — Helm Chart, configuración por entorno, instalación y acceso.~~ 10/11: release l4 revisión 2, tres servicios saludables, valores dev y H2 tras recrear pod comprobados. [Handoff](handoffs/HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md).
- [x] ~~L4-04 — Observabilidad y dashboard.~~ **10/11:** seis paneles comprobados y confirmados por Bruno, dashboard exportado y corrección OOM verificada en revisión 4. [Handoff](handoffs/HANDOFF_L4_04_OBSERVABILIDAD_2026-11-10.md). Siguiente **L4-05, GPT-6.1 Sol, esfuerzo medio**.
- [x] ~~L4-05 — Semgrep.~~ **10/11:** dos reglas Java oficiales, ocho fuentes, cero hallazgos/errores; pruebas 2/2, reporte y [handoff](handoffs/HANDOFF_L4_05_SEMGREP_2026-11-10.md).
- [x] ~~L4-06 — Snyk sobre Maven.~~ **11/11:** 130 dependencias con test, 44 IDs/rutas (7 críticas); análisis/reporte/propuestas completos, sin remediación. [Handoff](handoffs/HANDOFF_L4_06_SNYK_2026-11-10.md).
- [ ] Remediar 18 HIGH/CRITICAL Snyk L4-06: **parcialmente resuelto en L4-09**, siete críticos y diez altas dejaron de aparecer tras cambios y pruebas; persiste una alta. Conservar diagnóstico inicial y seguimiento residual, ver cierre L4-11.
- [x] ~~L4-07 — Kyverno.~~ **11/11:** cuatro ValidatingPolicy CEL Ready/Deny en laboratorio4, 16/16 pruebas y cuatro rechazos reales; candidato 1.20.0-rc.4/una réplica, límites guardados. [handoff L4-07](handoffs/HANDOFF_L4_07_KYVERNO_2026-11-11.md).
- [x] ~~L4-08 — Falco.~~ **11/11:** instalación eBPF y acción no shell con una alerta correlacionada; control, limpieza y 60 reportes preservados. [Handoff](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md).
- [x] ~~L4-10 — scripts y guía operativa.~~ **11/11:** pruebas reales de inicio/tráfico/limpieza; [handoff](handoffs/HANDOFF_L4_10_SCRIPTS_2026-11-11.md).
- [x] ~~L4-11 — revisión integral contra consigna, arquitectura y evidencias.~~ **11/11:** matriz actualizada, brechas B01–B09 registradas; [handoff L4-11](handoffs/HANDOFF_L4_11_REVISION_INTEGRAL_2026-11-11.md).
- [ ] L4-12 — redacción final con autorización propia.

Instrucción histórica de arranque L4-01 (cumplida; usar el cierre siguiente para continuar): «Continuemos Laboratorio 4 con L4-01 del PLAN_TRABAJO_LABORATORIO_4.md: Docker y manifiestos. Leé primero AGENTS.md, HANDOFF_MAESTRO.md y los mapas indicados. La copia local está atrasada respecto de GitHub y contiene reportes locales sin versionar: preservalos y revisá la base antes de modificar. Implementemos y verifiquemos esta etapa, guardando evidencias y handoff. E3 sigue pausado; no publicar cambios ni modificar su informe por esta tarea».

Cierre histórico L4-01 del 10/11 (L4-02 cumplida después): «Sigamos con L4-02. Leé AGENTS.md, maestro, mapas y handoffs/HANDOFF_L4_01_DOCKER_MANIFIESTOS_2026-11-10.md. Analizá la imagen pedidos-api:l4-01 identificada allí, preservando reportes históricos. Guiame para acciones de interfaz; ocupate de comandos y archivos. Sin publicar ni modificar el informe».

Cierre histórico L4-02 del 10/11 (L4-03 completada después): podés cerrar el chat. Siguiente L4-03, Sol/alto. Leer [handoff L4-02](handoffs/HANDOFF_L4_02_DIVE_TRIVY_2026-11-10.md) y L4-01 antes de preparar Helm e instalarlo; conservar vulnerabilidades abiertas. Bruno opera interfaces guiado paso a paso; agente realiza comandos/archivos. Sin publicación ni informe final por esta etapa.

Cierre histórico L4-03 del 10/11: podés cerrar el chat. Siguiente L4-04, Sol/alto. Leer el [handoff L4-03](handoffs/HANDOFF_L4_03_HELM_INSTALACION_2026-11-10.md). Minikube encendido con release l4 en laboratorio4; servicios de default son antecedentes separados. Bruno opera interfaces guiado; agente realiza comandos/archivos. Sin publicación ni informe final por esta etapa.

Cierre histórico L4-04 del 10/11: podés cerrar este chat. Seis paneles comprobados y confirmados visualmente, 17 pedidos correlacionados, dashboard exportado. OOM Grafana corregido (512 MiB request/1 GiB limit), revisión 4; 360 consultas en cinco minutos sin reinicios. Leer handoff L4-04 y mapa. Siguiente L4-05 — Semgrep, Sol/medio. Reutilizar evidencias respaldadas y comprobar solo faltantes/cambios/fallas; no repetir todo el repositorio. Sin publicación ni informe final por esta etapa.

Cierre histórico L4-05 del 10/11 (L4-06 completada el 11/11): podés cerrar este chat. Dos reglas Java identificadas y probadas, análisis exitoso sin hallazgos y reporte exigido guardado; diagnóstico previo intacto. Siguiente **L4-06 — Snyk sobre Maven, GPT-6.1 Sol, esfuerzo alto**. Leer handoff L4-05, maestro y mapas; conservar once HIGH/CRITICAL L4-02 abiertos. Sin publicación ni informe final por esta etapa.

Cierre histórico L4-06 del 11/11 (L4-07 completada después): podés cerrar este chat. Análisis y propuestas completos, siete críticos y once altos abiertos; sin cambios de dependencias ni publicación. [Handoff](handoffs/HANDOFF_L4_06_SNYK_2026-11-10.md). Siguiente **L4-07 — Kyverno, GPT-6.1 Sol, esfuerzo alto**.

Cierre histórico L4-07 del 11/11 (L4-08 completada después): podés cerrar este chat. Instalación Kyverno y
cuatro políticas verificadas, log requerido guardado, reportes previos intactos.
[handoff L4-07](handoffs/HANDOFF_L4_07_KYVERNO_2026-11-11.md). Siguiente **L4-08 — Falco: acción distinta de abrir shell,
correlación y explicación del evento. GPT-6.1 Sol, esfuerzo alto**.
Sin publicación ni informe final por esta etapa.

Cierre vigente L4-08 del 11/11: podés cerrar este chat. Falco 0.45.2 operativo,
acción directa sin shell sobre fixture sensible y alerta Warning correlacionada;
log/explicación guardados y prueba retirada. 60 reportes anteriores intactos.
[Handoff L4-08](handoffs/HANDOFF_L4_08_FALCO_2026-11-11.md). Siguiente **L4-09 —
Jenkins, GPT-6.1 Sol, esfuerzo alto**. Definir registro/credenciales con Bruno;
conservar hallazgos críticos abiertos y comprobar gate real sin ocultarlos.
Bruno opera interfaces guiado; agente realiza comandos/archivos. Sin publicación
de repo ni informe final por el cierre de L4-08.

## Continuidad vigente después de L4-09

Podés cerrar este chat. Siguiente **L4-10 — scripts Bash de inicio, tráfico y
limpieza y guía reproducible**, Sol/esfuerzo medio. Leer [cierre L4-09](handoffs/HANDOFF_L4_09_CIERRE_JENKINS_2026-11-11.md),
maestro y mapa. Conservar límites: fuente local sin publicación GitHub, una alta
Snyk y token Kubernetes 24h. No iniciar informe ni publicación por este cierre.

## Continuidad vigente después de L4-10

Podés cerrar este chat. Siguiente **L4-11 — revisión integral contra consigna,
arquitectura y resultados finales**, GPT-6.1 Sol/esfuerzo alto. Leer [handoff
L4-10](handoffs/HANDOFF_L4_10_SCRIPTS_2026-11-11.md), maestro y mapas. Conservar límites de limpieza/infraestructura,
pendientes de publicación y vulnerabilidades. No iniciar informe/publicación
por el cierre de esta etapa.

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

## Continuidad B02 — 11/11/2026

- [x] ~~B02: inventario real, decisión propios/upstream, excepciones y lock de Jenkins.~~
  [Handoff](handoffs/HANDOFF_L4_11B_B02_DOCKER_VERSIONES_2026-11-11.md).
- [ ] B02 literal global: Dockerfiles por herramienta y Jenkins no root/reproducible;
  no declarados completos por documentar excepciones.
- [ ] Siguiente B03 Helm, Sol/esfuerzo alto; después B04/B08.

Podés cerrar este chat. No se cambió el modelo ni se publicó el trabajo.

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
