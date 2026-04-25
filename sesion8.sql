-- sesion 8
-- bruno orrego

-- ejercicio1
DECLARE
    CURSOR c_pedidos IS
        SELECT p.PedidoID, p.Total, c.Nombre
        FROM Pedidos p
        JOIN Clientes c ON p.ClienteID = c.ClienteID
        WHERE p.Total > 500;
BEGIN
    FOR reg IN c_pedidos LOOP
        DBMS_OUTPUT.PUT_LINE('Pedido: ' || reg.PedidoID || ' Cliente: ' || reg.Nombre || ' Total: ' || reg.Total);
    END LOOP;
END;
/

--ejercicio2
DECLARE
    CURSOR repuesto_cursor IS
        SELECT RepuestoID, Precio
        FROM Repuestos
        WHERE Precio < 1000
        FOR UPDATE;
        
    v_repuestoid NUMBER;
    v_precio NUMBER;
BEGIN
    OPEN repuesto_cursor;
    LOOP
        FETCH repuesto_cursor INTO v_repuestoid, v_precio;
        EXIT WHEN repuesto_cursor%NOTFOUND;
        
        UPDATE Repuestos
        SET Precio = v_precio * 1.15
        WHERE CURRENT OF repuesto_cursor;
        
        DBMS_OUTPUT.PUT_LINE('Repuesto: ' || v_repuestoid || ' Nuevo Precio: ' || (v_precio * 1.15));
    END LOOP;
    CLOSE repuesto_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF repuesto_cursor%ISOPEN THEN
            CLOSE repuesto_cursor;
        END IF;
END;
/
--ejercicio3
DECLARE
    CURSOR cliente_cursor IS
        SELECT c.ClienteID, c.Nombre AS NombreCliente, SUM(p.Total) AS TotalPedidos
        FROM Clientes c
        JOIN Pedidos p ON c.ClienteID = p.ClienteID
        GROUP BY c.ClienteID, c.Nombre
        HAVING SUM(p.Total) > 1000;
    
    v_cliente_id Clientes.ClienteID%TYPE;
    v_nombre_cliente Clientes.Nombre%TYPE;
    v_total_pedidos NUMBER;
    v_contador NUMBER := 0;
BEGIN
    OPEN cliente_cursor;
    LOOP
        FETCH cliente_cursor INTO v_cliente_id, v_nombre_cliente, v_total_pedidos;
        EXIT WHEN cliente_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre_cliente || ' Total: ' || v_total_pedidos);
        v_contador := v_contador + 1;
    END LOOP;
    CLOSE cliente_cursor;
    
    IF v_contador = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No hay clientes sobre 1000.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF cliente_cursor%ISOPEN THEN
            CLOSE cliente_cursor;
        END IF;
END;
/
--ejercicio4
DECLARE
    CURSOR detalle_cursor IS
        SELECT dp.DetalleID, dp.PedidoID, dp.Cantidad
        FROM DetallesPedidos dp
        JOIN Pedidos p ON dp.PedidoID = p.PedidoID
        WHERE p.FechaPedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
        FOR UPDATE OF dp.Cantidad;
        
    v_detalle_id DetallesPedidos.DetalleID%TYPE;
    v_pedido_id DetallesPedidos.PedidoID%TYPE;
    v_cantidad DetallesPedidos.Cantidad%TYPE;
    v_nueva_cantidad DetallesPedidos.Cantidad%TYPE;
    v_contador NUMBER := 0;
BEGIN
    OPEN detalle_cursor;
    LOOP
        FETCH detalle_cursor INTO v_detalle_id, v_pedido_id, v_cantidad;
        EXIT WHEN detalle_cursor%NOTFOUND;
        
        v_nueva_cantidad := v_cantidad + 1;
        
        UPDATE DetallesPedidos
        SET Cantidad = v_nueva_cantidad
        WHERE CURRENT OF detalle_cursor;
        
        DBMS_OUTPUT.PUT_LINE('Detalle: ' || v_detalle_id || ' Pedido: ' || v_pedido_id || ' Cantidad: ' || v_cantidad || ' -> ' || v_nueva_cantidad);
        v_contador := v_contador + 1;
    END LOOP;
    CLOSE detalle_cursor;
    
    IF v_contador = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No hay detalles anteriores a la fecha.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Total actualizados: ' || v_contador);
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Sin datos.');
        IF detalle_cursor%ISOPEN THEN
            CLOSE detalle_cursor;
        END IF;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF detalle_cursor%ISOPEN THEN
            CLOSE detalle_cursor;
        END IF;
        ROLLBACK;
END;
/
--ejercicio5
CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

-- Crear el cuerpo del tipo con el método get_info
CREATE OR REPLACE TYPE BODY cliente_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || TO_CHAR(cliente_id) || ' Nombre: ' || nombre;
    END get_info;
END;
/

-- Crear la tabla basada en el tipo cliente_obj
CREATE TABLE Clientes_Obj OF cliente_obj (
    cliente_id PRIMARY KEY
);

-- Transferir datos de Clientes a Clientes_Obj
INSERT INTO Clientes_Obj (cliente_id, nombre)
SELECT ClienteID, Nombre
FROM Clientes;

-- Bloque PL/SQL para listar información de clientes usando el método get_info
DECLARE
    CURSOR cliente_cursor IS
        SELECT VALUE(c) AS cli_obj
        FROM Clientes_Obj c;
        
    v_cli_obj cliente_obj;
BEGIN
-- Abrir el cursor
    OPEN cliente_cursor;
    
-- Recorrer el cursor
    LOOP
        FETCH cliente_cursor INTO v_cli_obj;
        EXIT WHEN cliente_cursor%NOTFOUND;
        
-- Llamar al método get_info para mostrar la información
        DBMS_OUTPUT.PUT_LINE(v_cli_obj.get_info());
    END LOOP;
    
-- Cerrar el cursor
    CLOSE cliente_cursor;
    
-- Manejar el caso en que no se encuentren datos
    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('No hay clientes en la tabla Clientes_Obj.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al listar clientes: ' || SQLERRM);
        IF cliente_cursor%ISOPEN THEN
            CLOSE cliente_cursor;
        END IF;
END;
/