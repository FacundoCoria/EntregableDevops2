# Parada, copia, restauración y purga de Jenkins dedicado — C03

Ejecutar desde la raíz del repositorio. Requiere Python 3.11+, Docker Linux con
Compose v2, las imágenes C01 ya construidas y el código de esta misma versión.
En Linux sustituir `python` por `python3`. No requiere bibliotecas Python externas.
Esta guía administra exclusivamente proyectos `l4-c01` o `l4-c01-sufijo`.
El contenedor `jenkins` del curso, sus volúmenes, Minikube, `default` y recursos
de otros proyectos quedan fuera del alcance. No usar `prune` para este ciclo.

## Parada con conservación

Esperar que los trabajos terminen y no iniciar otros durante la operación.
El script consulta cola/ejecutores por lectura, detiene agente, controlador y
motor y comprueba la parada antes de copiar. Si hay actividad, falla sin detener.
La consulta usa la contraseña local de inicialización de `bruno`; si la cambiaste
en Jenkins, actualizar ese archivo privado con la contraseña vigente antes de
operar. No imprimirla, pasarla como argumento ni cambiar la cuenta para eludir
un error de autenticación. Si el controlador está detenido, no necesita consulta.

```sh
python ci/jenkins/lifecycle.py status
python ci/jenkins/lifecycle.py stop
python ci/jenkins/lifecycle.py start --port 18080
```

`stop` conserva los tres contenedores, cinco volúmenes y dos redes. `start`
reutiliza esos datos, sin construir imágenes, descargar otras ni iniciar jobs.
Para otra instalación agregar `--project l4-c01-repro` en **cada** comando y
un puerto libre en `start`. No cambiar el proyecto para reiniciar datos existentes.

## Copia en frío

```sh
python ci/jenkins/lifecycle.py backup --backup-id mi-copia-20261114
python ci/jenkins/lifecycle.py check-backup --backup-id mi-copia-20261114
python ci/jenkins/lifecycle.py start --port 18080
```

La copia deja el origen detenido. Si falla, conserva el intento incompleto y
no reinicia automáticamente; revisar la causa y usar un ID nuevo para repetir.
Nunca sobrescribe otra copia. Antes de eliminar recursos, comprobar el resultado
y practicar la restauración en un destino nuevo.

| Ubicación privada bajo `ci/jenkins/.local/` | Contenido |
|---|---|
| `backups/ID/controller-home.tar.gz` | Configuración Jenkins, usuarios, credenciales cifradas, plugins, jobs, historial y artefactos; excluye `secrets/master.key`. |
| `backups/ID/agent-home.tar.gz` | Workspace, marcador de persistencia y archivos del agente; puede incluir kubeconfig/token si se conectó Kubernetes. |
| `backups/ID/source.tar.gz`, `manifest.json`, `sha256.json` | Fuente C01 necesaria, versiones/IDs locales de imágenes, alcance y hashes de integridad. |
| `recovery-keys/ID/master-key.tar.gz` | Clave maestra necesaria para recuperar los secretos cifrados. |
| `recovery-keys/ID/admin-password.txt`, `sha256.json` | Contraseña local de inicialización para Compose y hashes del material de recuperación. |

Las carpetas nuevas son privadas: modo 700 en Linux y ACL restringida en Windows
a la cuenta actual y a identidades administrativas/sistema del equipo; comprobar
que no se otorgue acceso a usuarios generales. `.local/` está excluida de Git y
del contexto Docker. No copiar
estos archivos a `reports/`, al chat ni a una rama. Los archivos son **privados,
sin cifrado adicional**; el SHA256 detecta daños accidentales, no autentica una
copia recibida de terceros. Restaurar únicamente copias propias de confianza.

La clave está separada de la copia siguiendo la
[guía Jenkins](https://www.jenkins.io/doc/book/system-administration/backing-up/).
Aquí ambas carpetas siguen en el mismo disco: esta prueba local no protege de
la pérdida del equipo. Para retención fuera de la máquina, guardar la copia en
almacenamiento protegido y la clave en otra ubicación segura; mantener ambas
fuera del repositorio. No se configuró un servicio remoto por C03.

## Qué se recupera y qué se regenera

Se recuperan los dos homes con sus propietarios, permisos, enlaces y fechas;
la extracción compara cada archivo contra el tar antes de iniciar. Se aplica
la clave maestra separada al home del controlador. Se conservan contraseña y
credenciales existentes en Jenkins; no se exportan credenciales del curso.

Los volúmenes `agent-secret`, `docker-client-certs` y `docker-data` se crean
nuevos. Jenkins vuelve a emitir el secreto del agente; DinD genera certificados
y un motor vacío. **Las imágenes, contenedores internos y caché de builds de
DinD no se copian**: son reproducibles por los builds y no son el historial ni
los artefactos archivados de Jenkins. Las imágenes del host C01 se conservan al
purgar; para recuperar en otra máquina hay que reconstruirlas con la fuente
guardada o transferirlas de forma segura, revisar los IDs y validar allí el ciclo.
La comprobación automatizada actual exige los mismos IDs locales y fuente.

Una unión adicional del agente a la red Minikube no está en Compose. No se
recrea con la restauración; un token copiado conserva su vencimiento. Antes de
C07 revisar destino, renovar conexión y comprobar permisos según
[README C01](README.md). La restauración no crea RBAC ni inicia clústeres.

## Restaurar en un proyecto vacío

Elegir un proyecto nuevo, un puerto libre y conservar el origen. Nunca restaurar
encima de un home existente. Si hubo una extracción parcial, revisar ese destino;
no volver a restaurar sobre él a ciegas.

```sh
python ci/jenkins/lifecycle.py restore --project l4-c01-restaurado --backup-id mi-copia-20261114
python ci/jenkins/lifecycle.py start --project l4-c01-restaurado --port 18082
```

`restore` verifica hashes, fuente e imágenes disponibles antes de crear los dos
volúmenes. No inicia Jenkins. `start` compara los IDs de las imágenes con el
registro local de restauración antes de arrancar Compose. Las etiquetas distintas
se rechazan; no sobreescribir ese registro para forzar una migración no revisada.
Si falta la contraseña local, se recupera del material separado; si existe una
distinta, el script falla sin sobrescribirla.

Bruno abre `http://localhost:18082`, entra con su cuenta restaurada y comprueba
historial/artefactos. En esta instalación C01 conocida no hay trabajos periódicos,
la cola se verificó vacía y `L4-integral` sigue deshabilitado. Verificarlo antes
de repetir el preflight manual `L4-C01-preflight → Build Now`: debe conservar el
build anterior, ejecutar como UID 1000 y producir `PERSISTENCE_REUSED`.
No habilitar el integral para probar recuperación: publica y despliega (C07).

Para una instalación C01 modificada posteriormente con temporizadores/webhooks,
revisar y suspender sus disparadores antes de hacer la copia; el home restaurado
conserva esas configuraciones. No arrancar una copia desconocida conectada a
destinos reales.

## Purga explícita de un proyecto dedicado

Confirmar el nombre exacto y verificar una copia recuperable si sus datos importan.
El ejemplo elimina **solo el destino restaurado**:

```sh
python ci/jenkins/lifecycle.py purge --project l4-c01-restaurado --confirm l4-c01-restaurado
python ci/jenkins/lifecycle.py status --project l4-c01-restaurado
```

La purga verifica nombres y etiquetas Compose, montajes previstos y ausencia de
contenedores ajenos usando los volúmenes/redes. Falla ante recursos adicionales
del proyecto o compartidos. Retira exclusivamente tres contenedores, dos redes y
cinco volúmenes propios. Es irreversible para esos volúmenes: no hay papelera.
Conserva imágenes del host, código, informes, contraseña local, copias y claves.
El registro privado `restores/PROYECTO.json` queda como antecedente; no es un
recurso Docker ni contiene secretos.

Para eliminar también copias o claves locales se necesita una decisión de
retención separada: C03 no las borra automáticamente. Si el agente se conectó a
Kubernetes, la purga Docker no revoca ServiceAccount/Role/RoleBinding; revisar
ese destino con su alcance propio. En C03 no se creó esa conexión.

## Verificación

Pruebas de protección sin Docker:

```sh
python -m unittest discover -s ci/jenkins -p test_lifecycle.py -v
```

Resultado de la prueba real y límites:
[reporte C03](../../reports/l4-c03/VERIFICACION.md). No constituye la ejecución
integral C07 ni publicación C09.

El uso de contenedores auxiliares y tar sobre volúmenes sigue el mecanismo de
[copia/restauración de Docker](https://docs.docker.com/engine/storage/volumes/#back-up-restore-or-migrate-data-volumes).
