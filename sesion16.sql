-- sesion 16
-- bruno orrego

--16.1 ------------------------------------------------------------------
-- ejecutamos el plan de ejecución inicial
EXPLAIN PLAN FOR
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c, Pedidos p
WHERE c.ClienteID = p.ClienteID
  AND c.Ciudad = 'Santiago'
  AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
CREATE INDEX idx_clientes_ciudad ON Clientes(Ciudad);
CREATE INDEX idx_pedidos_clienteid ON Pedidos(ClienteID);
EXPLAIN PLAN FOR
SELECT /*+ INDEX(c idx_clientes_ciudad) INDEX(p idx_pedidos_clienteid) */
       c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
  AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
  AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
-- 16.2 ----------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p, DetallesPedidos dp
WHERE p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
EXPLAIN PLAN FOR
SELECT /*+ INDEX(dp idx_detalles_productoid) */
       p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p
JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p
JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;