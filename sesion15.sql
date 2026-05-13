-- Sesion 15
-- Bruno Orrego
-- actividad practica 15.1
CREATE INDEX idx_detalles_pedido_producto ON DetallesPedidos(PedidoID, ProductoID);
EXPLAIN PLAN FOR
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);--display para ver q se está ejecutando en la tablaaa
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;

-- ################################################################################################

--actividad practica 15.2
CREATE TABLE Ventas ( --creamos tabla teniendo en cuenta el bash
	VentaID NUMBER PRIMARY KEY, 
	ClienteID NUMBER,
	Total NUMBER,
	FechaVenta DATE
)
PARTITION BY HASH (ClienteID)
PARTITIONS 4;

-- Insertar datos desde Pedidos
INSERT INTO Ventas (VentaID, ClienteID, Total, FechaVenta)
SELECT PedidoID, ClienteID, Total, FechaPedido
FROM Pedidos;

--Consulta creada para saber quien usa las particiones
EXPLAIN PLAN FOR
SELECT ClienteID, SUM(Total) AS TotalVentas
FROM Ventas
GROUP BY ClienteID;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY); -- vemos lo que tenemos en tabla y ejecutamos la parte de clientes
SELECT ClienteID, SUM(Total) AS TotalVentas
FROM Ventas
GROUP BY ClienteID;