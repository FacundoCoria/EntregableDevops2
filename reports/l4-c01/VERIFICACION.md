# L4-C01 — Jenkins reproducible desde cero

Fecha: 13/11/2026, Uruguay. **C01 completa: implementación, pruebas por comandos
y preflight manual Jenkins #1 SUCCESS.** Evidencia nueva local, no publicada.
Base Git: `50a0eb53e7a1152fbe0e4f26252fac2380403fc3`, rama de trabajo
`lab4/c01-jenkins-reproducible`, cambios sin commit.

## Resultado técnico

**Cierre posterior a la confirmación de Bruno:** `L4-C01-preflight` **#1 SUCCESS**,
22.337 ms, iniciado por bruno desde la UI y ejecutado en `l4-agent` UID 1000.
Tres etapas completas: herramientas, clon del commit publicado `50a0eb5` y build
BuildKit local `l4-c01-smoke:local`. Nueve artefactos en `preflight-1/evidence/`,
XML original, consola original/legible, resumen y SHA256 guardados en
[preflight-1/](preflight-1/). El marcador del primer build es `PERSISTENCE_CREATED`;
la persistencia en frío está acreditada por comandos en la instalación secundaria,
no por un segundo build Jenkins. Sin push, scans ni despliegue.

- Jenkins LTS 2.580.2 descargado desde Docker Hub por digest amd64; cliente/motor
  Docker 29.7.2 también fijados por digest. Ver `ci/jenkins/images.env`.
- Cierre de 67 plugins/dependencias fijado; SHA256 oficial comprobado en build
  (`override-build.log`, originalmente comprobado también en `final-start.log`).
  Versiones efectivas y carga activa comprobadas en el inicio y `jenkins-state.json`.
- Controlador y agente UID/GID 1000; cero ejecutores en controlador, uno en agente.
  Dos redes propias, sin socket del equipo ni volúmenes del curso.
- Docker-in-Docker dedicado, TLS 2376 sin publicación de puertos. ID del motor
  del agente distinto del ID del host, capturado en cada `result.json`.
  DinD es **root/privilegiado**; no afirmar que todo el stack es no root ni que
  ofrece aislamiento frente a código hostil. No controla el motor del curso.
- Maven 3.9.16, Snyk 1.1308.4, Helm 4.3.1, kubectl 1.37.0 y Semgrep 1.184.0:
  comprobación positiva al construir y reutilizar; rechazo real del fixture
  Snyk 0.0.0. Versiones Java/Python/Git/curl y paquetes apt/Python registradas.
- Segunda instalación desde volúmenes vacíos (`l4-c01-repro`, 18081): arranque
  saludable con cuenta, dos trabajos y agente; `fresh-final-start.log` y
  `verification-fresh-final/result.json`: PASS, 67 plugins.
- Parada e inicio en frío de esa segunda instalación: mismos hashes de cuenta,
  configuración de los dos trabajos, marcador del controlador y marcador del
  agente; imagen local `l4-c01-smoke:persistence` conservada por mismo ID.
  Comparar `cold-before-controller.txt`/`cold-after-controller.txt` y las últimas
  dos líneas de `cold-before-agent.txt` contra `cold-after-agent.txt`.
- Buildx v0.36.1 incluido desde la imagen CLI fijada; build local con BuildKit
  exitoso en `buildkit-smoke.log`. Verificación de la imagen final después del
  ciclo: `verification-final-after-cold/result.json`: PASS.

La instalación `l4-c01` queda disponible en 127.0.0.1:18080, agente final aplicado
antes de que hubiera builds. La segunda instalación quedó **detenida**, conservando
sus cinco volúmenes, redes y contenedores para el alcance C03. Ninguna purga.

Jenkins del curso conservó contenedor
`d70aedf9e47bc8b601013fc6d0ed899fdccc9781e435ed565e61a737e7c7f7ab`, imagen
`sha256:99ea0037369f4639f495e5646bfef6b1820aa1b714a95b0e23e2edea1da76702`,
RestartCount 0 y sus dos montajes originales. Capturas restringidas en
`original-jenkins-after.txt` y `original-jenkins-final.txt`; identidad previa
comprobada en la sesión antes de crear C01. Minikube permaneció detenido.

## Intentos y correcciones conservados

1. `initial-start.log`/`first-boot.log`: creación y agente conectado correctos.
2. `final-start.log`: intento posterior termina unhealthy porque el home existente
   conservaba el script init anterior. No prueba fallo de los plugins (67 hashes OK).
   Corrección: `l4.groovy.override` actualiza el hook entregado al reiniciar;
   la configuración de cuentas/jobs existentes sigue conservándose. Arranque
   posterior y segunda instalación verificados. Este error se mantiene separado.
3. Build local inicial usa builder legacy porque se había copiado solo Docker CLI.
   Se añadió Buildx oficial fijado por la misma imagen base.
4. `buildkit-smoke-initial.log`: error porque `/tmp/c01-smoke` desapareció al
   recrear el agente (capa efímera, no volumen). Fixture recreado en home persistente;
   `buildkit-smoke.log` acredita éxito posterior. No confundir el intento fallido
   con un build completado.

## Alcance y pendientes

- [x] ~~Bruno inicia L4-C01-preflight y se guardan SUCCESS/artefactos.~~
  **13/11: #1 SUCCESS**, resultado final y contenido cotejados; C01 cerrada.
  No se disparó el job por API/comandos; interfaz operada por Bruno.
- `L4-integral` creado deshabilitado: SCM al commit publicado; parámetros explícitos.
  No hubo ejecución integral, push de imágenes, scan ni despliegue. C07 separado.
- Altas de Snyk/Docker Hub y sus credenciales locales corresponden a Bruno;
  no se copiaron ni leyeron secretos del curso. No son necesarias para preflight.
- Conexión Kubernetes declarada en `connect-kubernetes.ps1`: identidad dedicada,
  token 24 h y pruebas de límites. Sintaxis comprobada; **no ejecutada en vivo**
  en esta sesión, sin RBAC/token nuevo ni conexión a Minikube. Validar/renovar
  con destino revisado antes de C07; no afirmar esa conexión como probada.
- Apt y transitivas Python no se fijaron bit a bit; inventarios efectivos guardados.
  Compatibilidad portable y guía general siguen en C02; backup/purga en C03;
  vulnerabilidades residuales, alcance literal y merge conservan sus tareas.
- Informe README, Word y evidencias históricas conservados. Sin commit/push/merge.

Guía operativa entregada: [ci/jenkins/README.md](../../ci/jenkins/README.md).
