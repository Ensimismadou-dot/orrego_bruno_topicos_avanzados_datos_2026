-- sesion 17
-- bruno orrego
-- 17.1 ------------------------------------------------------------------
-- /*Crea un usuario user_analista y un rol rol_analista. El rol debe tener permisos para consultar (SELECT) todas las tablas de curso_topicos y para insertar (INSERT) en la tabla Pedidos. Asigna el rol al usuario y prueba los permisos.*/
CREATE USER user_analista IDENTIFIED BY analista123;
GRANT CONNECT TO user_analista; --USUARIO CREADO

CREATE ROLE rol_analista;
GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT ON Pedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;
GRANT INSERT ON Pedidos TO rol_analista; -- ROL Y PERMISOS

GRANT rol_analista TO user_analista; -- ASIGNACIÓN DE ROL

CONNECT user_analista/analista123; -- PRUEBA DE CONEXIÓN
SELECT * FROM Clientes; -- PRUEBA DE PERMISO SELECT
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (200, 1, 1000, TO_DATE('2025-04-01', 'YYYY-MM-DD')); -- PRUEBA DE PERMISO INSERT
UPDATE CLIENTES SET Nombre = 'Pepe Tapia modificado' WHERE ClienteID = 1; -- PRUEBA DE PERMISO UPDATE (DEBE FALLAR)

-- 17.2 ------------------------------------------------------------------

/*Configura auditoría para monitorear las acciones de user_analista al consultar la tabla Clientes y al insertar en la tabla Pedidos. Realiza algunas acciones y verifica los registros de auditoría.*/
CONNECT sys AS sysdba; -- CONEXIÓN COMO SYSDBA PARA CONFIGURAR AUDITORÍA
AUDIT SELECT ON Clientes BY user_analista; -- AUDITORÍA PARA SELECT EN CLIENTES
AUDIT INSERT ON Pedidos BY user_analista; -- AUDITORÍA PARA INSERT EN PEDIDOS 
-- habilita auditoria para el usuario

CONNECT user_analista/analista123; -- CONEXIÓN COMO USER_ANALISTA
SELECT * FROM Clientes; -- ACCIÓN DE CONSULTA PARA GENERAR REGISTRO DE AUDITORÍA
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (201, 1, 1500, TO_DATE('2025-04-02', 'YYYY-MM-DD')); -- ACCIÓN DE INSERT PARA GENERAR REGISTRO DE AUDITORÍA
--REALIZA ACCIONES COMO USER_ANALISTA PARA GENERAR REGISTROS DE AUDITORÍA

--VER REGISTROS DE AUDITORÍA
CONNECT sys AS sysdba; -- CONEXIÓN COMO SYSDBA PARA VER AUDITORÍA
SELECT username, action_name, timestamp
FROM dba_audit_trail
FROM dba_audit_trail
WHERE username = 'USER_ANALISTA';