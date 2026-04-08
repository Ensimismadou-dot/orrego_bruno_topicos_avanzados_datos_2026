-- practica 3: Riesgo de temperaturas por ciudad
--  TEMPERATURAS -- > Alta (>= 25), Media (15 a 24), Baja (< 15)

DECLARE
    -- se hace elige temperatura para las 3 ciudades
    temp_ciudad_a NUMBER := 28;
    temp_ciudad_b NUMBER := 20;
    temp_ciudad_c NUMBER := 15;
BEGIN
    -- primera ciudad
    IF temp_ciudad_a >= 25 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad A: Temperatura alta');
    ELSIF temp_ciudad_a >= 15 THEN
        -- Si no es mayor a 25, pero sí mayor o igual a 15, es media
        DBMS_OUTPUT.PUT_LINE('Ciudad A: Temperatura media');
    ELSE
        -- Si es menor a 15
        DBMS_OUTPUT.PUT_LINE('Ciudad A: Temperatura baja');
    END IF;

    -- segunda ciudad
    IF temp_ciudad_b >= 25 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad B: Temperatura alta');
    ELSIF temp_ciudad_b >= 15 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad B: Temperatura media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ciudad B: Temperatura baja');
    END IF;

    -- tercera ciudad
    IF temp_ciudad_c >= 25 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad C: Temperatura alta');
    ELSIF temp_ciudad_c >= 15 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad C: Temperatura media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ciudad C: Temperatura baja');
    END IF;
END;
/