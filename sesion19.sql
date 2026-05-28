--sesion 19 
--bruno orrego
--19.1
/*Diseña una estrategia de respaldo para el esquema curso_topicos. Documenta la estrategia en comentarios y escribe un script RMAN para un respaldo completo y un respaldo incremental
*/

-- Estrategia de respaldo para el esquema curso_topicos
-- -Respaldo Completo: Cada Domingo a las 23:00
-- -Respaldo incremental (Nivel 1): Diaramente a las 23:00
-- -Retención : mantener respaldos de las últimas 2 semanas
-- ubicación: disco Local (/u01/backup) y copia en la nube (AWS S3)

-- Script RMAN para respaldo completo
rman target /

CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 14 DAYS;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/backup/%U';

RUN{
    BACKUP DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE;
    }
    -- Script RMAN para respaldo incremental
    RUN{
        BACKUP INCREMENTAL LEVEL 1 DATABASE;
        BACKUP ARCHIVELOG ALL;
    }
    LIST BACKUP;

--#################################################################################

--19.2
/*SIMULA UN FALLO ELIMINANDO LA TABLA PRODUCTOS Y RECUPERA LOS DATOS USANDO FLASHBACK (SI ESTÁ HABILITADO) O RAMN. DOCUMENTA EL PROCESO.
*/

-- simulamos el fallo
DROP TABLE productos;
-- VERIFICAMOS
SELECT COUNT(*) FROM productos; -- La tabla no existe
-- recuperamos usando flashback
FLASHBACK TABLE productos TO BEFORE DROP;
-- CASO CONTRARIO (RMAN)

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
RUN{
    RESTORE TABLE curso_topicos.productos;
    RECOVER TABLE curso_topicos.productos;
}
ALTER DATABASE OPEN;
--VERIFICAMOS
SELECT COUNT(*) FROM productos; -- La tabla ha sido recuperada