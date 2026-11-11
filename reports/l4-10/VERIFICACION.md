# L4-10 — Verificación, 11/11/2026

Resultado: **PASS local**, sin commit ni publicación. Helm 4.3.1, Git Bash/Windows,
Minikube existente. Scripts en `scripts/l4/`, guía en `scripts/l4/GUIA.md`.

## Ejecuciones reales

- Inicio principal con `--jenkins-existing`: revisión Helm 9, Jenkins responde,
  API UP, Prometheus ready, Grafana database ok y tres Deployments disponibles.
  Evidencia: `20261111T175412Z-start-2011/`.
- Tráfico principal: 20 pedidos, 40 lecturas; contador de negocio 0 → 20,
  IDs únicos y exit 0. `20261111T175439Z-traffic-2075/summary.json`.
- Stack temporal `l4-test/laboratorio4-l4test` instalado por el mismo start.
  `integration-final/results.json`: cinco rechazos esperados (contexto/namespace,
  iteraciones, ausencia de confirmación y destino de evidencia existente), tráfico,
  plan, limpieza con retención, reinstalación, tráfico posterior, purga y segunda
  limpieza sin recursos: todos con salidas esperadas.
- Tres PVC conservaron exactamente sus UID al desinstalar. El producto de prueba
  id 1 reapareció después de reinstalar desde H2. Tras purga no quedaron recursos
  del stack ni RBAC de métricas; namespace vacío conserva solo SA/default y CA.
  `integration-final/pvc-*.json`, `test-after.json`, `test-rbac-after.txt`.
- Durante la limpieza temporal, todos los UID de Pods/PVC/Deployments principales
  quedaron iguales. 211 archivos previos (reportes y Word) conservaron SHA256;
  comprobación repetida al cierre. `integration-final/verification.json` y
  `final-verification.json`.
- `start.sh --security` final: PASS, cuatro políticas Ready, Falco disponible y
  salud de los tres servicios. `security-start-final.log` y `final-*.json`.
- Acceso abre tres túneles solo en loopback. La versión final recibe TERM y
  cierra sus tres puertos (conexión rechazada 10061): `access-final.log` y
  `access-closed.json`. Tráfico final de un pedido también cierra su túnel:
  `traffic-final.log`, `traffic-final-closed.json`.
- Sintaxis Bash final: cinco archivos válidos. Prueba final de falta de confirmación
  termina exit 1 con FAIL, sin eliminar nada: `final-failure-trap.log` y directorio
  de evidencia que indica su primera línea. Plan `--security`: PLAN_ONLY en
  `20261111T175932Z-clean-2661/`.

## Diagnósticos conservados y correcciones

- `integration/`: primera limpieza falló por `helm list -a`, opción retirada en
  Helm 4. Se corrigió a `helm list` (todos los estados por defecto en 4.3.1).
  No había ejecutado uninstall; no acredita limpieza exitosa. La serie final
  queda separada en `integration-final/`.
- Inicio de seguridad `20261111T175834Z-start-2646/`: la espera usó condition=Ready,
  pero esta versión publica `.status.conditionStatus.ready`. Se detuvo esa espera,
  se corrigió a espera JSONPath y se repitió con éxito. No fue una caída de Kyverno.
- Primer acceso parecía terminar, pero comprobación real de sockets detectó
  kubectl huérfanos: se estaba siguiendo el PID de una función/subshell Bash.
  Se corrigió lanzando kubectl directamente. Los 19 túneles de las primeras
  pruebas se retiraron por su comando exacto; registro `initial-tunnels-retired.json`.
  No usar `access-test.log` como prueba de cierre; prevalecen las pruebas finales.

## Límites

Inicio probado sobre perfil Minikube/Jenkins existentes; no se acredita una
máquina desde cero ni el arranque de un perfil apagado. Jenkins se reutiliza:
no se aprovisionan plugins, trabajos o credenciales. No se ejecutó el retiro
real de Kyverno/Falco sobre el stack principal: esa opción tiene plan comprobado
y comandos documentados, pero no prueba destructiva de extremo a extremo.
CRD/namespaces e infraestructura compartida quedan fuera de la limpieza.
No se repiten los análisis Snyk/Trivy ni la matriz de admisión/Falco anterior.
El tráfico deja 21 pedidos de prueba en H2 principal; los del stack temporal se
eliminaron con sus PVC. El namespace temporal vacío se conserva intencionalmente.
