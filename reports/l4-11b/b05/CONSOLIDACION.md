# B05 — consolidación y entrega

11/11/2026, Uruguay. Rama `lab4/b05-consolidacion-entrega`, publicada por Pela311
en el [repositorio original](https://github.com/FacundoCoria/EntregableDevops2/tree/lab4/b05-consolidacion-entrega).
Main remoto `ee6bc93` incorporado en esta rama; main no modificado.

El commit técnico `1869fe342c0f02366b455fbd323e1b53f11d1610` fue clonado
desde GitHub dentro del contenedor Jenkins. Checkout limpio, Jenkinsfile remoto
y **721 archivos de evidencia idénticos** a la copia local. La comprobación
local previa también verificó scripts LF/ejecutables, resolución por rama/commit,
rechazo de referencia inexistente, Helm lint/render (16 recursos) y Kustomize
(11 recursos) después del renombrado remoto de la configuración Prometheus.

Bruno configuró el job `L4-09-pedidos-api` como Pipeline script from SCM, URL
original, rama `*/lab4/b05-consolidacion-entrega`, Script Path `Jenkinsfile`.
Se verificaron su definición SCM y los defaults SOURCE_URL/SOURCE_REF: remotos.
Los parámetros heredados locales se corrigieron antes de cerrar esta etapa.
Los valores de «Build with Parameters» deben corresponder a la fuente deseada.

| Evidencia | Alcance |
|---|---|
| [Verificación local](verificacion-local.json) | Commit técnico, 721 reports y contenido original; no cuenta este documento posterior. |
| [Clonación Jenkins](fuente-remota-jenkins.json) | Fuente pública clonada desde Jenkins; sin build integral. |
| [Configuración SCM](configuracion-scm.json) | Campos no secretos leídos del job después de guardar en interfaz. |
| [Guía de entrega](../../../docs/ENTREGA-B05.md) | Reconciliación, uso y límites. |

Los archivos de esta carpeta y el contexto B05 de README/índice se agregan en
un commit documental posterior. Su publicación se verifica por separado.
Los reportes iniciales y posteriores de seguridad se conservan; no hubo scan nuevo.
SUCCESS #7 corresponde al snapshot local `0f47780`, no a un nuevo build remoto.
No se disparó #8 ni se publicó otra imagen ni se actualizó el release principal.
B02 literal/B04 global y B06/B07/B09 permanecen con su alcance pendiente.
