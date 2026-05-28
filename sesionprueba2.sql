-- SESION PRUEBA
-- BRUNO ORREGO
-- PARTE 1
-- PREGUNTA 1: La diferencia entre ambas, radica en que hacen cada uno con los datos procesados
--  function: tiene como objetivo principal realizar calculos dando como retorno un único valor usando RETURN. Se tiene que considerar que no está pesando para modificar la base de datos, osea ingresar INSERT, UPDATE ETC. Solo PARA LECTURA CON UN RETURN DEL DATO EN CUESTIÓN.
--  procedure: Está pensado para ejecutar una acción lógica, no devuelve un valor necesariamente, pero está pesando para editar la lógica u manejar el código de la base de datos.
--  parte dos de la pregunta: para ejemplificar los usos de cada uno, dependiendo de cada función, nos piden una función que nos solicita llamarla calcular_horas_agente, que está a la par con un AgenteID, retornando el número total de horaas que tiene asaignadas
-- para el otro ejmplo, podemos utilizar el registrar_asignacion que nos solicita el ejercicio, el cual también recibe un AgenteID, pero con la diferencia que nos solicita un IncidenteID, hORAS, Y roL Y debemos hacer un insert en la tabla de asignaciónes

--Pregunta2: Un parámetro IN/OUT tiene en un principio, un valor inicial que es procesado dentro del bloque, y al terminar el proceso que el parámetro realize, se actualiza la variable en cuestión y devuelve un valor a quien llamó el procedimiento.
--Ejemplo:
/* CREATE OR REPLACE PROCEDURE ajustar_horas_asignacion(
    p_agente_id IN NUMBER,
    p_horas_asignadas IN OUT NUMBER
) AS
BEGIN
    obtenemos las horas actuales asignadas al agente
    SELECT NVL(SUM(horas), 0) INTO p_horas_asignadas
    FROM asignaciones
    WHERE agente_id = p_agente_id;

    se hace ajuste las horas asignadas (por ejemplo, sumando 2 horas adicionales)
    p_horas_asignadas := p_horas_asignadas + 2;

    podríamos actualizar la base de datos con el nuevo valor si es necesario
    UPDATE agentes
    SET horas_asignadas = p_horas_asignadas
    WHERE agente_id = p_agente_id;
    
END;*/

-- PREGUNTA3: una función al devolver un solo dato o valor, se les pueden invocar epliciamente a estas mediante el uso de un SELECT, WHERE, Y ORDER BY
-- ejmplo:
/* CREATE OR REPLACE FUNCTION calcular_total_horas(
    p_id_incidente IN NUMBER
) RETURN NUMBER AS
    v_total_horas NUMBER;
BEGIN
    SELECT NVL(SUM(horas), 0) INTO v_total_horas
    FROM asignaciones
    WHERE incidente_id = p_id_incidente;
    
    RETURN v_total_horas;
END;*/

-- PREGUNTA4: Un TRIGGER es un bloque de código PL/SQL que se ejecuta de forma automática como respuesta a un evento específico que ocurra en alguna tabla y vista. Es útil para automatizar o auditar o mantener la integridad de los datos.
-- Dos tipos de eventos que pueden dispararlo son: INSERT (cuando se agrega un nuevo registro a la tabla) y UPDATE (cuando se modifican los datos de uno o varios registros existentes)
-- ejemplo:
/* CREATE OR REPLACE TRIGGER trg_actualiza_estado_incidente
AFTER INSERT ON Asignaciones
FOR EACH ROW
BEGIN
    -- Se actualiza la tabla Incidentes usando el ID del nuevo registro insertado
    UPDATE Incidentes
    SET Estado = 'En Proceso' -- se cambia el estado a 'En Proceso' cuando se asigna un agente a un incidente
    WHERE IncidenteID = :NEW.IncidenteID
      AND Estado = 'Abierto'; -- La condición asegura que solo cambie si estaba en 'Abierto'
END;
*/

-- #############################################################termina preguntas 1/4#######################################################################################################################################

-- PARTE 2
-- 2.1
-- se crea procedimiento
CREATE OR REPLACE PROCEDURE registrar_asignacion(
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas IN NUMBER,
    p_Rol IN VARCHAR2
) AS
    v_estado_incidente VARCHAR2(50); --variable para almacenar el estado del incidente
    v_count NUMBER;
    v_next_asignacion_id NUMBER;
    
    e_agente_no_existe EXCEPTION; -- excepción para agente no existente
    e_ya_asignado EXCEPTION; -- excepción para agente ya asignado al incidente
BEGIN
    -- se debe verificar si el agente existe
    SELECT COUNT(*) INTO v_count FROM Agentes WHERE AgenteID = p_AgenteID;
    IF v_count = 0 THEN
        RAISE e_agente_no_existe;
    END IF;
    -- comprobamos para el incidente si existe y obtenemos su estado
    SELECT Estado INTO v_estado_incidente FROM Incidentes WHERE IncidenteID = p_IncidenteID;
    -- mismo que en el anterior solo que se verifica si el agente ya está asignado al incidente para evitar duplicados
    SELECT COUNT(*) INTO v_count FROM Asignaciones WHERE AgenteID = p_AgenteID AND IncidenteID = p_IncidenteID;
    IF v_count > 0 THEN -- si el conteo es mayor a 0, significa que ya existe una asignación para ese agente e incidente
        RAISE e_ya_asignado;
    END IF;
    -- ahora buscamos obtener el próximo AsignacionID disponible
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_next_asignacion_id FROM Asignaciones;
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol) -- se inserta la nueva asignación con el nuevo ID generado
    VALUES (v_next_asignacion_id, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
    IF v_estado_incidente = 'Abierto' THEN -- si el estado del incidente es 'Abierto', se actualiza a 'En Proceso'
        UPDATE Incidentes SET Estado = 'En Proceso' WHERE IncidenteID = p_IncidenteID;
    END IF;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Asignación registrada!!');

EXCEPTION
    WHEN e_agente_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El ID para el agente' || p_AgenteID || ' no existe.');
        ROLLBACK;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: El ID para el incidente ' || p_IncidenteID || ' no existe.');
        ROLLBACK;
    WHEN e_ya_asignado THEN
        DBMS_OUTPUT.PUT_LINE('Error: El agente ya se encuentra asignado a este incidente.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ¿?' || SQLERRM);
        ROLLBACK;
END;
/

-- 2.2
/*escribe una función calcular_horas_agente que reciba un AgenteID (parámetro IN) y devuelva el total de horas asignadas a este agente en todos los incidentes. Luego, usa la función en un procedimiento mostrar_carga_agentes que muestre el total de horas por agente para todos los agentes, indicando su nombre y especialidad.*/
-- Función para calcular el total de horas asignadas a un agente
CREATE OR REPLACE FUNCTION calcular_horas_agente(p_AgenteID IN NUMBER) RETURN NUMBER AS
    v_total_horas NUMBER;
BEGIN
    SELECT NVL(SUM(Horas), 0) INTO v_total_horas
    FROM Asignaciones
    WHERE AgenteID = p_AgenteID;
    
    RETURN v_total_horas;
END;
/
-- Procedimiento para mostrar la carga de todos los agentes
CREATE OR REPLACE PROCEDURE mostrar_carga_agentes AS
BEGIN
    FOR r_agente IN (SELECT AgenteID, Nombre, Especialidad FROM Agentes) LOOP
        DBMS_OUTPUT.PUT_LINE('Agente: ' || r_agente.Nombre || 
                             ' | Especialidad: ' || r_agente.Especialidad || 
                             ' | Total Horas: ' || calcular_horas_agente(r_agente.AgenteID));
    END LOOP;
END;
/

-- 2.3
/*implementa un sistema de auditoria manual usando un trigger. Para esto, primero crea una tabla llamada AuditoriaAsignaciones con las columnas necesarias. Luegocrea un trigger auditar_asignaciones que se dispare después de inertar o eliminar una asignación en la talba Asignaciones. El trigger debe registrar en una tabla de auditoria el AsignaciónID, AgenteID, IncidenteID, Horas, la acción realizada(INSERT p DELETE y la fecha del registro.
*/
-- Crear tabla de auditoría
CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10), -- para registrar si fue un INSERT o DELETE
    FechaRegistro DATE
);
--creamos un trigger para auditar_asignaciones
CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW -- se ejecuta para cada fila afectada
BEGIN
    -- se verifica si la operación es un INSERT o DELETE para registrar la acción correspondiente en la tabla de auditoría
    IF INSERTING THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (:NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, 'INSERT', SYSDATE);
    -- si es un DELETE, se registra la acción de eliminación con los valores antiguos asignados a la fila eliminada
    ELSIF DELETING THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (:OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, 'DELETE', SYSDATE);
    END IF;
END;
/
