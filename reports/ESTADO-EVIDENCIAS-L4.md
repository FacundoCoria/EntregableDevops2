# Laboratorio 4 — índice vigente de guías y evidencias

Actualización B05: 11/11/2026, Uruguay. Estado respaldado por archivos de las
etapas indicadas; no es una consulta en vivo ni el informe integrador final.

| Tema | Guía / evidencia vigente | Alcance y antecedente |
|---|---|---|
| Operación principal | [GUIA](../scripts/l4/GUIA.md) | Contexto minikube; principal conservado en B04: chart 0.2.1, revisión 10, imagen #7. start.sh aplica el chart local 0.3.0; puede actualizarlo. |
| Reproducción y limpieza | [Guía B04](../scripts/l4/B04-REPRODUCCION.md), [resultado](l4-11b/b04-reproduccion.md) | Perfil minikube-l4-b04 nuevo, reinicio frío, H2, cinco componentes y retiro total probados. Perfil temporal eliminado; Docker/CLI preinstalados, Jenkins desde cero pendiente. |
| Helm local 0.3.0 | [README](../pedidos-api/pedidos-api/helm-chart/README.md), [B03](l4-11b/b03-helm.md) | Puertos 1024–65535 y réplicas 0/1; variante real probada/retirada. No HA. appVersion l4-01 no identifica imagen efectiva. |
| Imagen publicada #7 | [Análisis B01](l4-11b/image-analysis.md), [índice histórico](image-analysis.md) | Digest sha256:48b65d95763c2a1eb6727f9b22b78fc27509f79b62a7b87903cea87a4aee41d9; Trivy 0 críticos/2 altos/23 medios/16 bajos. Dos HIGH Ubuntu pendientes. |
| Snyk Maven | [Comparación](snyk-comparison.md), [diagnóstico original](snyk-report.txt) | #7: 0 críticos/1 alto/8 medios/1 bajo; JAXB HIGH pendiente. No es scan de imagen. |
| Jenkins | [Verificación #7](l4-09/integral-7/verification.json), [gate #3](l4-09/security-3/gate-summary.json) | SUCCESS #7 y bloqueo previo sobre snapshot local 0f47780. Código/reportes publicados en rama B05; SCM y clonación remota comprobados, sin nuevo build integral. [B05](l4-11b/b05/CONSOLIDACION.md). |
| Docker/versiones/no root | [B02](l4-11b/b02-componentes.md) | API/monitoreo/Kyverno no root; Jenkins/Falco UID 0 como excepciones. Imágenes oficiales sin Dockerfile derivado; conformidad literal global parcial. |
| Observabilidad | [Guía](../pedidos-api/pedidos-api/OBSERVABILIDAD-L4.md), [dashboard](../grafana/dashboard.json) | Seis paneles comprobados L4-04, OOM corregido; B03/B04 targets UP. Contadores no reconstruyen datos históricos H2. |
| Semgrep | [Reporte](semgrep-report.txt) | Dos reglas Java, ocho fuentes, 0 hallazgos/errores; no cobertura universal. |
| Kyverno | [Guía](../pedidos-api/pedidos-api/security/kyverno/README.md), [log](kyverno-validation.log) | Cuatro políticas, 16/16 casos, namespace laboratorio4, candidato/una réplica. latest con digest y ephemeralContainers: límites B09. |
| Falco | [Guía](../pedidos-api/pedidos-api/security/falco/README.md), [evento](falco-event.md), [log](falco-event.log) | Acción no shell sobre fixture ficticio y alerta correlacionada L4-08; no incidente real. |
| Pruebas operativas iniciales | [L4-10](l4-10/VERIFICACION.md) | Inicio/tráfico/retención/purga previos; B04 amplía reproducción y retiro de seguridad, sin borrar el diagnóstico. |

Pendientes separados: B02 literal, B04 global/Jenkins desde cero, B06 informe final y B07/B09 seguimiento
de seguridad/alcance. B05 cierra publicación de la rama/fuente SCM; B08 contextualizó las guías. Las demás brechas siguen abiertas.
E3 y sus Word quedan pausados. No ejecutar nuevamente verificadores para
recuperar evidencia ya conservada; cualquier prueba nueva necesita destino nuevo.
