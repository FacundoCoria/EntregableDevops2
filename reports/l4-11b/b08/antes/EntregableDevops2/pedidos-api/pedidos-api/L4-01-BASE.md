# L4-01 — Base Docker y manifiestos

Implementación local del 10/11/2026 sobre main remoto `489f9f3`, rama `lab4/l4-01-docker-manifiestos`. No publicada.

## Componentes y decisiones

| Componente | Imagen/configuración | Datos |
|---|---|---|
| API Java 21 / Spring Boot 4.1.1 | Dockerfile propio, build JDK → runtime JRE Temurin 21.0.13+9; bases fijadas por digest | H2 embebida, `/data/pedidos`, UID/GID 10001 |
| Prometheus | Imagen oficial v3.16.0 fijada por digest; UID/GID 65534 | PVC 1 GiB, `/prometheus`, retención 7 días |
| Grafana | Imagen oficial 13.0.12 fijada por digest; UID/GID 472 | PVC 1 GiB, `/var/lib/grafana` |

No hay frontend propio ni servidor H2 separado. Las imágenes oficiales de monitoreo se usan directamente, sin Dockerfiles que solo repitan un FROM. Jenkins y las herramientas de seguridad se incorporarán en sus etapas; esta base no acredita todavía contenerización de todo el integrador.

El Dockerfile ejecuta `clean verify` usando Maven Wrapper 3.9.16. La prueba de contexto usa H2 en memoria; la prueba de contenedor verifica por separado H2 en disco. Solo el JAR pasa a la imagen runtime, sin compilador ni caché Maven. `.dockerignore` excluye target, reportes y datos locales. La aplicación corre como 10001:10001 y `/data` pertenece a ese usuario.

Los tres Deployments tienen requests/limits, usuario no root, capacidades eliminadas, escalada deshabilitada y seccomp RuntimeDefault. Los PVC usan fsGroup para permitir la escritura sin un init container root. La aplicación tiene sondas de arranque, disponibilidad y liveness. La configuración Kubernetes deshabilita la consola H2 y activa las sondas de Actuator.

H2 requiere **una sola réplica** y estrategia Recreate: no se debe escalar esta base ni superponer dos procesos sobre el archivo. Eso implica una interrupción durante actualizaciones. Un despliegue con alta disponibilidad requiere otra arquitectura de base de datos. El almacenamiento depende de una StorageClass por defecto y de un driver compatible con los permisos; todavía se verificará en L4-03.

## Comandos reproducibles

Desde la raíz del repositorio:

```powershell
docker build --progress=plain -t pedidos-api:l4-01 pedidos-api/pedidos-api
& ./pedidos-api/pedidos-api/scripts/verify-container.ps1 -EvidenceDir ./reports/l4-01
kubectl kustomize pedidos-api/pedidos-api --output ./reports/l4-01/manifiestos-renderizados.yaml
Get-Content -Raw ./reports/l4-01/manifiestos-renderizados.yaml | docker run --rm -i ghcr.io/yannh/kubeconform:v0.7.0 -strict -summary -kubernetes-version 1.35.0
```

El verificador crea nombres únicos, publica un puerto temporal solo en localhost y usa un volumen nuevo. Comprueba usuario, salud, liveness, métricas y persistencia después de eliminar y recrear el contenedor. Elimina sus contenedores y, si pasa, su volumen; si falla conserva el volumen para diagnóstico. No toca los volúmenes existentes.

`kustomization.yaml` enumera los recursos de aplicación y monitoreo y genera el ConfigMap Prometheus desde el archivo existente; excluye políticas y Pods de pruebas negativas. No aplicar recursivamente todos los YAML. El nombre generado del ConfigMap se incorpora automáticamente al Deployment. Si cambia el archivo prometheus.yml, se debe volver a renderizar el conjunto.

La etiqueta `pedidos-api:l4-01` es local, todavía no está publicada. Antes de desplegar con Minikube deberá cargarse allí o reemplazarse por una imagen publicada. `IfNotPresent` permite ambos modos. Los Services conservan NodePort; puertos de acceso, instalación y pruebas de PVC en el clúster se documentarán en L4-03. Las versiones de monitoreo fueron resueltas en el registro, pero no se arrancaron sus servicios en esta etapa; datasource/dashboard pertenecen a L4-04.

## Verificación del 10/11

- Build correcto: una prueba Maven, cero fallos, errores y omisiones.
- API bajo límite de 768 MiB y una CPU: usuario 10001:10001; salud y liveness UP; métricas JVM expuestas.
- Producto creado y recuperado con el mismo ID/nombre/precio después de recrear el contenedor: persistencia H2 comprobada.
- Kustomize renderizado y 11 recursos válidos con Kubeconform 0.7.0/esquemas Kubernetes 1.35.0: cero inválidos, errores u omisiones. Esto no prueba admisión Kyverno ni ejecución en clúster.
- Los 13 archivos históricos de `reports/` permanecen con las mismas huellas SHA256. Los nuevos registros de esta sesión están fuera del repositorio, en [evidencias locales de L4-01](../../../handoffs/evidencias_l4_01_2026-11-10/).

Dive y el análisis de vulnerabilidades de esta imagen corresponden a L4-02. Los resultados Trivy antiguos no se atribuyen a esta imagen. No se modificaron las dependencias Maven ni se integró métricas-nuevas.

Referencias de diseño: [Docker multi-stage](https://docs.docker.com/build/building/multi-stage/) y [contextos de seguridad Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/).
