# C05 — verificación y límites

Fecha: **14/11/2026, Uruguay**. Ampliación técnica local probada y entorno retirado.
[Alcance y decisiones](ALCANCE.md); [JSON con fuentes por caso](verificacion.json).

- Comparación anterior: [baseline.log](baseline.log), latest@digest aceptado en
  laboratorio4/default con políticas previas, ahora rechazado en el alcance C05.
- **90 casos distintos con resultado esperado**: 60 éxitos válidos de
  [admission-1](admission-1/results.json) y 30/30 finales de
  [subresources-final](subresources-final/results.json). No una corrida única de 90.
- Siete políticas Ready/Deny/Fail; cuatro con autogeneración conservada y tres
  auxiliares efímeras. Deployment conforme y cuatro rechazos probados.
- Tres namespaces de aplicaciones probados; cinco exclusiones verificadas por
  dry-run. Cuatro creates reales inválidos y tres updates efímeros reales denegados.
- Seis rechazos de API identificados separadamente; no se atribuyen a Kyverno.
- Chart L4 0.3.0, dieciséis recursos admitidos por server dry-run, sin despliegue.
- Perfil minikube-l4-c05 eliminado tras cotejar ID; contexto minikube restaurado.
  Doce contenedores originales preservados, principal detenido; sin volumen/red
  con nombre del perfil de ensayo. No se modificó el entorno principal/Jenkins.

Intentos preservados: primer pase 60/87 por invocación inválida del cliente para
27 subrecursos; segundo 24/30 por fixture de resize y expectativa incorrecta de
rechazo Kyverno; resize corregido 6/6 y grupo final 30/30. No se cuentan errores
de cliente ni rechazos previos al webhook como cumplimiento de una política.

La verificación es de admisión: fixtures sin ejecución, digest sintético, sin
descargas de imágenes por los Pods de prueba. No demuestra rendimiento ni
runtime de la API, estabilidad productiva, HA o ausencia de vulnerabilidades.
Candidato/una réplica conservados. Cinco namespaces exceptuados: **C05-A aceptación
académica abierta; conformidad literal global parcial**. Principal sin ampliación;
C07 aplicación integral y C09 informe/publicación conservan alcance propio.

Preservación por SHA256 y conservación Docker/perfiles en el JSON. Log raíz,
pruebas previas, README general, Word y PDF intactos. C01–C05 sin commit/push/merge.
