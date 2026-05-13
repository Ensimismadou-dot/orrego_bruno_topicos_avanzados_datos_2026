-- sesion14
-- 14.1
-- Supertipo Vehiculo
CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
    Marca VARCHAR2(50),
    Año NUMBER,
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY Vehiculo AS
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN 2025 - Año;
    END;
END;
/

-- Subtipo Automovil
CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
    NumeroPuertas NUMBER,
    MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY Automovil AS
    MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Automóvil: ' || Marca || ', Año: ' || Año || ', Puertas: ' || NumeroPuertas;
    END;
END;
/

-- Crear tabla y probar
CREATE TABLE Vehiculos OF Vehiculo;

INSERT INTO Vehiculos VALUES (Automovil('Toyota', 2020, 4));

SELECT v.Marca, v.obtener_antiguedad() AS Antiguedad, TREAT(VALUE(v) AS Automovil).descripcion() AS Descripcion
FROM Vehiculos v
WHERE VALUE(v) IS OF (Automovil);
-- 14.2

-- Subtipo Camion
CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
    CapacidadCarga NUMBER,
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Camion AS
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN (2025 - Año) + 2; -- 2 años adicionales
    END;
END;
/

-- Insertar y consultar
INSERT INTO Vehiculos VALUES (Camion('Volvo', 2018, 10));

SELECT v.Marca, v.obtener_antiguedad() AS Antiguedad
FROM Vehiculos v
WHERE VALUE(v) IS OF (Camion);