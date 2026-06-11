-- sesion 28
-- bruno orrego

/*1. TRANSACCIÓN Y PROPIEDADES ACID:
   Una transacción es una unidad lógica de trabajo en la base de datos que agrupa 
   múltiples operaciones. Su integridad se garantiza mediante las propiedades ACID:
   - Atomicidad: Se ejecuta todo el bloque o no se ejecuta nada (todo o nada).
   - Consistencia: La base de datos siempre pasa de un estado válido a otro.
   - Aislamiento (Isolation): Las transacciones concurrentes no se interfieren.
   - Durabilidad: Una vez hecho el COMMIT, los cambios son permanentes ante fallos.

2. Se utilizan Savepoints para marcar un punto en la transacción. En el procedimiento 
   "registrar_pedido", si el cliente no existe, se ejecuta un "ROLLBACK TO inicio_pedido", 
   lo que revierte la operación de forma segura sin afectar otras transacciones externas.

3. DATA WAREHOUSE VS BD OPERATIVA:
   - Propósito: La BD Operativa (OLTP) procesa transacciones rápidas del día a día. 
     El Data Warehouse (OLAP) analiza grandes volúmenes de datos históricos para toma de decisiones.
   - Estructura: La BD Operativa está altamente normalizada (evita redundancia de datos). 
     El Data Warehouse está desnormalizado (esquemas de estrella/copo de nieve para optimizar lectura).

4. DISEÑO TABLA FACT_INVENTARIO: Es una tabla de hechos diseñada para un entorno OLAP. Almacena las métricas/medidas 
   (CantidadMovimiento) y utiliza claves foráneas para enlazarse con sus dimensiones 
   (ProductoID, FechaID), permitiendo análisis multidimensionales de entradas y salidas.

5. - Herencia: Se logra creando un supertipo "AS OBJECT NOT FINAL" y luego creando 
     subtipos que lo heredan mediante la cláusula "UNDER" (ej. ClientePremium).
   - Índice: Se eligió un índice en la columna "Ciudad" porque optimiza drásticamente 
     el rendimiento en consultas de segmentación geográfica. Evita que el motor de BD 
     lea toda la tabla registro por registro (Full Table Scan).
*/

-- 1. IMPLEMENTACION DE OBJETOSS

CREATE TYPE Tipo_Cliente AS OBJECT (
    ClienteID NUMBER,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    MEMBER FUNCTION getDescuento RETURN NUMBER
) NOT FINAL;
/

CREATE TYPE BODY Tipo_Cliente AS
    MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN 0; END;
END;
/

CREATE TYPE Tipo_ClientePremium UNDER Tipo_Cliente (
    DescuentoAdicional NUMBER,
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER
);
/

CREATE TYPE BODY Tipo_ClientePremium AS
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN DescuentoAdicional; END;
END;
/
-- 2. CREACION DE TABLAS

CREATE TABLE Clientes OF Tipo_Cliente; -- Instanciación de la tabla a partir del tipo de objeto

-- Creación de la tabla de hechos (Data Warehouse)
CREATE TABLE Fact_Inventario (
    FactID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductoID NUMBER,
    FechaID NUMBER,
    CantidadMovimiento NUMBER,
    TipoMovimiento VARCHAR2(10),
    CONSTRAINT fk_fact_inventario_producto FOREIGN KEY (ProductoID) REFERENCES Dim_Producto(ProductoID),
    CONSTRAINT fk_fact_inventario_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
-- 3. ÍNDICES

-- Optimización por Ciudad en Clientes
CREATE INDEX idx_clientes_ciudad ON Clientes (Ciudad);
-- Índice compuesto para la tabla Pedidos
CREATE INDEX idx_pedidos_cliente_total ON Pedidos (ClienteID, Total);
-- Índice compuesto para DetallesPedidos
CREATE INDEX idx_detalles_pedido_prod ON DetallesPedidos (PedidoID, ProductoID);

-- 4. PARTICIONAMIENTO DE TABLAS

-- Partición mixta por rango mensual/trimestral para 2025 basada en los requerimientos
ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_jan_2025 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_feb_2025 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_mar_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_q2_2025 VALUES LESS THAN (TO_DATE('2025-07-01', 'YYYY-MM-DD')),
    PARTITION p_q3_2025 VALUES LESS THAN (TO_DATE('2025-10-01', 'YYYY-MM-DD')),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);
-- 5. PROCEDIMIENTOS ALMACENADOS O FUNCIONES DE TRANSACIONES

CREATE OR REPLACE PROCEDURE registrar_pedido (
    p_cliente_id IN NUMBER,
    p_total IN NUMBER,
    p_fecha_pedido IN DATE
) AS
    v_cliente_existe NUMBER;
BEGIN
    -- Punto de guardado para la transacción
    SAVEPOINT inicio_pedido;
    
    -- Validar que el cliente existe
    SELECT COUNT(*) INTO v_cliente_existe
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    
    IF v_cliente_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cliente no existe.');
    END IF;
    
    -- Insertar pedido
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES ((SELECT NVL(MAX(PedidoID), 0) + 1 FROM Pedidos), p_cliente_id, p_total, p_fecha_pedido);
    
    -- Consolidar la transacción
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Reversión hasta el savepoint en caso de error
        ROLLBACK TO inicio_pedido;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM || '. Operación revertida.');
        ROLLBACK;
END;
/
-- 6. ¿CONSULTAS?

-- Sumatoria total por ClienteID en enero de 2025
SELECT 
    ClienteID,
    SUM(Total) AS Total_Mensual
FROM Pedidos
WHERE FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-01-31', 'YYYY-MM-DD')
GROUP BY ClienteID;