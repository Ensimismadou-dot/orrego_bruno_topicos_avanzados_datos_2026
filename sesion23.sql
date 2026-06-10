--sesion 23
-- bruno orrego
-- 23.1

-- Modelo NoSQL para curso_topicos
-- Colección: clientes
-- Embeber los Pedidos y DetallesPedidos en el documento del cliente
-- Embeber los datos de Productos en Detalles para evitar consultas adicionales
-- - Motivo: Reducir la necesidad de JOINs y mejorar el rendimiento en consultas frecuentes
-- - Nota: Si los productos cambian frecuentemente, podría ser mejor mantenerlos en una colección separada

db.clientes.insertOne({
  "ClienteID": 1,
  "Nombre": "Juan Pérez",
  "Ciudad": "Santiago",
  "FechaNacimiento": "1990-05-15",
  "Pedidos": [
	{
  	"PedidoID": 101,
  	"Total": 2272.5,
  	"FechaPedido": "2025-03-01",
  	"Detalles": [
    	{ "ProductoID": 1, "Nombre": "Laptop", "Precio": 1200, "Cantidad": 2 },
    	{ "ProductoID": 2, "Nombre": "Mouse", "Precio": 25, "Cantidad": 5 }
  	]
	}
  ]
});
-- 23.2
-- Consulta 1: Clientes de Santiago
db.clientes.find(
  { "Ciudad": "Santiago" },
  { "Nombre": 1, "Ciudad": 1, "_id": 0 }
);
-- Resultado esperado:
-- { "Nombre": "Juan Pérez", "Ciudad": "Santiago" }
-- { "Nombre": "Ana López", "Ciudad": "Santiago" }

-- Consulta 2: Número total de productos vendidos por producto
db.clientes.aggregate([
  { $unwind: "$Pedidos" },
  { $unwind: "$Pedidos.Detalles" },
  {
	$group: {
  	_id: "$Pedidos.Detalles.Nombre",
  	TotalVendidos: { $sum: "$Pedidos.Detalles.Cantidad" }
	}
  }
]);
-- Resultado esperado:
-- { "_id": "Laptop", "TotalVendidos": 3 }
-- { "_id": "Mouse", "TotalVendidos": 7 }
