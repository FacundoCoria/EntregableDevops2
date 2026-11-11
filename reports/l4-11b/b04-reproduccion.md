# B04 — reproducción y limpieza, 11/11/2026

**Ciclo Kubernetes verificado; reproducción global parcial por Jenkins heredado.**
Perfil nuevo `minikube-l4-b04`, Docker, Minikube 1.39.0, Kubernetes v1.37.0,
containerd, 2800 MiB/dos CPU. Helm 4.3.1; chart API 0.3.0, imagen publicada
#7 por digest; Kyverno chart 3.10.0-rc.4 y Falco chart 9.2.2. Docker y CLI
preinstalados; no es una máquina recién aprovisionada.

## Implementación y resultado

- `scripts/l4/sandbox.sh`: plan por defecto, creación de perfil ausente,
  identidad Docker registrada y eliminación restringida al perfil dedicado.
- `common.sh`: admite exclusivamente los contextos principal y B04.
- `start.sh`: métricas del nodo según contexto; Jenkins heredado solo principal.
- `clean.sh`: propiedad de los tres PVC validada antes de cualquier retiro.
- `B04-REPRODUCCION.md`, enlace desde GUIA y notas Helm sin contexto principal
  fijo. No se escribió el informe integrador ni se completó B08 global.

Resultados observados, sin extrapolar desde L4-10:

1. Plan sin mutaciones y rechazos por confirmación ausente/principal y contexto
   inválido. Sintaxis de siete scripts comprobada.
2. Perfil nuevo, tres servicios saludables, cuatro políticas Ready, Kyverno y
   Falco disponibles; targets API y kubelet UP sobre nodo B04.
3. Identidad de perfil incorrecta rechazada antes de borrar. Propietario de PVC
   ajeno rechazado antes de desinstalar; UIDs de Deployments conservados.
   Fixtures restaurados antes de seguir.
4. Dos pedidos correlacionados; apagado/arranque real del perfil; tres servicios,
   seguridad y targets recuperados. Producto H2 persistente, un pedido posterior
   correlacionado. No se afirma persistencia de contadores del proceso.
5. Retiro real de aplicación/tres PVC/políticas/Kyverno/Falco; ausencia de Pods
   activos, Deployment, DaemonSet, PVC y Service en sus tres namespaces, y RBAC
   de métricas retirado. Segunda limpieza exitosa. Se conservan namespaces,
   algunas CRD/ConfigMap y un Pod Succeeded del hook de migración de Kyverno.
6. Eliminación total del perfil con sus CRD/namespaces/volúmenes; ausencia del
   perfil, contenedor y volumen Docker del mismo nombre verificada.
7. Segundo ciclo con archivos estables: `sandbox.sh create` desde perfil ausente
   hasta PASS, cinco componentes disponibles, y `sandbox.sh delete` hasta PASS.
   Este último retiro también prueba eliminación directa con workloads activos.

## Intento inicial y recuperación

`create.txt`/`create/result.txt` conservan exit 127 (`se: command not found`):
se editó start.sh mientras Bash lo leía, después de instalar seguridad. Es fallo
de ejecución, no reproducción exitosa. `fresh-start-retry.txt` acredita recuperación
con archivo estable. El segundo ciclo completo en `final-create/` acredita la
versión final de sandbox.sh, con evidencia interna en `final-create/start/`.
No se ocultó ni sobrescribió el diagnóstico inicial. La auditoría posterior
también conservó sus dos errores: exigía cero Pods aun con un hook Succeeded,
y consultó políticas cuando su CRD ya había sido retirada. Se corrigió el
auditor para reconocer únicamente ese hook completado y comprobar primero
la existencia de la CRD. No fueron fallas del retiro Helm ni se interpretaron
como pruebas aprobadas. Ver verification-initial-error.txt y after-clean-policies.txt.
El primer retiro también dejó current-context vacío: restaurado a minikube,
conservando el fallo de auditoría en main-after-current-context.txt. Se agregó
restauración explícita del contexto anterior a sandbox.sh; el segundo ciclo
comprueba esa corrección. Los objetos del clúster principal no se modificaron
por esa pérdida temporal de selección.

## Evidencia y límites

Evidencias locales en [b04/](b04/), resultados
[verification.json](b04/verification.json) y [final-cycle.json](b04/final-cycle.json).
`fresh-targets.json`, `recovered-targets.json`, logs de tráfico, cold-stop/restart,
after-clean y main-before/after permiten revisar cada afirmación.
El inicio del primer ensayo quedó en `reports/l4-10/20261111T184722Z-start-1026/`;
es evidencia B04, no una repetición atribuida a L4-10. El segundo ciclo usa ruta
anidada específica, para evitar esta confusión.

525 archivos previos de reportes/Word/PDF intactos por SHA256. Release
principal l4 revisión 10, especificaciones/UIDs de aplicación y controladores
principales, ID/imagen/fecha de arranque de Jenkins y contexto activo preservados.
No se prueba ausencia de cambios periódicos de status ni se afirma que no hubo
ningún reinicio interno por esa sola comparación. Sin túneles propios restantes.

Jenkins/plugins/jobs/credenciales desde cero y limpieza de su volumen no se
implementaron. Son infraestructura heredada compartida: B04 global permanece
parcial y enlaza B02/B05. No borrar entorno principal/default para demostrar
limpieza. Cachés de imágenes/CLI del host se conservan; no son recursos del
perfil eliminado. Imágenes/reglas transitivas de seguridad no son todas inmutables.
Sin nuevos scans, build/push, commit, publicación de código ni Word.
Rama `lab4/l4-01-docker-manifiestos`, HEAD `489f9f37a2275a5e284769fdbb511c0855c1c384`; cambios acumulados locales.
