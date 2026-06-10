-- sesion 24
-- bruno orrego
-- 24.1

-- Roles y permisos para el Proyecto Integrador
CREATE ROLE rol_usuario;
CREATE ROLE rol_admin;

GRANT SELECT, INSERT ON Productos TO rol_usuario;
GRANT SELECT, INSERT ON Ventas TO rol_usuario;
GRANT ALL PRIVILEGES ON Productos TO rol_admin;
GRANT ALL PRIVILEGES ON Ventas TO rol_admin;
GRANT ALL PRIVILEGES ON Clientes TO rol_admin;

CREATE USER usuario1 IDENTIFIED BY user123;
GRANT rol_usuario TO usuario1;

CREATE USER admin1 IDENTIFIED BY admin123;
GRANT rol_admin TO admin1;

-- Optimización de consulta
EXPLAIN PLAN FOR
SELECT c.Nombre, SUM(v.Total) AS TotalVentas
FROM Clientes c
INNER JOIN Ventas v ON c.ClienteID = v.ClienteID
GROUP BY c.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Resultado inicial: Costo 5, TABLE ACCESS FULL en Ventas

-- Mejora: Crear índice
CREATE INDEX idx_ventas_clienteid ON Ventas(ClienteID);

EXPLAIN PLAN FOR
SELECT c.Nombre, SUM(v.Total) AS TotalVentas
FROM Clientes c
INNER JOIN Ventas v ON c.ClienteID = v.ClienteID
GROUP BY c.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- Resultado final esperado: Disminución del costo de ejecución y cambio de TABLE ACCESS FULL a INDEX RANGE SCAN usando idx_ventas_clienteid.
