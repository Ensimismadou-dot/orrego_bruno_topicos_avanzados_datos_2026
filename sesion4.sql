-- practica sesion 4.1
-- stock de un repuesto y advertir si no hay

SET SERVEROUTPUT ON;

DECLARE
    stock_actual NUMBER;
    alerta_poco_stock EXCEPTION;-- stock crítico
BEGIN
    -- Busco cuántas bujías (ej, el ID 10) nos quedan en bodega
    SELECT cantidad INTO stock_actual
    FROM InventarioRepuestos
    WHERE repuesto_id = 10;
    
    -- Si quedan menos de 3, advertencia
    IF stock_actual < 3 THEN
        RAISE alerta_poco_stock;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Todo bien, tenemos ' || stock_actual || ' unidades en stock.');

EXCEPTION
    -- "else"
    WHEN alerta_poco_stock THEN
        DBMS_OUTPUT.PUT_LINE('Error: Ojo, quedan menos de 3 unidades. Hay que encargar más.');
    WHEN NO_DATA_FOUND THEN
        -- Esto salva el código si puse un ID que no existe en la tabla
        DBMS_OUTPUT.PUT_LINE('Error: No existe el repuesto en la base de datos.');
END;
/
-- 4.2 -----------------------------------------------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
    -- DATOS DEL VEHICULO: ID 404 guardado en la tabla.
    nuevo_id NUMBER := 404; 
    marca_veh VARCHAR2(50) := 'Mahindra';
    modelo_veh VARCHAR2(50) := 'Scorpio';
    anio_veh NUMBER := 2011;
BEGIN
    -- distinto del anterior,  insertamos sin preguntar primero
    INSERT INTO VehiculosRegistrados (vehiculo_id, marca, modelo, anio) 
    VALUES (nuevo_id, marca_veh, modelo_veh, anio_veh);
    
    -- si el ID estuviera libre, llegaría a este mensaje
    DBMS_OUTPUT.PUT_LINE('Vehículo guardado sin problemas.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN-- DUP_VAL_ON_INDEX es la excepción
        DBMS_OUTPUT.PUT_LINE('Fallo: La base de datos rebotó el ingreso porque el ID ' || nuevo_id || ' ya existe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Pasó un error inesperado: ' || SQLERRM);-- cuando un ID ya existe (llave primaria duplicada)
END;
/