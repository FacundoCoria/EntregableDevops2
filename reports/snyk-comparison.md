# Snyk Maven — diagnóstico y resultado posterior

Contextualización B08, 11/11/2026. Comparación de artefactos existentes, sin
scan nuevo. [Reporte inicial íntegro](snyk-report.txt).

| Evidencia | CRITICAL | HIGH | MEDIUM | LOW |
|---|---:|---:|---:|---:|
| [L4-06 original](l4-06/snyk.json) | 7 | 11 | 24 | 2 |
| [Jenkins #7 posterior](l4-09/integral-7/snyk.json) | 0 | 1 | 8 | 1 |

Ambos análisis incluyen test y 130 dependencias. Snyk #7 terminó con exit 1 por
hallazgos; el [gate](l4-09/integral-7/gate-summary.json) pasó por cero críticos.
El [gate #3](l4-09/security-3/gate-summary.json) bloqueó siete críticos; el error
técnico de #2 se conserva como intento fallido, no resultado de vulnerabilidades.

Tomcat 11.0.27 y Jackson BOM 3.1.8 se aplicaron y probaron en L4-09. Los siete
IDs críticos y diez IDs altos iniciales no aparecen en #7; comparación de IDs
en [JSON B08](l4-11b/b08/snyk-comparison.json). La ejecución integral #7 tuvo
una prueba Maven sin fallos, API UP y publicación de imagen; ver
[verificación](l4-09/integral-7/verification.json). Una prueba no garantiza
compatibilidad universal ni ausencia de vulnerabilidades.

Persiste HIGH `SNYK-JAVA-ORGGLASSFISHJAXB-20883142`, jaxb-core 4.0.9 (XXE), sin
versión corregida informada en ese resultado. Mantener seguimiento B07 y revisar
uso/configuración XML antes de justificar aplicabilidad. No se hizo análisis de
alcanzabilidad ni explotación. Los ocho medios y un bajo siguen documentados.

El [Trivy de la imagen publicada](l4-11b/image-analysis.md) conserva dos HIGH
Ubuntu: es otro alcance/catálogo y no debe sumarse a Snyk como IDs únicos.
Los hallazgos Java del Trivy L4-02 ya no aparecen en B01; el diagnóstico antiguo
permanece. No atribuir todos los cambios únicamente a una dependencia: también
intervienen catálogo, fecha y alcance de cada herramienta.

Evidencia local sin publicación nueva. El código/reportes L4 aún no están
consolidados en GitHub (B05); este documento no sustituye el informe final.
