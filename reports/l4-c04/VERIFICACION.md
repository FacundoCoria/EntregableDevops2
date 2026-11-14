# C04 — Verificación documental

Fecha: **14/11/2026, Uruguay**. Verificación de archivos y registros;
**sin nueva ejecución operativa ni aceptación docente**.

Se contrastaron Dockerfiles, Compose y versiones fijadas con resultados anteriores:

- API: dos FROM, transferencia JAR build → runtime y USER final 10001:10001.
- Controlador Jenkins: un FROM y USER final 1000:1000; derivado real con plugins/init.
- Agente: dos FROM, copia Docker CLI/Buildx y USER final 1000:1000.
- Compose: usuarios 1000:1000 y excepción DinD privileged:true; TLS al motor propio.
- B02 inventario 11/11: UID sensor Falco 0, init 65532; capacidades y AppArmor.
- C03 primary-final: PASS, controllerAndAgentUid 1000, TLS y job integral deshabilitado.
- Enlaces locales del criterio, handoff e índice vigente comprobados.
- Mil archivos anteriores inventariados por SHA256. La única modificación prevista
  de ese conjunto es `reports/ESTADO-EVIDENCIAS-L4.md`; los otros 999 se conservan
  idénticos, incluidos README, Word, consigna, Dockerfiles y pruebas anteriores.

Detalle y resultado: [verificacion.json](verificacion.json).
Inventario previo: [preservacion-antes.json](preservacion-antes.json).
La integridad de archivos no prueba por sí sola salud actual o aceptación académica.

El primer pase del verificador se detuvo al comprobar el enlace a su propio JSON
antes de crearlo. Se corrigió el orden: se exige su existencia después de escribirlo;
los demás enlaces se comprueban antes. Ese intento no acredita verificación exitosa.

Maestro, mapa L4, plan, pendientes e índice vigentes registran la decisión C04 y
la aceptación pendiente C04-A. C09 conserva la actualización del informe publicado;
su texto histórico no se corrigió en esta etapa. Sin commit, push, merge, scans,
builds, despliegues ni acciones de interfaz.
