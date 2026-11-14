# L4-C03 — copia, restauración y purga de Jenkins dedicado

Fecha: **14/11/2026, Uruguay**. **C03 completa localmente:** copia en frío,
restauración en proyecto vacío, preflight manual **#2 SUCCESS, 22.283 ms** y
purga real del destino comprobados. Origen/curso/otros recursos preservados.

## Alcance y fuente

Bruno solicitó continuar L4-C03. Implementación/pruebas por comandos sobre
Jenkins dedicado C01; las acciones de interfaz las realiza Bruno. Sin ejecutar
el integral, scanners, publicaciones, despliegues ni modificar el informe.
Rama local `lab4/c01-jenkins-reproducible`, HEAD/base
`50a0eb53e7a1152fbe0e4f26252fac2380403fc3`; C01/C02/C03 sin commit/push/merge.

Código: [lifecycle.py](../../ci/jenkins/lifecycle.py),
[pruebas de protección](../../ci/jenkins/test_lifecycle.py),
[guía](../../ci/jenkins/RECUPERACION.md). No depende de bibliotecas Python externas.

## Resultados comprobados

| Comprobación | Evidencia y resultado |
|---|---|
| Inventario inicial | [docker-before.json](docker-before.json): origen activo; C01-repro detenido; Jenkins del curso y otros recursos identificados. |
| Copia inicial y diagnóstico | [backup-primary.txt](backup-primary.txt), [integridad](backup-integrity.txt), [intento inicial](intento-inicial.md). Copia válida, restauración detenida antes de crear recursos por variantes de respuesta de ausencia Docker. No es un PASS de restauración. |
| Copia corregida | [backup-primary-v2.txt](backup-primary-v2.txt), [integridad v2](backup-integrity-v2.txt). Origen detenido durante el tar; dos homes y clave separada. 175.522.629 bytes controlador + 156.145.427 bytes agente; fuente 20.826 bytes. |
| Separación de clave | [archive-check-v2.json](archive-check-v2.json): `master.key` excluida del tar de controlador y presente en el tar separado. Historial #1 y artefactos dentro de la copia. |
| Restauración en destino vacío | [destination-empty.txt](destination-empty.txt), [restore-v2.txt](restore-v2.txt), [arranque](start-restored-v2.txt). Tar compara contenido/metadatos tras extraer cada home y la clave; salida 0. |
| Origen después de reiniciar | [result.json](primary-after-restart/result.json): 67 plugins, UID 1000, agente conectado, TLS, historial #1 y nueve artefactos. Hashes de todos los archivos de jobs/users y marcador idénticos al inicio. Motor/imagen smoke originales conservados. |
| Copia restaurada antes del nuevo build | [result.json](restored-before-build/result.json): mismos 67 plugins, UID, herramientas, cuenta/jobs/historial #1 y nueve artefactos; hashes coincidentes. Motor Docker diferente al del host y al del origen, vacío; TLS regenerado. Integral deshabilitado. |
| Rechazos reales sin modificación | [default](reject-default.txt), [sin confirmación](reject-missing-confirmation.txt), [destino existente](reject-existing-destination.txt). Los tres rechazados, exit 1 esperado. |
| Protecciones automatizadas | [safety-tests.txt](safety-tests.txt): 11 pruebas PASS; propiedad/volumen/red ajenos, actividad Jenkins, confirmación, destino existente, corrupción, errores de ausencia/permisos. |
| Recursos ajenos antes de la purga | [unrelated-before-purge.json](unrelated-before-purge.json): nueve contenedores ajenos al origen/restauración conservan ID, imagen, montajes, RestartCount y estado. Incluye curso, Minikube y secundaria C01-repro. |
| Preflight iniciado por Bruno en la copia | [resultado #2](restored-preflight-2/result.json), [consola](restored-preflight-2/console.txt), [XML original](restored-preflight-2/build.xml) y [hashes](restored-preflight-2/sha256.json): SUCCESS, 22.283 ms, nueve artefactos, commit remoto 50a0eb5, UID 1000 y `PERSISTENCE_REUSED`. BuildKit construyó de nuevo en el motor vacío. No se ejecutó por API. |
| Purga real del destino | [antes](before-purge.txt), [purga](purge.txt), [después](after-purge.txt): tres contenedores, dos redes y cinco volúmenes retirados; inventario final del destino vacío. El #2 queda en los reportes; la copia del home del origen contiene hasta #1. |
| Conservación después de purgar | [final-resources.json](final-resources.json), [inventario posterior](docker-after.json), [origen saludable](primary-final/result.json), [integridad de copia posterior](backup-integrity-after-purge.txt). Doce contenedores, diecinueve volúmenes y once redes originales conservados; origen en 18080 y curso intactos. |

Los montajes se compararon ordenados por destino: Docker devuelve el array en
orden variable. Una primera comparación literal de listas detectó solo esa
diferencia de orden; al comparar contenido no hubo cambios de montajes.

Scripts de lectura reproducibles: [verify-recovery.py](verify-recovery.py) y
[collect-preflight.py](collect-preflight.py); no inician trabajos Jenkins.
El inventario de preservación anterior está en
[preserved-before.json](preserved-before.json).

Comprobación documental final: [final-document-check.json](final-document-check.json).
81 enlaces locales válidos, cuatro fuentes Python parseadas. De 916 archivos
previos, 915 idénticos; solo se actualizó el índice documental de evidencias y
su [copia previa](estado-evidencias-before.md) conserva el hash original.
README/informe, Word/PDF, aplicación/chart, Jenkinsfile y diagnósticos intactos.
Secretos locales ausentes de los entregables nuevos; copias/claves ignoradas.
`git diff --check` sin errores; HEAD conservado, sin commit/push.

## Almacenamiento privado y alcance de recuperación

Ubicaciones reales, **locales e ignoradas**:

- `ci/jenkins/.local/backups/c03-primary-v2-20261114/`: dos homes, fuente y manifiesto/hashes.
- `ci/jenkins/.local/recovery-keys/c03-primary-v2-20261114/`: clave maestra, contraseña de inicialización y hashes.
- Se conservan también las carpetas del intento `c03-primary-20261114`; su fuente
  anterior no supera la comparación de fuente con el script corregido actual.

No se incorporan los archivos privados a este reporte ni al repositorio.
En Windows se comprobaron ACL sin permisos para usuarios generales; la cuenta
Bruno e identidades administrativas/sistema mantienen acceso. La copia no tiene
cifrado adicional. Copia y clave están en carpetas separadas del mismo disco:
no protege de pérdida de máquina y no configura retención externa.

Se recuperan homes de controlador/agente, configuración, cuenta, secretos
cifrados más clave separada, historial/artefactos y workspace/marcador. Se
regeneran los otros tres volúmenes: transporte de agente, certificados y datos
Docker internos. No se copian imágenes/caché de DinD; el preflight puede volver
a construirlas. Las imágenes del host se conservan, no se exportan; restauración
en otra máquina/arquitectura no probada. Fuente e IDs locales exactos exigidos.

No se creó conexión Kubernetes en C03, no se renovaron tokens ni se tocó RBAC.
Una conexión futura necesita revisar destino/red y renovar antes de C07; un
kubeconfig copiado no renueva su vencimiento. DinD root/privilegiado conserva
la excepción C01; controlador/agente no root no implican aislamiento hostil.

## Fuentes de operación

[Jenkins: copia y clave separada](https://www.jenkins.io/doc/book/system-administration/backing-up/)
y [Docker: volúmenes](https://docs.docker.com/engine/storage/volumes/), consultadas
en esta sesión. Evidencia de ejecución local anterior enlazada por separado;
no se infiere una prueba integral de esta recuperación.
