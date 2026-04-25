--sesion11
--ejercicio_practico_1
CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
	v_fecha_nacimiento DATE;
	v_edad NUMBER;
BEGIN
	SELECT FechaNacimiento INTO v_fecha_nacimiento
	FROM Clientes
	WHERE ClienteID = p_cliente_id;
	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
	RETURN v_edad;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
END;
/
-- prueba
DECLARE
	v_edad NUMBER;
BEGIN
	v_edad := calcular_edad_cliente(1);
	DBMS_OUTPUT.PUT_LINE('Edad del cliente 1: ' || v_edad);
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
---------------------------------------------------------------------------------------------

--ejercicio_practico_2
CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
-- Variable para almacenar el resultado del promedio calculado
    v_promedio NUMBER;
BEGIN
-- Calcular el promedio matemático de la columna Precio en la tabla Repuestos
    SELECT AVG(Precio) INTO v_promedio
    FROM Repuestos;
    
-- Retornar el valor numérico calculado
    RETURN v_promedio;
END;
/
-- Consulta SQL para listar los repuestos cuyo precio supera la media
-- Llama directamente a la función en la cláusula WHERE
SELECT Nombre, Precio
FROM Repuestos
WHERE Precio > obtener_precio_promedio();