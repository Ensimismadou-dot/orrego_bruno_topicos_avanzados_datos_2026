-- Sesion 5.1
-- Listar dos atributos (nombre y precio) ordenados por precio usando un cursor explícito.
SET SERVEROUTPUT ON;

DECLARE-- Defino mi cursor acá arriba. Es básicamente guardar la consulta sql en una variable que después voy a recorrer.
    CURSOR cursor_repuestos IS
        SELECT nombre_repuesto, precio
        FROM CatalogoRepuestos
        ORDER BY precio ASC;
        
    -- Mis variables para ir guardando los datos que saque del cursor --
    v_nombre_repuesto VARCHAR2(50);
    v_precio_repuesto NUMBER;
BEGIN
    OPEN cursor_repuestos; -- Abro la "caja" de resultados
    
    LOOP
        -- Saco la siguiente fila y meto los datos en mis variables
        FETCH cursor_repuestos INTO v_nombre_repuesto, v_precio_repuesto;
        
        -- Si el cursor ya no encuentra más filas, corta el loop para dar resultado
        EXIT WHEN cursor_repuestos%NOTFOUND;
        
        -- muestra
        DBMS_OUTPUT.PUT_LINE('Repuesto: ' || v_nombre_repuesto || ' - Valor: $' || v_precio_repuesto);
    END LOOP;
    
    CLOSE cursor_repuestos; -- buena práctica: siempre cerrar el cursor al terminar
END;
/
--5.2 Usar un cursor CON PARÁMETRO para buscar un repuesto específico, bloquear la fila (FOR UPDATE) y subirle el precio un 10%.
SET SERVEROUTPUT ON;
DECLARE
    CURSOR cursor_precio (p_id_buscado NUMBER) IS
        SELECT repuesto_id, precio
        FROM CatalogoRepuestos
        WHERE repuesto_id = p_id_buscado
        FOR UPDATE;
        
    v_id NUMBER;
    v_precio_actual NUMBER;
    
    -- el id del repuesto que le vamos a pasar al parámetro del cursor
    id_objetivo NUMBER := 105; 
BEGIN
    -- abro el cursor, pero esta vez le paso el parámetro del paréntesis
    OPEN cursor_precio(id_objetivo);
    FETCH cursor_precio INTO v_id, v_precio_actual; -- fila
    
    -- si encontró algo con ese ID:
    IF cursor_precio%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Precio original del repuesto: $' || v_precio_actual);
        -- se suma el 10% 
        v_precio_actual := v_precio_actual * 1.10; 
        -- Hago el update. El "WHERE CURRENT OF" es mágico porque actualiza 
        -- exactamente la fila donde el cursor está parado en este momento.
        UPDATE CatalogoRepuestos 
        SET precio = v_precio_actual 
        WHERE CURRENT OF cursor_precio;
        n8
        DBMS_OUTPUT.PUT_LINE('Precio actualizado (+10%): $' || v_precio_actual);
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontró ningún repuesto con el ID ' || id_objetivo);
    END IF;
    CLOSE cursor_precio;
END;
/