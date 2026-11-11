# Helm local — L4-03 y L4-04

Chart `pedidos` 0.2.1: API Java/H2, Prometheus y Grafana. Son dieciséis recursos:
tres Deployments, tres Services ClusterIP, tres PVC, cuatro ConfigMaps y tres recursos de cuenta/RBAC. Los nombres
incluyen el release; los selectores combinan release y componente. No administra
los manifiestos anteriores de `default`, políticas, operadores ni Jenkins.

## Requisitos y configuración

Verificado con Helm 4.3.1, Minikube 1.39.0, Kubernetes 1.37.0/containerd 2.3.4,
driver Docker en Windows. StorageClass por defecto `standard`, hostpath local.
API: imagen exacta `pedidos-api:l4-01` de L4-01/L4-02, sin reconstruir ni publicar.
Su configuración OCI es `sha256:1cb073e6aa69c2f35d61a2cbeb5816e06e5e54daed81f4cad580992102e22b72`.
Conserva once hallazgos HIGH/CRITICAL abiertos de L4-02; no es una aprobación de seguridad.

`values.yaml` configura imágenes, recursos, tamaños de PVC, StorageClass, título y
entorno. `values-dev.yaml` cambia el título, activa perfil `dev` y exige la imagen
API local con `Never`. No hay propiedades Java específicas del perfil: los valores
comunes siguen aplicándose. Los puertos y rutas de datos son contratos fijos de las
imágenes y del chart, validados por esquema; no son opciones libres. Se rechaza
`latest` y campos desconocidos. No se ofrece un perfil productivo sin validarlo.

Una réplica y `Recreate` en los tres componentes; H2 requiere un único escritor.
Los tres contenedores se ejecutan sin root, con recursos, sondas HTTP y volúmenes
con fsGroup. La API deshabilita consola H2. Un checksum de ConfigMaps provoca
recreación al cambiar configuración. Las imágenes de monitoreo conservan los digests
de L4-01. Configuración Prometheus apunta al Service del release.

## Instalación reproducible

Desde `pedidos-api/pedidos-api/`, con Helm y las herramientas en PATH:

```powershell
minikube start -p minikube
minikube -p minikube image load pedidos-api:l4-01
helm lint ./helm-chart --strict
helm lint ./helm-chart -f ./helm-chart/values-dev.yaml --strict
helm install l4 ./helm-chart --kube-context minikube --namespace laboratorio4 --create-namespace -f ./helm-chart/values-dev.yaml --wait --timeout 6m
kubectl --context minikube -n laboratorio4 get pods,pvc,svc
```

Si ya existe el release, actualizar con `helm upgrade l4 ./helm-chart` y las mismas
opciones de contexto/namespace/values/wait. No reinstalar sobre recursos retenidos.
En este equipo Helm está en `.tools/helm/windows-amd64/helm.exe` desde la carpeta
general del proyecto, fuera del repositorio. No requiere instalación global.

## Acceso y verificación

Se omite Ingress porque el alcance es local; no requiere controlador, DNS ni
publicación. Cada port-forward debe permanecer activo mientras se usa su URL:

```powershell
kubectl --context minikube -n laboratorio4 port-forward svc/l4-pedidos-api 18080:8080 --address 127.0.0.1
kubectl --context minikube -n laboratorio4 port-forward svc/l4-pedidos-grafana 13000:3000 --address 127.0.0.1
kubectl --context minikube -n laboratorio4 port-forward svc/l4-pedidos-prometheus 19090:9090 --address 127.0.0.1
```

- API: `http://127.0.0.1:18080/actuator/health`, resultado `UP`.
- Grafana: `http://127.0.0.1:13000/api/health`, base `ok`.
- Prometheus: `http://127.0.0.1:19090/-/ready`, servidor listo.

Bruno opera las interfaces con guía. Los comandos anteriores son la referencia
reproducible del trabajo técnico; no hace falta que Bruno los ejecute para continuar.
Datasource, dashboard y métricas por pod se provisionan en L4-04. Consultar
[OBSERVABILIDAD-L4.md](../OBSERVABILIDAD-L4.md) para fuentes, consultas, permisos,
verificación y límites. `observability.nodeName` configura el nodo observado.

```powershell
./scripts/verify-helm.ps1 -EvidenceDir ./helm-evidence
```

Este verificador abre conexiones temporales solo en loopback, consulta salud de
los tres servicios, crea un producto, recrea el pod API y recupera el mismo
producto/precio desde el mismo PVC. Conserva evidencia y cierra sus conexiones.
Requiere puertos locales 18080, 13000 y 19090 libres. Deja el producto de prueba
como evidencia, y no borra volúmenes ni recursos del clúster.

## Datos y límites

Los PVC tienen `helm.sh/resource-policy: keep`: desinstalar el release conserva
los datos y exige gestionar explícitamente los PVC antes de reutilizar el nombre.
Un borrado manual de namespace/PVC puede eliminar datos; no forma parte de esta
etapa. `standard` no permite expandir los PVC; dimensionarlos antes de instalar.
Hostpath y H2 no ofrecen HA ni respaldo. No se probó recuperar tras perder el nodo.

La instalación anterior en `default` sigue presente. En el clúster local revisado
no está instalado Kyverno; esta instalación no acredita sus políticas. No hay
prueba Helm hook (`helm test`); la verificación funcional es el script anterior.
Los servicios permanecen desplegados al cerrar el chat; los port-forward de las
pruebas se cierran. No se modifican reportes históricos ni el informe E3.

Referencias oficiales: [Helm install](https://docs.helm.sh/docs/intro/using_helm/),
[values por entorno](https://docs.helm.sh/docs/v3/chart_template_guide/values_files/),
[imágenes locales en Minikube](https://minikube.sigs.k8s.io/docs/tasks/docker_daemon/).
