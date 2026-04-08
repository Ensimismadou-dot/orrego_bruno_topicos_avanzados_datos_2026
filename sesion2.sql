-- sesion 2 practica
-- traer todos los datos de los vehículos que sean del año 2011
SELECT * FROM VehiculosRegistrados 
WHERE anio = 2011;

-- ver los nombres y precios de los repuestos que cuesten menos de 10 mil
SELECT nombre_repuesto, precio 
FROM CatalogoRepuestos 
WHERE precio < 10000;

-- Agregada 1: Contar cuántos vehículos tenemos registrados en total en el sistema (COUNT)
SELECT COUNT(*) AS total_vehiculos 
FROM VehiculosRegistrados;

-- Agregada 2: Calcular el precio promedio de todos los repuestos que vendemos (AVG)
SELECT AVG(precio) AS precio_promedio 
FROM CatalogoRepuestos;

-- Buscar el filtro con la palabra "Filtro". 
-- El símbolo '^' significa "al inicio de la palabra". La 'i' al final es para ignorar mayúsculas/minúsculas.
SELECT nombre_repuesto, precio 
FROM CatalogoRepuestos 
WHERE REGEXP_LIKE(nombre_repuesto, '^filtro', 'i');

-- Buscar vehículos cuya marca empiece con 'M' o con 'S' (ej: Mahindra, Subaru).
-- El '^[MS]" busca las que partan con M o S".
SELECT marca, modelo 
FROM VehiculosRegistrados 
WHERE REGEXP_LIKE(marca, '^[MS]', 'i');

CREATE OR REPLACE VIEW vista_repuestos_premium AS -- Un "atajo" (vista) para revisar rápidamente solo los repuestos caros
SELECT repuesto_id, nombre_repuesto, precio
FROM CatalogoRepuestos
WHERE precio >= 50000;

-- tabla resumen más limpia de los vehiculos, ordenados del mas nuevo al mas antiguo (vista)
CREATE OR REPLACE VIEW vista_resumen_vehiculos AS
SELECT marca, modelo, anio
FROM VehiculosRegistrados
ORDER BY anio DESC;

COMMIT; -- se guardan los datos
/