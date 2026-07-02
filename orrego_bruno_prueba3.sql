-- sesion 29
-- evaluacion 3
-- Bruno Orrego

-- ### PARTE 1: Teorica ###

/* 1 Explique qué es una transacción en una base de datos y describe las propiedas ACID. 
Luego, muestra a través de un ejemplo cómo usarias multiples savepoints para manejar errores parciales en un procedimiento que asigna un agente a un incidente y actualiza simultaneamente el estado del incidente.
 ¿Qué ocurre si falla solo la actualización del estado?
 
 Respuesta: Una transación en una base de datos, corresponde a una unidad lógica de trabajo.
 Que consta de ser un conjunto de operaciones (INSERT, UPDATE, DELETE) que deben ejecutarse juntas.
 Las siglas que commprenden un ACID son:
    A(Atomicidad): Conocido como "todo o nada", significa que todas las operaciones de la transacción deben completarse con éxito, o ninguna de ellas se aplicará.
    C(Consistencia): Garantiza que la base de datos pase de un estado válido a otro estado válido, manteniendo la integridad de los datos.
    I(Aislamiento): Si hay múltiples transacciones ocurriendo al mismo tiempo, no deben interferir entre sí. Cada una debe ejecutarse como si fuera la única en el sistema.
    D(Durabilidad): Una vez que una transacción o COMMIT se ha completado, sus cambios son permanentes, incluso en caso de fallos del sistema (Como un corte de luz o server down).

Además, ¿Qué ocurre si falla solo la actualización del estado?

-- > Lo que ocurre es que al ejecturar el "ROLLBACK TO sp_antes_estado;"", la base de datos deshace el intento del UPDATE, pero mantiene intacto en la memoria del INSERT initial de la asignación. 
El proceso no se ha guardado de forma definitiva (falta el COMMIT final), pero nos permite controlar el error específico sin perder el trabajo válido que ya habíamos avanzado en la transacción.

Ejemplos SAVEPOINT:

CREATE OR REPLACE PROCEDURE asignar_agente_incidente (
    p_AgenteID IN NUMBER,
    p_IncidenteID IN NUMBER
) AS
BEGIN
    -- Iniciamos la transacción principal
    SAVEPOINT sp_inicio;

    -- Operación 1: Asignar al agente
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID) 
    VALUES (seq_asignacion.NEXTVAL, p_AgenteID, p_IncidenteID);

    -- Punto de guardado intermedio
    SAVEPOINT sp_antes_estado;

    -- Operación 2: Actualizar el estado del incidente
    UPDATE Incidentes 
    SET Estado = 'En Progreso' 
    WHERE IncidenteID = p_IncidenteID;
    COMMIT; --guardamos los cambios de toda la transacción

EXCEPTION
    WHEN OTHERS THEN
        -- Si falla la actualización (ej. un constraint del estado), volvemos al punto intermedio
        ROLLBACK TO sp_antes_estado;
        DBMS_OUTPUT.PUT_LINE('Fallo al actualizar el estado. La asignación sigue pendiente en memoria.');
        -- Aquí podríamos decidir hacer un COMMIT parcial o lanzar otro error.
END;
/


 */

/* 2. ¿Qué es un Data Warehouse y cómo se diferencia de una base de datos transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos y al menos dos dimensiones)
 para analizar las horas trabajadas por agente y por severidad de incidente. 
 ¿Qué ventajas tiene este modelo para consultas analíticas versus consultar directamente las tablas transaccionales?

 Respuesta: Un Data Warehouse es un sistema de almacenamiento de datos diseñado específicamente para la consulta y análisis de grandes volúmenes de información, a diferencia de una base de datos transaccional que está optimizada para operaciones rápidas de lectura y escritura (como INSERT, UPDATE, DELETE) en tiempo real.
   - BD Transaccional: Está diseñada para la operación diaria. Es altamente 
     normalizada para procesar inserciones, actualizaciones y borrados rápidos y seguros 
     (por ejemplo, registrar un nuevo incidente o asignar un agente en tiempo real).
   - Data Warehouse: Es un repositorio central diseñado para el análisis histórico 
     y la toma de decisiones. Aquí la información se "desnormaliza" intencionalmente para 
     que las consultas masivas de lectura sean extremadamente rápidas.

   Para analizar las horas trabajadas cruzando datos por agente y por la severidad del 
   incidente, diseñaríamos el siguiente esquema:
   
   -> DIMENSIONES (Describen el "quién" y el "qué"):
      * Dim_Agente: AgenteID (PK), Nombre, Nivel, Especialidad.
      * Dim_Incidente: IncidenteID (PK), Severidad, Categoria.
   
   -> TABLA DE HECHOS (Almacena las métricas/números a analizar):
      * Fact_Asignaciones_Horas: 
        - Claves Foráneas: AgenteID (FK), IncidenteID (FK)
        - Métricas: Horas_Invertidas (NUMBER)

    Para analizar las ventajas de este modelo dimensional frente a consultar directamente las tablas transaccionales:

   --> Rendimiento Analítico: Consultar la base transaccional directamente requiere ejecutar 
     múltiples JOINs pesados cruzando tablas altamente normalizadas llenas de datos 
     operativos. 
   --> Simplicidad: En el Data Warehouse, como los datos ya están pre-calculados y 
     estructurados para el análisis, una consulta tipo "SUM(Horas_Invertidas) GROUP BY 
     Severidad" solo cruza la tabla de hechos con una dimensión. Esto hace que el 
     motor de base de datos responda muchísimo más rápido y sin afectar el rendimiento 
     del sistema operativo principal que usan los usuarios día a día. */

/* 3. Explica cómo se implementa la herencia en Oracle usando tipos de objetos. 
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista → AgentePentester, donde cada nivel agrega atributos y sobreescribe un método calcular_costo().
 ¿Qué implicancias tiene declarar un tipo como NOT INSTANTIABLE?
 
 Respuesta: Para implementar la herencia en Oracle, se utilizan tipos de objetos o object types, que permiten definir una estructura de datos con atributos y métodos asociados.
 La herencia se logra mediante la clausula UNDER, que permite que un tipo de objeto herede atributos y métodos de otra base. 
 Esto permite crear jerarquias de tipos de objetos, donde los subtivos pueden extender la funcionalidad de los tipos base.

Implicancia de NOT INSTANTIABLE:
Al declarar la clase Agente base como no instanciable, le estamos diciendo a Oracle que funciona puramente como una plantilla (clase abstracta).
Es imposible hacer un INSERT en una tabla insertando un objeto del tipo Agente puro; obligatoriamente el registro debe ser de un tipo hijo que sí sea instanciable, como un AgenteEspecialista o un AgentePentester.
Ejemplo de jerarquía de dos niveles utilizando UNDER y MEMBER FUNCTION:

CREATE TYPE Agente AS OBJECT ( -- super clase
    AgenteID NUMBER,
    Nombre VARCHAR2(100),
    SueldoBase NUMBER,
    MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT INSTANTIABLE NOT FINAL; -- ¡AQUÍ: Debe ser NOT FINAL para poder heredar de él!
/

-- nivel 1
CREATE TYPE AgenteEspecialista UNDER Agente ( -- sub clase
    BonoEspecialidad NUMBER,
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY AgenteEspecialista AS
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
    BEGIN
        RETURN SueldoBase + BonoEspecialidad;
    END;
END; -- ¡AQUÍ: Faltaba cerrar el TYPE BODY!
/

-- nivel 2
CREATE TYPE AgentePENTESTER UNDER AgenteEspecialista ( -- sub clase
    BonoRiesgo NUMBER,
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY AgentePENTESTER AS
    OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
    BEGIN
        RETURN SueldoBase + BonoEspecialidad + BonoRiesgo;
    END;
END;
/                                                                    */

 /* 4. Describe las ventajas y desventajas de usar índices y particiones en una base de datos.
  ¿Cómo usarías un índice compuesto y una partición por rango para mejorar el rendimiento de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion? 
  Explica qué es el partition pruning y cómo impacta en el plan de ejecución.

  Respuesta: 

Indices:
    Ventajas:
        + Mejoran significativamente la velocidad de las consultas SELECT, especialmente en tablas grandes.
        + Permiten búsquedas rápidas y eficientes, reduciendo el tiempo de respuesta.
        + Pueden ser únicos, asegurando la integridad de los datos.
    Desventajas:
        - Consumen espacio adicional en disco.
        - Pueden ralentizar las operaciones de INSERT, UPDATE y DELETE, ya que el índice debe actualizarse.
        - Requieren mantenimiento y pueden fragmentarse con el tiempo.

Particiones:
    Ventajas:
        + Mejoran el rendimiento de las consultas al permitir que la base de datos lea solo las particiones relevantes.
        + Facilitan la gestión de grandes volúmenes de datos, permitiendo archivar o eliminar particiones completas.
        + Pueden mejorar la disponibilidad y recuperación ante fallos.
    Desventajas:
        - Incrementan la complejidad del diseño y mantenimiento de la base de datos.
        - No todas las consultas se benefician de la partición, especialmente si no están bien diseñadas.
        - Pueden requerir más recursos para administrar y monitorear.

¿Cómo lo usaria?
Si constantemente buscamos incidentes por su gravedad en ciertos rangos de fecha, usaríamos un índice compuesto y una partición:

Particionamos la tabla por rango usando FechaDeteccion (ej. particiones mensuales o trimestrales).

Creamos un índice local compuesto: CREATE INDEX idx_sev_fecha ON Incidentes(Severidad, FechaDeteccion);.

¿Qué es el Partition Pruning?
Es una técnica del optimizador de Oracle (poda de particiones). Si tu consulta dice WHERE Severidad = 'Alta' AND FechaDeteccion = '2026-03-15', el motor mira las reglas de la tabla particionada. En lugar de leer toda la tabla, el optimizador "poda" (ignora totalmente) las particiones de enero, febrero, abril, etc., y dirige la búsqueda física exclusivamente a la partición de marzo.
En el plan de ejecución (EXPLAIN PLAN), el impacto es brutal: pasas de ver un costoso TABLE ACCESS FULL a ver un PARTITION RANGE SINGLE (acceso a una sola partición), minimizando el uso de disco y memoria.

 */

-- ### PARTE 2: Practica ###################################################################################################################

-- 1. Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe: 1. Insertar una nueva asignación en Asignaciones (usa el próximo AsignacionID disponible). 2. Validar que el agente no supere 100 horas totales asignadas en incidentes con Estado 'Abierto'. 3. Validar que el incidente no tenga ya 3 o más agentes asignados. 4. Usar savepoints independientes para cada validación, de modo que un fallo en una no deshaga operaciones previas válidas. 5. Manejar todas las excepciones con mensajes descriptivos.

SET SERVEROUTPUT ON; -- para su próxima ejecución y revisar los resultados de DBMS_OUTPUT.PUT_LINE.

CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_agente_id    IN NUMBER,
    p_incidente_id IN NUMBER,
    p_horas        IN NUMBER,
    p_rol          IN VARCHAR2
) AS
    v_total_horas_agente   NUMBER;
    v_agentes_en_incidente NUMBER;
    v_next_asignacion_id   NUMBER;
    
    -- Declaración de excepciones personalizadas
    e_excede_horas   EXCEPTION;
    e_excede_agentes EXCEPTION;
BEGIN
    -- Punto de guardado inicial
    SAVEPOINT sp_inicio;

    --Insertar la nueva asignación
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_next_asignacion_id FROM Asignaciones;
    
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_next_asignacion_id, p_agente_id, p_incidente_id, p_horas, p_rol);

    -- validación 1: Límite de horas
    SAVEPOINT sp_val_horas;
    
    SELECT NVL(SUM(a.Horas), 0)
    INTO v_total_horas_agente
    FROM Asignaciones a
    JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
    WHERE a.AgenteID = p_agente_id AND i.Estado = 'Abierto';

    IF v_total_horas_agente > 100 THEN
        RAISE e_excede_horas;
    END IF;

    -- validación 2: Límite de agentes
    SAVEPOINT sp_val_agentes;
    
    SELECT COUNT(DISTINCT AgenteID)
    INTO v_agentes_en_incidente
    FROM Asignaciones
    WHERE IncidenteID = p_incidente_id;

    -- Comparamos con > 3 porque el agente ya fue insertado en memoria en el paso 1
    IF v_agentes_en_incidente > 3 THEN
        RAISE e_excede_agentes;
    END IF;

    -- Si ambas validaciones son exitosas, consolidamos
    DBMS_OUTPUT.PUT_LINE('Asignación ' || v_next_asignacion_id || ' registrada correctamente.');
    COMMIT;

EXCEPTION
    WHEN e_excede_horas THEN
        ROLLBACK TO sp_inicio;
        DBMS_OUTPUT.PUT_LINE('Error: El agente superaría las 100 horas en incidentes abiertos.');
    
    WHEN e_excede_agentes THEN
        ROLLBACK TO sp_inicio;
        DBMS_OUTPUT.PUT_LINE('Error: El incidente ya tiene el límite máximo de agentes.');
        
    WHEN OTHERS THEN
        ROLLBACK TO sp_inicio;
        DBMS_OUTPUT.PUT_LINE('Error crítico: ' || SQLERRM);
END registrar_asignacion;
/

-- 2.Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un Data Warehouse basado en la base de datos de la prueba. Luego, Escribe una consulta analítica sobre las tablas transaccionales que muestre, para cada agente, el total de horas trabajadas y el número de incidentes atendidos, ordenado de mayor a menor por total de horas.

-- a) Diseño de tablas para Data Warehouse

CREATE TABLE Dim_Agente (
    AgenteID NUMBER PRIMARY KEY,
    NombreAgente VARCHAR2(100),
    Especialidad VARCHAR2(100)
);

CREATE TABLE Dim_Incidente (
    IncidenteID NUMBER PRIMARY KEY,
    Descripcion VARCHAR2(255),
    Severidad VARCHAR2(50),
    Estado VARCHAR2(50)
);

CREATE TABLE Fact_Asignaciones (
    FactID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    HorasAsignadas NUMBER,
    Rol VARCHAR2(50),
    CONSTRAINT fk_fact_agente FOREIGN KEY (AgenteID) REFERENCES Dim_Agente(AgenteID),
    CONSTRAINT fk_fact_incidente FOREIGN KEY (IncidenteID) REFERENCES Dim_Incidente(IncidenteID)
);

-- b) Consulta analítica sobre tablas transaccionales

SELECT
    a.AgenteID,
    a.Nombre,
    SUM(asg.Horas) AS TotalHorasTrabajadas,
    COUNT(DISTINCT asg.IncidenteID) AS NumeroIncidentesAtendidos
FROM
    Agentes a
JOIN
    Asignaciones asg ON a.AgenteID = asg.AgenteID
GROUP BY
    a.AgenteID, a.Nombre
ORDER BY
    TotalHorasTrabajadas DESC;

-- 3. Crea un índice compuesto en Incidentes para las columnas Severidad y FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el total de horas asignadas por incidente para incidentes 'Critical' detectados en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.

-- SOLUCIÓN 3:

-- a) Creación de índice compuesto
CREATE INDEX idx_inc_severidad_fecha ON Incidentes(Severidad, FechaDeteccion);

-- b) Creación de tabla particionada
-- Se crea una nueva tabla para implementar el particionamiento.
CREATE TABLE Incidentes_Particionada (
    IncidenteID     NUMBER PRIMARY KEY,
    Descripcion     VARCHAR2(255),
    Severidad       VARCHAR2(50),
    Estado          VARCHAR2(50),
    FechaDeteccion  DATE NOT NULL
)
PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_2026_q1 VALUES LESS THAN (TO_DATE('2026-04-01', 'YYYY-MM-DD')),
    PARTITION p_2026_q2 VALUES LESS THAN (TO_DATE('2026-07-01', 'YYYY-MM-DD')),
    PARTITION p_2026_q3 VALUES LESS THAN (TO_DATE('2026-10-01', 'YYYY-MM-DD')),
    PARTITION p_2026_q4 VALUES LESS THAN (TO_DATE('2027-01-01', 'YYYY-MM-DD')),
    PARTITION p_max     VALUES LESS THAN (MAXVALUE)
);

-- c) Consulta sobre la tabla particionada
EXPLAIN PLAN FOR
SELECT
    i.IncidenteID,
    SUM(a.Horas) AS TotalHorasAsignadas
FROM
    Incidentes_Particionada i
JOIN
    Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE
    i.Severidad = 'Critical'
    AND i.FechaDeteccion >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
    AND i.FechaDeteccion < TO_DATE('2026-04-01', 'YYYY-MM-DD')
GROUP BY
    i.IncidenteID;

-- d) Mostrar y analizar el plan de ejecución
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());

/*
e) Ventaja de la partición para esta consulta:

La principal ventaja es el "Partition Pruning" o Poda de Particiones; Al filtrar por un rango de
fechas que corresponde exactamente a una partición (el primer trimestre de 2026), el optimizador
de Oracle es lo suficientemente inteligente para saber que *solo* necesita leer los datos de la
partición `p_2026_q1`.
En el plan de ejecución, esto se reflejará en la operación `PARTITION RANGE (SINGLE)`,
indicando que solo se accede a una partición. Si la tabla `Incidentes` fuera muy grande y contuviera
datos de muchos años, esta técnica evita escanear la tabla completa, resultando en una mejora
drástica del rendimiento de la consulta al reducir masivamente la lectura de disco.
*/