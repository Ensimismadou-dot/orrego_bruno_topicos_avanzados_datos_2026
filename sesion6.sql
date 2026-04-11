-- creacion del objeto
CREATE OR REPLACE TYPE repuesto_obj AS OBJECT (
    repuesto_id NUMBER,
    nombre VARCHAR2(50),
    precio NUMBER,
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

-- cuerpo del objeto
CREATE OR REPLACE TYPE BODY repuesto_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || repuesto_id || ', Repuesto: ' || nombre || ', Precio: ' || precio;
    END;
END;
/

-- tabla del objeto
CREATE TABLE repuestos_obj OF repuesto_obj (
    repuesto_id PRIMARY KEY
);

-- insertamos repuestos para la lista
INSERT INTO repuestos_obj VALUES (1, 'Filtro de Aceite Mahindra', 15000);
INSERT INTO repuestos_obj VALUES (2, 'Pastillas de Freno', 35000);
-- ------------------------------------------------------------------------------------
-- sesion 6.1
-- escribir un bloque anonimo que use un cursor explicito basado en un objeto para listar 2 atributos, ordenados por uno de ellos
DECLARE
    -- cursor basado en el objeto se ordena precio
    CURSOR repuesto_cursor IS
        SELECT VALUE(r) 
        FROM repuestos_obj r 
        ORDER BY r.precio DESC;
        
    v_repuesto repuesto_obj;
BEGIN
    OPEN repuesto_cursor;
    LOOP
        FETCH repuesto_cursor INTO v_repuesto;
        EXIT WHEN repuesto_cursor%NOTFOUND;
        
        -- SE LISTA 2 atributos de la clase objeto
        DBMS_OUTPUT.PUT_LINE('Repuesto: ' || v_repuesto.nombre || ' | Precio: $' || v_repuesto.precio);
    END LOOP;
    CLOSE repuesto_cursor;
END;
/
-- --------------------------------------------------------------------------------------------------------
-- sesion 6.2
-- escribir un bloque anonimo que use un cursor explicito con parámetro basado en un objeto para aumentar un 10% el atributo numerico, mostrando el valor original y actualizado, utilizando for update
DECLARE
    -- Cursor con parámetro (p_id) y FOR UPDATE
    CURSOR actualiza_precio_cursor (p_id NUMBER) IS
        SELECT repuesto_id, precio
        FROM repuestos_obj
        WHERE repuesto_id = p_id
        FOR UPDATE;
        
    v_id NUMBER;
    v_precio_original NUMBER;
BEGIN
    -- se abre el cursor pasando el ID del repuesto como parámetro (ej: ID 1)
    OPEN actualiza_precio_cursor(1);
    LOOP
        FETCH actualiza_precio_cursor INTO v_id, v_precio_original;
        EXIT WHEN actualiza_precio_cursor%NOTFOUND;
        
        -- valor original
        DBMS_OUTPUT.PUT_LINE('Precio original del repuesto ' || v_id || ': $' || v_precio_original);
        
        -- aplicamos el aumento del 10% (multiplicando por 1.1)
        UPDATE repuestos_obj
        SET precio = v_precio_original * 1.1
        WHERE CURRENT OF actualiza_precio_cursor;
        
        -- valor actualizado
        DBMS_OUTPUT.PUT_LINE('Precio actualizado (+10%): $' || (v_precio_original * 1.1));
    END LOOP;
    CLOSE actualiza_precio_cursor;
END;
/