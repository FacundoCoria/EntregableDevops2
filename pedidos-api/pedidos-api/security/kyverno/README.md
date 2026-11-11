# Kyverno — L4-07

Implementación local comprobada el 11/11/2026: Kubernetes 1.37.0,
Kyverno v1.20.0-rc.4, chart 3.10.0-rc.4. Es un candidato de lanzamiento,
instalación de laboratorio de una réplica, sin alta disponibilidad.

## Políticas vigentes

`policies.yaml` contiene cuatro `policies.kyverno.io/v1 ValidatingPolicy` con
`validationActions: [Deny]` y `failurePolicy: Fail`:

| Política | Condición |
|---|---|
| l4-deny-latest-images | Etiqueta explícita diferente de latest o referencia por digest SHA256 |
| l4-require-container-resources | Requests y limits de CPU y memoria por contenedor |
| l4-disallow-root-containers | runAsNonRoot efectivo true; UID explícito/heredado diferente de cero |
| l4-disallow-privileged-containers | privileged ausente o false |

Alcance: solo namespace `laboratorio4`, CREATE/UPDATE de Pods, contenedores
normales e initContainers, incluidos sidecars nativos declarados como initContainers.
Kyverno genera además variantes para controladores de Pods (estado efectivo guardado).
La alternativa por digest admite también `:latest@sha256:...`; ese caso no
se probó en L4-07. No afirmar prohibición literal universal de latest (B09).
No se comprueban ephemeralContainers ni su subrecurso; no son un endurecimiento
completo de Pod Security Standards. No se verifican cantidades positivas ni
proveniencia/firma de las imágenes. La política de imagen no hace validación
criptográfica del digest; esa referencia fija contenido cuando el runtime la resuelve.

`default`, `kyverno`, `kube-system`, `falco` y cualquier otro namespace quedan
fuera del selector. No hay excepciones de política creadas. El escaneo de fondo
está habilitado: no elimina ni corrige recursos existentes.

Los YAML de `../../k8s/kyverno-policies.yaml` se conservan como antecedente E3.
**No aplicarlos como implementación L4:** Kyverno 1.20 no ejecuta los tipos
legacy ClusterPolicy aunque sus CRD sigan presentes. Esta etapa conserva los
tres objetivos previos en CEL y añade la prohibición de privilegiados.

## Reproducir

Desde la raíz del repositorio, con Helm y kubectl disponibles:

```powershell
helm install kyverno kyverno --repo https://kyverno.github.io/kyverno/ --version 3.10.0-rc.4 --kube-context minikube -n kyverno --create-namespace -f pedidos-api/pedidos-api/security/kyverno/values-minikube.yaml --wait --timeout 6m
kubectl --context minikube apply -f pedidos-api/pedidos-api/security/kyverno/policies.yaml
kubectl --context minikube get validatingpolicies
./pedidos-api/pedidos-api/scripts/verify-kyverno.ps1
```

Para la instalación ya realizada usar consultas; no repetir `helm install` sobre
el release existente. El script se niega a sobrescribir el log: antes de repetir,
archivar el log y `reports/l4-07/validation-results.json` en una ruta nueva.
Requiere PowerShell 7. El comando Helm real utilizó el paquete local cuyo SHA256
coincide con el índice oficial: `20c9a1a0d0a31b4f57961abe523ab10a963f05c7b7d89ddc5031391f8c89d310`.

16/16 casos server dry-run exitosos: 13 rechazos y tres aceptaciones; se comprueba
el nombre de la política y el rechazo, evitando confundir un error de conexión
con una validación correcta. Las negativas de initContainers iniciales tenían
nombres duplicados y fallaron antes de Kyverno: intento conservado por separado;
los archivos finales corrigen esos nombres.

También se ejecutaron `kubectl create` sin dry-run sobre los cuatro casos
`containers-latest/resources/root/privileged.json`: cuatro rechazos por webhook.
Un Pod conforme temporal ejecutó `sh -c id`, terminó Succeeded con UID/GID 10001
y se eliminó. No se crearon los Pods inválidos. El chart L4 completo pasó
`kubectl apply --dry-run=server`; no se hizo upgrade ni restart del release l4.

Evidencias: `reports/kyverno-validation.log` y `reports/l4-07/` desde la raíz del
repo. Los archivos son locales, sin commit ni publicación.

## Elección de versión y fuentes

La documentación web indicaba chart 3.10.0 / Kyverno 1.20 para Kubernetes
1.34–1.37; el repositorio consultado aún no ofrecía ese chart estable.
Se fijó el candidato publicado 3.10.0-rc.4 y se verificó funcionamiento real.
Esto no acredita estabilidad productiva ni pruebas de alta disponibilidad.
Antes de actualizar, revisar la publicación estable y repetir la matriz.

- https://kyverno.io/docs/installation/installation/
- https://kyverno.io/docs/installation/releases/
- https://kyverno.io/docs/policy-types/validating-policy/
- https://kyverno.io/docs/guides/migration-to-cel/
- https://kyverno.github.io/kyverno/index.yaml
