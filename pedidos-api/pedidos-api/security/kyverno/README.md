# Kyverno — ampliación C05

**14/11/2026: variante local C05 implementada y probada en clúster descartable.**
Bruno eligió ampliar y probar aislado. `policies.yaml` contiene siete
ValidatingPolicy: cuatro objetivos sobre Pods y tres reglas sobre el subrecurso
`pods/ephemeralcontainers`. Sin commit/push. El principal no recibió esta variante;
conserva el antecedente L4-07 de cuatro políticas para `laboratorio4`.

- Se rechaza `latest` también antes de `@sha256:...`. Se admite tag explícito
  distinto de latest o digest SHA256 de 64 caracteres hexadecimales; no verifica
  firma, procedencia ni existencia de la imagen.
- Se cubren namespaces de aplicaciones, incluidos `default` y espacios nuevos
  sin etiqueta opt-in. Se exceptúan expresamente `kube-system`, `kube-public`,
  `kube-node-lease`, `kyverno` y `falco`. **Conformidad literal global parcial**:
  la aceptación docente de estas excepciones queda pendiente C05-A.
- Contenedores normales e init, incluidos sidecars nativos: imagen, recursos,
  no root y no privileged. Se conserva la autogeneración para controladores;
  Deployment conforme y cuatro rechazos comprobados.
- Contenedores efímeros: imagen, no root y no privileged mediante tres reglas
  separadas. Kubernetes prohíbe sus recursos propios. En `pods/resize`, la API
  admitió un cambio válido y rechazó retirar límites; ese rechazo no es Kyverno.
- Candidato v1.20.0-rc.4/chart 3.10.0-rc.4 y una réplica conservados para aislar
  esta corrección; actualización/HA son mejoras separadas. No afirmar estabilidad
  productiva ni cobertura retroactiva/universal. No se cubren Pods estáticos
  fuera de admisión ni se ensaya cada subrecurso posible de Kubernetes.

[Alcance, excepciones y reproducción C05](../../../../reports/l4-c05/ALCANCE.md),
[verificación](../../../../reports/l4-c05/VERIFICACION.md) y
[JSON consolidado](../../../../reports/l4-c05/verificacion.json).
90 casos distintos con resultado esperado: 60 del primer pase y 30 finales de
subrecursos, con procedencia por caso. Intentos fallidos separados y preservados.
Incluye siete rechazos reales (cuatro creates y tres updates efímeros). Los
fixtures conformes fueron Pods sin ejecución; el chart de 16 recursos pasó
server dry-run. No equivale a ejecución de la aplicación ni al integral C07.

Para repetir, usar el perfil nuevo/descartable `minikube-l4-c05`, nunca el
principal, y una carpeta de resultados nueva. El verificador Python 3 usa solo
la biblioteca estándar y no instala políticas ni servicios:

```powershell
python pedidos-api/pedidos-api/scripts/verify-kyverno-c05.py --report-dir reports/c05-nueva-ejecucion
```

La preparación completa está en el alcance enlazado. La ejecución final completa
espera 90 resultados; esta sesión consolidó los grupos sin repetir 60 pruebas
ya válidas. El log original `reports/kyverno-validation.log` sigue intacto y
la nueva evidencia está en `reports/l4-c05/`. C09 mantiene el informe/publicación;
C07 mantiene la aplicación al destino final. E3 pausado.

## Antecedente L4-07 — estado del 11/11/2026

**Todo lo siguiente describe la implementación anterior, no la variante C05.**
Sus pruebas y límites se conservan para comparación. La entrega previa fue
publicada posteriormente en trabajo-integrador-4/50a0eb5 el 13/11; las referencias
a archivos locales sin publicar corresponden al momento original de L4-07.

Implementación local comprobada el 11/11/2026: Kubernetes 1.37.0,
Kyverno v1.20.0-rc.4, chart 3.10.0-rc.4. Es un candidato de lanzamiento,
instalación de laboratorio de una réplica, sin alta disponibilidad.

### Políticas probadas en L4-07

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
