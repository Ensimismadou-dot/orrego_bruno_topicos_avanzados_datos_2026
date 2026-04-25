--sesion10
--practico1
CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10) AS
-- Declarar el cursor para obtener los pedidos del cliente con bloqueo
    CURSOR pedido_cursor IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE;
BEGIN
-- Recorrer los pedidos usando un bucle (for)
    FOR pedido IN pedido_cursor LOOP
        -- Actualizar el total aplicando el porcentaje de aumento
        UPDATE Pedidos
        SET Total = pedido.Total * (1 + p_porcentaje / 100)
        WHERE CURRENT OF pedido_cursor;
        
-- Mostrar el cambio en la consola de forma limpia y directa
        DBMS_OUTPUT.PUT_LINE('Pedido: ' || pedido.PedidoID || ' Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
    END LOOP;
    
-- Verificar si el cliente tenía pedidos para actualizar
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('El cliente ' || p_cliente_id || ' no tiene pedidos.');
    ELSE
        -- Confirmar la transacción si hubo actualizaciones
        COMMIT;
    END IF;
    
EXCEPTION
-- Capturar cualquier error inesperado durante el proceso
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        -- Revertir los cambios en caso de fallo
        ROLLBACK;
END;
/
-- Prueba de ejecucion del procedimiento
EXEC actualizar_total_pedidos(1);
------------------------------------------------------------------------------------------------
--practico2
CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo IN OUT NUMBER) AS
-- Declarar variables para almacenar el precio del repuesto y la cantidad solicitada
    v_precio NUMBER;
    v_cantidad NUMBER;
BEGIN
-- Obtener el precio y la cantidad mediante un JOIN entre DetallesPedidos y Repuestos
    SELECT r.Precio, d.Cantidad INTO v_precio, v_cantidad
    FROM DetallesPedidos d
    JOIN Repuestos r ON d.RepuestoID = r.RepuestoID
    WHERE d.DetalleID = p_detalle_id;
    
-- Calcular el costo total multiplicando el precio por la cantidad
    p_costo := v_precio * v_cantidad;
    
-- Mostrar el resultado en consola de forma directa y limpia
    DBMS_OUTPUT.PUT_LINE('Detalle: ' || p_detalle_id || ' Costo: ' || p_costo);
    
EXCEPTION
-- Manejar el error en caso de que el ID del detalle no exista en la tabla
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: Detalle ' || p_detalle_id || ' no encontrado.');
END;
/
-- Bloque anónimo para la prueba del procedimiento
DECLARE
-- Variable para inicializar y recibir el costo calculado (parámetro IN OUT)
    v_costo NUMBER := 0;
BEGIN
-- Llamada al procedimiento pasando el ID del detalle y la variable por referencia
    calcular_costo_detalle(1, v_costo);
    
-- Imprimir el valor devuelto por el parámetro IN OUT
    DBMS_OUTPUT.PUT_LINE('Costo final devuelto: ' || v_costo);
END;
/