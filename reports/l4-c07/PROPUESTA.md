> Acuerdo posterior de Bruno, 14/11/2026: ciclo completo autorizado,
> con cambios GitHub exclusivamente en **trabajo-integrador-4**, conservando
> main. Verificar fuentes oficiales de descargas. La rama nueva sugerida abajo
> queda sustituida; el resto describe la propuesta de referencia.

# C07 — fuente y ejecución integral propuestas

14/11/2026, Uruguay. **Preparación documental; pendiente de acuerdo de Bruno.**
No es evidencia de ejecución ni de reproducción integral completada.

## Fuente concreta

- Repositorio: `https://github.com/FacundoCoria/EntregableDevops2.git`.
- Base local comprobada: rama `lab4/c01-jenkins-reproducible`, HEAD
  `50a0eb53e7a1152fbe0e4f26252fac2380403fc3`, con cambios C01–C06 sin commit.
- Consulta remota de esta sesión: `trabajo-integrador-4` sigue en `50a0eb5`,
  `main` en `ee6bc9333506ddaec1ecb3803bdb812eda0a94ff`.
  `lab4/c01-jenkins-reproducible` y `lab4/c07-integral-final` no aparecen
  en la consulta de heads. No se hizo fetch, pull ni integración.
- Propuesta: crear **`lab4/c07-integral-final`** desde el trabajo local actual,
  incorporar C01–C06 y los ajustes C07 descritos abajo, revisar archivos/secretos
  y publicar un commit candidato. No integrar main ni `métricas-nuevas`.
- Verificar después un clon limpio contra ese commit, con inventario/hash de
  archivos; instalar y ejecutar desde el clon. Registrar el SHA real una vez
  creado: todavía no existe un commit C07 ni se inventa su identificador.
- Usar el mismo SHA completo en SCM del trabajo y en `SOURCE_REF` del build.
  Comprobar Jenkinsfile y código de aplicación; no confundir la rama de revisión
  con una fuente académica final aceptada por el compañero (C08 pendiente).

## Destino y publicación propuestos

| Elemento | Destino propuesto |
|---|---|
| Jenkins nuevo | Proyecto Compose `l4-c07`, puerto local `18083`, volúmenes propios |
| Trabajo | `L4-integral`, solo en ese Jenkins nuevo, iniciado por Bruno |
| Perfil/contexto Kubernetes | `minikube-l4-c07`, nuevo y con identidad registrada |
| Namespace / release | `laboratorio4` / `l4` dentro de ese perfil |
| Chart | `pedidos-api/pedidos-api/helm-chart`, versión local 0.3.0 |
| Nodo observado | `minikube-l4-c07`, pasado explícitamente al chart |
| Registro | `brunovitola/pedidos-api-l4`, sujeto a credencial de Bruno |
| Tag | Único para C07 y cada intento, con build y SHA; evitar colisión con #1 de otros Jenkins |
| Evidencias | `reports/l4-c07/`, subcarpeta nueva por intento |

La imagen se construirá de nuevo desde el commit publicado; no se presentará
el ID local C06 como digest publicado. Guardar tag, digest remoto, configuración
y digest efectivo desplegado. Propuesta: desplegar por digest tras el push.
La limpieza local conservará la rama y la imagen remotas como evidencia;
no se propone borrar tags remotos ni infraestructura previa.

## Ajustes necesarios antes de publicar el candidato

La inspección de archivos identificó estos puntos; **todavía no implementados**:

1. `Jenkinsfile`: defaults B05 y tag basado solo en build/SHA. Preparar defaults
   de candidato, tag C07 único y publicación/despliegue con identidad verificable.
   Mantener gate Snyk real: error o críticos impiden continuar.
2. `ci/deploy.sh`: namespace/release/nombres están fijados y el nodo queda en
   `minikube` por defecto. Hacer explícito el destino C07 y comprobarlo antes de
   mutar; pasar `observability.nodeName` y registrar la identidad desplegada.
3. `ci/jenkins/connect-kubernetes.ps1`: selecciona Compose sin parámetro de
   proyecto. Añadir selección explícita de `l4-c07`, red/API del perfil nuevo,
   token de 24 h y pruebas de permisos, sin tocar al agente C01.
4. `ci/jenkins/init.groovy`: el integral nace deshabilitado en `50a0eb5`.
   Preparar la fuente candidata para instalaciones nuevas; Bruno fijará el SHA
   publicado en el formulario/SCM antes del primer build. El init conserva jobs
   existentes: modificar el archivo no actualiza automáticamente esos trabajos.
5. `scripts/l4/common.sh` y `sandbox.sh`: admiten perfiles principal/B04, y
   sandbox fija B04. Incorporar C07 con comprobaciones de propiedad y sin
   reutilizar/sobrescribir el marcador histórico B04. Separar instalación de
   seguridad/permisos de la instalación de la API que realizará el pipeline.
6. El chart crea ClusterRole/ClusterRoleBinding de monitoreo, mientras el rol
   Jenkins solo puede leerlos por nombre. Preparar **solo ese RBAC de monitoreo**
   desde el chart final con la cuenta local administradora en el perfil C07;
   comprobar nombres, ownership Helm y nodo. No dar permiso global de creación
   de roles a Jenkins para sortear el problema.
7. Verificar scripts/render/Compose y exclusiones Git/Docker. Revisar secretos,
   copias privadas y archivos grandes antes del commit/push; `.local/` excluido.
   No convertir auxiliares externos de sesión en requisitos del clon entregado.

## Secuencia y condiciones de cierre

1. Tras el acuerdo, implementar y verificar los ajustes anteriores, revisar el
   candidato y publicar la rama acordada. Cotejar un clon limpio y registrar SHA.
2. Inventariar recursos previos. Crear perfil y Jenkins nuevos desde el clon,
   registrar identidades y versiones; instalar Kyverno C05 y Falco en ese perfil.
   Preparar namespace y RBAC de monitoreo antes del despliegue por Jenkins.
3. Bruno entra a Jenkins `http://localhost:18083`, inicia sesión y crea las
   credenciales `l4-snyk-token` y `l4-dockerhub`. Guiar cada acción en el momento
   necesario; no copiar credenciales del curso/C01 ni operarlas por interfaz.
   El agente prepara por comandos la conexión limitada al perfil nuevo.
4. Bruno fija SCM y parámetros al SHA candidato, habilita el trabajo y lo inicia.
   Cotejar parámetros efectivos y commit; Semgrep → Snyk/gate → Maven → build/
   push → Helm. Guardar intentos fallidos aparte y no ocultar hallazgos.
5. Comprobar API y tráfico con datos exclusivos C07, métricas/targets y seis
   paneles; Bruno realiza la comprobación visual guiada. Verificar políticas
   C05 operativas y salud de Falco; reutilizar las pruebas de seguridad previas
   que no hayan cambiado, sin atribuirles una ejecución nueva.
6. Analizar con Trivy la imagen efectivamente publicada; si difiere de C06,
   comparar alcance/catálogo y residuales. Snyk sigue enviando metadatos al
   servicio externo según la autorización previa C06. No afirmar cero global.
7. Reiniciar en frío los destinos propios, comprobar historial Jenkins, datos
   H2, servicios y observabilidad; renovar conexión/red solo si corresponde.
8. Guardar artefactos y retirar únicamente los recursos nuevos identificados
   de C07 (túneles, perfil y proyecto/volúmenes de ensayo). Antes de borrar,
   cotejar propiedad/IDs. Verificar conservación de los recursos anteriores.
9. Handoff y registros con resultados reales. El commit ensayado queda fijo;
   evidencias posteriores y coherencia del README/informe se publican mediante
   el alcance C09, sin mover silenciosamente la fuente declarada del ensayo.

## Límites y evidencia de esta preparación

Consulta Docker en vivo: doce contenedores; C01 controlador/agente/DinD activos,
controlador saludable; `jenkins` del curso activo; `minikube` detenido. Los tres
contenedores C01-repro y los otros cinco contenedores están detenidos.
No se arrancó/detuvo ningún servicio. La primera consulta Docker sin elevación
falló por permisos; la consulta de lectura posterior obtuvo el inventario.

C06 conserva, según evidencia del 14/11, JAXB HIGH mitigado sin parche acreditado
y 17 MEDIUM/16 LOW Ubuntu sin fix informado en ese scan. **No se volvió a
consultar proveedores ni a escanear en esta preparación.** C06-R1/R2 deben
reevaluarse con el candidato antes de declarar el ciclo concluido; no quedan
cerrados por este plan. C04-A/C05-A aceptación académica y C08 revisión/merge
siguen pendientes. No equivalen a una prohibición técnica de ensayo aislado.

El acuerdo solicitado comprende ajustes locales, commit/push del candidato,
creación de recursos C07, controles, publicación de imagen, despliegue,
reinicio y limpieza exclusiva del ensayo. No incluye redacción del informe,
merge, contacto con terceros ni modificación del entorno principal.
