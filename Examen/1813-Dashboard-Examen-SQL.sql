use coworking_db;

-- ===================================================================
-- VIEW VW_EstadoEspacios
-- ===================================================================
-- en esta view use principalmente 
-- un espacio estara Ocupado si existe una reserva CONFIRMADA en el rango
-- [fecha_inicio, fecha_fin] que tenga NOW() es decir el ahora eso lo hago dentro de unaa mini consulta
-- usando un condiciuonal que como estoy dentro de un selec tengo que usar el case y decirle when 
-- Las ortras opciones no lo ponen en ocupado.
-- Proxi reserva es la fecha_inicio mas cercana usando min y validando qu este confirmaada
-- y null si no hay
DROP VIEW IF EXISTS VW_EstadoEspacios;

CREATE OR REPLACE VIEW VW_EstadoEspacios AS
SELECT  e.id_espacio,
    e.nombre AS espacio,
    e.estado AS estado_operativo, case
   when EXISTS(		SELECT 1
            FROM reservas r
            WHERE r.id_espacio = e.id_espacio
              AND r.estado = 'Confirmada'
              AND NOW() BETWEEN r.fecha_inicio AND r.fecha_fin
        ) THEN 'Ocupado'
        ELSE 'Libre' END AS estado,
    (
        SELECT MIN(r2.fecha_inicio)
        FROM reservas r2
        WHERE r2.id_espacio = e.id_espacio
          AND r2.estado = 'Confirmada'
          AND r2.fecha_inicio > NOW()
    ) AS proxima_reserva
    FROM espacios e;
    

SELECT espacio, estado, proxima_reserva FROM VW_EstadoEspacios ORDER BY espacio;

-- ===================================================================
-- sp_GenerarReporteDiario
-- ===================================================================
-- en este procesimiento use principalmente
-- pues lo mas facil fue hacer sud consultas dentro de una mas grande
-- tambien guarde la fecha de hoy con CURDATE() en una variable y en otra lo mismo
-- pero para dentrode un dia para lass validaciones en sub consultas 
-- a una cosa fue que por practicidad use una fecha vieja

DROP PROCEDURE IF EXISTS sp_GenerarReporteDiario;

DELIMITER $$

CREATE PROCEDURE sp_GenerarReporteDiario()
BEGIN
    DECLARE v_inicio_dia DATETIME DEFAULT date('2026-09-30');            
    DECLARE v_fin_dia    DATETIME DEFAULT v_inicio_dia + INTERVAL 1 DAY;    

    SELECT
        -- Total de reservas del dia no cuentan las canceladas
        (SELECT COUNT(*)
           FROM reservas
          WHERE fecha_inicio >= v_inicio_dia
            AND fecha_inicio <  v_fin_dia
            AND estado <> 'Cancelada') AS total_reservas_hoy,

        -- Usuarios unicos que lograron ingresar hoy
        (SELECT COUNT(DISTINCT id_usuario)
           FROM registros_acceso
          WHERE fecha_hora_entrada >= v_inicio_dia
            AND fecha_hora_entrada <  v_fin_dia
            AND estado_validacion = 'Exitoso') AS usuarios_activos,

        -- Dinero de hoy
        (SELECT COALESCE(SUM(monto), 0)
           FROM pagos
          WHERE fecha_pago >= v_inicio_dia
            AND fecha_pago <  v_fin_dia
            AND estado_transaccion = 'Pagado') AS ingresos_del_dia;
END$$

DELIMITER ;

CALL sp_GenerarReporteDiario();

-- datos que me faltava
INSERT INTO registros_acceso (id_usuario, fecha_hora_entrada, fecha_hora_salida, metodo_acceso, estado_validacion, motivo_rechazo) 
VALUES 
(1, '2026-09-30 07:45:12', '2026-09-30 12:30:00', 'RFID', 'Exitoso', NULL),
(2, '2026-09-30 08:02:45', '2026-09-30 17:15:30', 'QR', 'Exitoso', NULL),
(3, '2026-09-30 08:15:00', '2026-09-30 13:00:20', 'RFID', 'Exitoso', NULL),
(3, '2026-09-30 08:15:00', null, 'RFID', 'Exitoso', NULL);

-- ===================================================================
-- Consulta
-- ===================================================================
-- esta consulta use principalmente
-- un CONCAT para agregar el texto que me solicitaban 
-- tambien en el mismo CONCATuse el CASE para usar un condicional para asegurar si era uno pues decir en sigular
-- y si no en plural y ya  el resto condicion pues estado exitoso que la hora de salir sea null
-- y que cuando entro pues sea menorque ahora

SELECT
    CONCAT(
        'Ahora mismo hay ',
        COUNT(DISTINCT id_usuario),
        CASE WHEN COUNT(DISTINCT id_usuario) = 1 THEN ' persona' ELSE ' personas' END,
        ' en el coworking'
    ) AS mensaje_pantalla
FROM registros_acceso
WHERE estado_validacion = 'Exitoso'
  AND fecha_hora_salida IS NULL
  AND fecha_hora_entrada <= CURDATE();