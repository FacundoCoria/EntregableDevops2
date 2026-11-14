# C05 — propuesta de alcance

Decisión final: Bruno aceptó ampliar/probar aislado. Ver [alcance final](ALCANCE.md);
la regla candidata de resize se retiró tras comprobar el rechazo de la API.

Fecha: 14/11/2026, Uruguay. Propuesta técnica en preparación; no acredita pruebas.

1. Rechazar `:latest` también antes de `@sha256:...`. Conservar digest sin tag
   y tag explícito distinto de latest. Validar el formato SHA256; esto no verifica
   firma, procedencia ni existencia en un registro.
2. Cubrir todos los namespaces de aplicaciones, incluido `default`. Excluir
   expresamente `kube-system`, `kube-public`, `kube-node-lease`, `kyverno` y `falco`.
   Las exclusiones dejan conformidad literal global parcial; no son aprobación
   docente. No trasladar cargas de aplicaciones a esos namespaces.
3. Conservar cuatro políticas de Pods/autogeneración de controladores. Añadir
   validaciones separadas para `pods/ephemeralcontainers` (imagen, no root y
   privileged), preservando la autogeneración de las políticas originales.
   Evaluar recursos en `pods/resize` para no omitir cambios por ese subrecurso.
4. CPU/memoria requests y limits se exigen a contenedores normales e init,
   incluidos sidecars nativos. Kubernetes prohíbe recursos propios en efímeros;
   no exigir campos inválidos ni presentar esa exclusión como ausencia de control
   de imagen o identidad. Se comprueba la admisión, no el consumo real.
5. Conservar Kyverno v1.20.0-rc.4/chart 3.10.0-rc.4 y una réplica para aislar
   esta corrección. Estable/HA quedan como mejora independiente: no se afirma
   estabilidad productiva. La versión web puede diferir del paquete fijado.
6. Probar en `minikube-l4-c05`, nuevo y descartable. El perfil principal está
   detenido en la consulta inicial y no se modifica. Jenkins y E3 se conservan.
   Sin pipeline integral, publicación, merge ni escritura del informe.

Fuentes oficiales consultadas el 14/11:

- [Contenedores efímeros y recursos prohibidos](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/).
- [ValidatingPolicy y autogeneración](https://kyverno.io/docs/policy-types/validating-policy/).
- [Ejemplo oficial del subrecurso efímero](https://main.kyverno.io/docs/guides/tracing/).
- [Versiones/compatibilidad](https://kyverno.io/docs/installation/releases/).

Antecedentes: `reports/kyverno-validation.log` y `reports/l4-07/` conservados.
Los nuevos intentos y resultados deben quedar en rutas nuevas de C05.
