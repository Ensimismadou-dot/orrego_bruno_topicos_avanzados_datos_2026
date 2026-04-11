-- sesion 7.1
CREATE OR REPLACE PROCEDURE aumentar_precio_repuesto(p_repuesto_id IN NUMBER, p_porcentaje IN NUMBER) AS
BEGIN
    -- se actualiza el precio del repuesto sumandole el porcentaje
    UPDATE Repuestos
    SET Precio = Precio * (1 + p_porcentaje / 100)
    WHERE RepuestoID = p_repuesto_id;
    
    -- Si ninguna fila fue afectada, significa que el repuesto no existe
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Repuesto Mahindra con ID ' || p_repuesto_id || ' no encontrado.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Precio del repuesto ' || p_repuesto_id || ' aumentado en ' || p_porcentaje || '%.');
    COMMIT;

EXCEPTION -- para errores 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

EXEC aumentar_precio_repuesto(2, 10); -- testtt
-- ------------------------------------------------------------------------------------------------------
-- sesion 7.2
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(p_cliente_id IN NUMBER, p_cantidad OUT NUMBER) AS
BEGIN
    -- contamos los pedidos del cliente y lo guardamos en la salida
    SELECT COUNT(*) INTO p_cantidad
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
END;
/

--                       test del procedimiento usando bloque
DECLARE
    v_cantidad NUMBER;
BEGIN
    contar_pedidos_cliente(1, v_cantidad); -- procedimiento para ir pasando el ID del cliente y la variable que recibirá el resultado
    
    -- Mostramos el resultado por pantalla
    DBMS_OUTPUT.PUT_LINE('El cliente 1 ha realizado ' || v_cantidad || ' pedidos de repuestos.');
END;
/