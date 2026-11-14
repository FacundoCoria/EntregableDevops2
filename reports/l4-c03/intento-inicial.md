# Intento inicial C03 — 14/11/2026

La copia `c03-primary-20261114` y su integridad terminaron correctamente;
el origen reinició en 18080. La restauración no llegó a crear volúmenes:
Docker devuelve `no such volume` en minúsculas cuando el destino no existe;
el reconocimiento del script esperaba `No such` y falló de forma conservadora.
Error: `No se pudo inspeccionar volume: l4-c01-c03-restore_controller-home`.

La comprobación posterior detectó una segunda variante de ausencia:
`network l4-c01-c03-restore_control not found`. Tampoco creó recursos.
Se corrigió la comparación sin distinguir mayúsculas y se reconoció la variante
exacta de red inexistente. Pruebas específicas cubren ambas y que un error de
permisos no se trate como ausencia. El intento y la copia inicial se conservan, pero **no acreditan
restauración exitosa**. Se hará una copia nueva con la fuente corregida,
sin sobrescribir la primera. Consultar VERIFICACION.md para el resultado final.
