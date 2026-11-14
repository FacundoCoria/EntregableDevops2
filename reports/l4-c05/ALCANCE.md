# C05 — alcance literal de Kyverno y decisión aplicada

Fecha: **14/11/2026, Uruguay**. Bruno eligió «Ampliar y probar aislado».
Implementación y verificación locales; aceptación académica global pendiente.

## Decisión y excepción frente a la consigna

La consigna 5.3 pide prohibir latest, exigir CPU/memoria en todos los Pods,
impedir root y añadir una buena práctica. C05 conserva esos cuatro objetivos,
amplía los espacios de aplicaciones y cubre la incorporación de efímeros.

| Objetivo | Recurso / tipos | Decisión probada |
|---|---|---|
| Imagen | Pods; normales, init y sidecars nativos | Rechazar latest, también latest@digest; admitir tag distinto o SHA256 de 64 hexadecimales. |
| Recursos | Pods; normales, init y sidecars nativos | Presencia de requests y limits CPU/memoria por contenedor. |
| Identidad | Pods; normales, init y sidecars nativos | runAsNonRoot efectivo true y UID explícito/heredado no cero. |
| Buena práctica | Pods; normales, init y sidecars nativos | privileged ausente o false. |
| Imagen / identidad / privilegios | UPDATE pods/ephemeralcontainers | Tres reglas auxiliares con los mismos criterios, incluida herencia del Pod. |
| Cambio de recursos | pods/resize | Cambio conforme aceptado; quitar un límite rechazado por la API, sin atribuirlo a Kyverno. |

Las cuatro políticas principales mantienen autogeneración para controladores;
se probó un Deployment conforme y cuatro no conformes. Las auxiliares están
separadas para conservar ese match de Pods. Hay **siete objetos** para cuatro
objetivos: no se reemplaza la política adicional por una mera duplicación.
Todos Deny/Fail; fondo habilitado en las cuatro principales, auxiliares solo
admisión. No elimina ni corrige recursos existentes.

Selector de namespaces por nombre `NotIn`: se exceptúan `kube-system`,
`kube-public`, `kube-node-lease`, `kyverno` y `falco`. El resto incluye `default`,
`laboratorio4` y nuevos namespaces de aplicaciones, sin etiqueta opt-in.
Las excepciones preservan infraestructura y operación del webhook/sensor
privilegiado; los filtros globales del chart también se conservaron y están
registrados. No se crearon PolicyException. No ubicar aplicaciones en espacios
exceptuados. Un administrador con permisos para alterar políticas/webhooks/RBAC
puede cambiar estos controles; no se afirma resistencia frente a ese actor.

**C05-A abierto:** la consigna no exime literalmente esos namespaces. La decisión
técnica está cerrada por Bruno; aceptación docente no localizada en lo revisado.
No afirmar conformidad literal global ni cobertura universal. Si el docente
exige ampliar excepciones, acordar componentes y probar en otro destino aislado.
No se envió ninguna consulta a terceros.

Kubernetes prohíbe recursos propios en efímeros: exigirlos bloquearía incluso
su uso conforme. El rechazo de esa asignación se probó por la API en los tres
namespaces de prueba. Imagen, identidad y privilegios sí son controles Kyverno.
Para resize se retiró una regla candidata redundante: la API ya impidió quitar
límites en los casos probados. `pods/status` no modifica la spec; no se añade
una regla de spec para ese subrecurso. No se ensayan todos los subrecursos
posibles ni Pods estáticos fuera de la admisión del API server.

Se mantiene **v1.20.0-rc.4/chart 3.10.0-rc.4 y una réplica** para separar esta
corrección de un upgrade. No se considera estable ni HA/productivo. Migración a
estable o HA es una mejora separada: la consigna no fija esas condiciones.
`Fail` puede bloquear admisiones si el controlador no responde. No se probó caída
del webhook. La web oficial puede describir versiones distintas del paquete
fijado; C05 no se basa en declarar ese candidato como la última versión.

Otros límites: se exige presencia de cantidades, sin nueva regla de positividad;
el patrón del digest no verifica firma, existencia ni contenido de la imagen;
no es cumplimiento completo de Pod Security Standards ni remediación de CVE.
El principal está detenido y se conserva con las políticas previas: esta mejora
solo se aplicó al perfil descartable. Aplicación final C07 y publicación C09.

## Reproducción en perfil nuevo

Desde la raíz del repo, con Docker, Minikube, Helm, kubectl y Python 3 en PATH.
Primero comprobar que `minikube-l4-c05` no existe; si existe, revisar propiedad
antes de reutilizar o borrar. Nunca usar `minikube` como destino de esta prueba.

```powershell
minikube profile list
minikube start -p minikube-l4-c05 --driver=docker --container-runtime=containerd --kubernetes-version=v1.37.0 --memory=2800 --cpus=2 --keep-context
helm install kyverno kyverno --repo https://kyverno.github.io/kyverno/ --version 3.10.0-rc.4 --kube-context minikube-l4-c05 -n kyverno --create-namespace -f pedidos-api/pedidos-api/security/kyverno/values-minikube.yaml --wait=legacy --timeout 6m
kubectl --context minikube-l4-c05 create namespace laboratorio4
kubectl --context minikube-l4-c05 create namespace c05-second
kubectl --context minikube-l4-c05 create namespace falco
kubectl --context minikube-l4-c05 apply -f pedidos-api/pedidos-api/security/kyverno/policies.yaml
kubectl --context minikube-l4-c05 wait '--for=jsonpath={.status.conditionStatus.ready}=true' -f pedidos-api/pedidos-api/security/kyverno/policies.yaml --timeout=120s
python pedidos-api/pedidos-api/scripts/verify-kyverno-c05.py --report-dir reports/c05-nueva-ejecucion
```

El verificador solo admite ese contexto; exige carpeta nueva, genera fixtures
JSON y log completo, distingue Deny por nombre de política de error de cliente/API,
y retira sus Pods. `--suite subresources` repite solo ese grupo. Los fixtures
reales tienen programación bloqueada; no ejecutan contenedores ni descargan
imágenes. Se prueban referencias con digest sintético solo para admisión.

La instalación real usó el paquete oficial local SHA256
`20c9a1a0d0a31b4f57961abe523ab10a963f05c7b7d89ddc5031391f8c89d310`,
ya contrastado con el índice en L4-07. No repetir install sobre un release
existente. Al terminar, comprobar identidad/propiedad del destino antes de
`minikube delete -p minikube-l4-c05`; restaurar el contexto previo si se limpia.
La sesión C05 guardó el ID de contenedor antes del retiro y comprobó conservación.

Fuentes oficiales consultadas el 14/11/2026:

- [Kyverno ValidatingPolicy/autogeneración](https://kyverno.io/docs/policy-types/validating-policy/).
- [Ejemplo oficial del subrecurso efímero](https://main.kyverno.io/docs/guides/tracing/).
- [Kubernetes: efímeros y recursos prohibidos](https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/).
- [Versiones y compatibilidad Kyverno](https://kyverno.io/docs/installation/releases/).

[Verificación y comparación](VERIFICACION.md), [JSON](verificacion.json).
