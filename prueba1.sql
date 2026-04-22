-- Prueba 1 
-- Bruno Orrego
------------------------- parte 1 ----------------
--Pregunta 1 R --> -- 1 Sucede cuando un objeto de múltiples registros en una tabla se asocian a otros múltiples registros, implementándose mediante una tabla intermedia que contiene las claves foráneas de ambas. Por ejemplo: tabla Trabajo_Incidente uniendo Incidentes y Tecnicos entre la relación (muchos tecnicos a muchos incidentes).
--Pregunta 2 R --> Es cuando se crea una tabla virtual, puede ser vista cuando en la consulta por medio de SQL, se realiza la visualización de la tabla.
--Se escribe para generar la consulta --> CREATE VIEW vista_horas AS SELECT i.id_incidente, i.descripcion, i.severidad, SUM(t.horas_dedicadas) AS total FROM Incidentes i JOIN Trabajo_Incidente t ON i.id_incidente = t.id_incidente GROUP BY i.id_incidente, i.descripcion, i.severidad;
--Pregunta 3 R --> Corresponden a errores de Oracle que pueden ser cometidos por el usuario o el mismo SQL, al tener complicaciones en líneas de código u encontrar archivos. El ejemplo de NO_DATA_FOUND que conlleva al EXCEPTION para evitar caídas o perdidas de informacin 
-- --> EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('No encontrado');
-- Pregunta 4 --> Es un puntero en memoria de un proceso definido por el usuario para realizar consultas de múltiples filas paso a paso; como por ejemplo OPEN, FETCH, utilizando atributos como:
-- %NOTFOUND --> devuelve el booleano TRUE si no hay más filas que leer.
-- %ROWCOUNT  --> muestra las filas procesadas que el usuario lleva creadas por el momento.
----------------------- parte 2 --------------------------
-- ejercicio1 bloque
DECLARE
    CURSOR c_esp IS
        SELECT a.especialidad, AVG(asg.horas) AS prom
        FROM Agentes a
        JOIN Asignaciones asg ON a.agente_id = asg.agente_id
        GROUP BY a.especialidad
        HAVING AVG(asg.horas) > 30;
BEGIN
    FOR r IN c_esp LOOP
        DBMS_OUTPUT.PUT_LINE(r.especialidad || ' | ' || ROUND(r.prom, 2));
    END LOOP;
END;
--EJERCICIO2
