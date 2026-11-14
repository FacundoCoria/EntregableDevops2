# Laboratorio 4 — índice vigente de guías y evidencias

**14/11, C06: corrección y tratamiento técnico local completos.** Snyk
0 CRITICAL/1 HIGH/0 MEDIUM/0 LOW; JAXB mitigado/no parcheado, C06-R1 abierto.
Trivy imagen C06 0/0/17/16; 28 pares eliminados frente a #7 con igual DB.
33 filas Ubuntu sin fix informado, C06-R2 abierto. Tres tests/20 HTTP,
persistencia H2/probe DOM-SAX PASS. [Tratamiento](l4-c06/TRATAMIENTO.md),
[verificación](l4-c06/VERIFICACION.md). Ensayo retirado; originales intactos.
Imagen C06/C01–C06 solo locales sin publicar; README histórico hasta C09.
Siguiente C07: acordar fuente/publicación y alcance integral. Los cierres
siguientes son antecedentes.


**14/11, C05: ampliación técnica probada solo en entorno descartable.**
latest@digest rechazado; espacios de aplicaciones/default y efímeros cubiertos,
siete políticas, 90 casos distintos aprobados (60 + 30) y siete rechazos reales.
[Alcance](l4-c05/ALCANCE.md), [verificación](l4-c05/VERIFICACION.md).
Perfil de prueba retirado; principal conserva políticas anteriores. C05-A
aceptación académica de cinco namespaces exceptuados pendiente, literal global
parcial. C01–C05 sin publicar; informe histórico se revisará en C09. Próximo C06.
Los estados siguientes son antecedentes.

**14/11, C04: decisión técnica acordada con Bruno, solo local.** Oficiales de
Prometheus/Grafana/Kyverno/Falco conservadas; API multi-stage, controlador Jenkins
una etapa y agente dos. Jenkins dedicado UID 1000; Falco/DinD excepciones.
[Matriz C04](l4-c04/CRITERIO-DOCKERFILES.md), [verificación](l4-c04/VERIFICACION.md).
Aceptación académica C04-A pendiente; conformidad literal global parcial.
README publicado conserva conclusiones históricas hasta C09; C01–C04 sin publicar.
Próximo C05. Los estados anteriores que siguen son antecedentes.

**Actualización técnica local, 14/11/2026:** C01 Jenkins dedicado desde cero y
C02 guía portable completos el 13/11; C03 copia fría, recuperación, preflight
manual #2 SUCCESS y purga dedicada completos el 14/11. [Guía C03](../ci/jenkins/RECUPERACION.md),
[resultado](l4-c03/VERIFICACION.md), [instalación portable](../docs/INSTALACION-L4.md).
Origen/curso preservados; C01–C03 sin commit/push sobre 50a0eb5. Integral final
C07 y publicación C09 pendientes. El párrafo siguiente registra la publicación
anterior de B05/B06, que no incluye C01–C03.

Actualización de entrega: 13/11/2026, Uruguay. Estado respaldado por archivos de las
etapas indicadas; no es una consulta en vivo. El [informe integrador](../README.md)
y su [diagrama](../docs/arquitectura-l4.png) se incorporan a la rama de revisión
[trabajo-integrador-4](https://github.com/FacundoCoria/EntregableDevops2/tree/trabajo-integrador-4).
Main queda sin cambios; el compañero revisará y decidirá el merge. No se
incorpora la rama métricas-nuevas ni se repite el pipeline por esta publicación.

| Tema | Guía / evidencia vigente | Alcance y antecedente |
|---|---|---|
| Operación principal | [GUIA](../scripts/l4/GUIA.md) | Contexto minikube; principal conservado en B04: chart 0.2.1, revisión 10, imagen #7. start.sh aplica el chart local 0.3.0; puede actualizarlo. |
| Reproducción y limpieza | [Guía B04](../scripts/l4/B04-REPRODUCCION.md), [resultado](l4-11b/b04-reproduccion.md) | Perfil minikube-l4-b04 nuevo, reinicio frío, H2, cinco componentes y retiro total probados. Perfil temporal eliminado; Docker/CLI preinstalados; Jenkins desde cero resuelto C01 y recuperación/purga C03 por separado. Integral C07 pendiente. |
| Helm local 0.3.0 | [README](../pedidos-api/pedidos-api/helm-chart/README.md), [B03](l4-11b/b03-helm.md) | Puertos 1024–65535 y réplicas 0/1; variante real probada/retirada. No HA. appVersion l4-01 no identifica imagen efectiva. |
| Imagen publicada #7 | [Análisis B01](l4-11b/image-analysis.md), [índice histórico](image-analysis.md) | Digest sha256:48b65d95763c2a1eb6727f9b22b78fc27509f79b62a7b87903cea87a4aee41d9; Trivy 0 críticos/2 altos/23 medios/16 bajos. B01 histórico; imagen local C06 0/0/17/16, sin publicar/desplegar; [tratamiento](l4-c06/TRATAMIENTO.md). |
| Snyk Maven | [C06](l4-c06/TRATAMIENTO.md), [comparación histórica](snyk-comparison.md) | C06 local 0/1/0/0; JAXB mitigado/no parcheado. #7 0/1/8/1 histórico intacto; C06-R1 abierto. No es scan de imagen. |
| Jenkins | [Verificación #7](l4-09/integral-7/verification.json), [gate #3](l4-09/security-3/gate-summary.json) | SUCCESS #7 y bloqueo previo sobre snapshot local 0f47780. Código/reportes publicados en rama B05; SCM y clonación remota comprobados, sin nuevo build integral. [B05](l4-11b/b05/CONSOLIDACION.md). |
| Docker/versiones/no root | [C04](l4-c04/CRITERIO-DOCKERFILES.md), [B02](l4-11b/b02-componentes.md) | API/monitoreo/Kyverno no root; Jenkins dedicado C01 controlador/agente UID 1000. Curso histórico root; DinD/Falco privilegiados como excepciones. Oficiales de monitoreo/seguridad conservadas; Jenkins tiene derivados reales C01. Aceptación académica C04-A pendiente, conformidad literal global parcial. |
| Observabilidad | [Guía](../pedidos-api/pedidos-api/OBSERVABILIDAD-L4.md), [dashboard](../grafana/dashboard.json) | Seis paneles comprobados L4-04, OOM corregido; B03/B04 targets UP. Contadores no reconstruyen datos históricos H2. |
| Semgrep | [Reporte](semgrep-report.txt) | Dos reglas Java, ocho fuentes, 0 hallazgos/errores; no cobertura universal. |
| Kyverno | [Guía](../pedidos-api/pedidos-api/security/kyverno/README.md), [C05](l4-c05/VERIFICACION.md), [log anterior](kyverno-validation.log) | C05 aislado: siete reglas, 90 casos distintos, siete rechazos reales; latest@digest/efímeros/default cubiertos. Principal sin ampliación. Cinco namespaces exceptuados, C05-A abierta; candidato/una réplica. |
| Falco | [Guía](../pedidos-api/pedidos-api/security/falco/README.md), [evento](falco-event.md), [log](falco-event.log) | Acción no shell sobre fixture ficticio y alerta correlacionada L4-08; no incidente real. |
| Pruebas operativas iniciales | [L4-10](l4-10/VERIFICACION.md) | Inicio/tráfico/retención/purga previos; B04 amplía reproducción y retiro de seguridad, sin borrar el diagnóstico. |

Pendientes separados: aceptación literal C04-A, ciclo global C07, revisión/merge a main y B07/B09 seguimiento
de seguridad/alcance. B06 completa la redacción, diagrama y selección de salidas.
B05 cierra publicación de la rama/fuente SCM; B08 contextualizó las guías. Las demás brechas siguen abiertas.
E3 y sus Word quedan pausados. No ejecutar nuevamente verificadores para
recuperar evidencia ya conservada; cualquier prueba nueva necesita destino nuevo.
