# ID 1791 · Gestión de Coworking y Oficinas Compartidas
# Examen 1813-Dashboard


Dashboard Básico para Recepcionista

Contexto:
La recepcionista necesita un dashboard simple con datos en tiempo real.



Tarea:
Crear una vista VW_EstadoEspacios que muestre:
Espacio
Estado (Libre / Ocupado)
Próxima reserva
Crear un procedimiento sp_GenerarReporteDiario que devuelva:
Total de reservas hoy
Usuarios activos en el día
Ingresos del día
Simular una consulta para mostrar en pantalla: "Ahora mismo hay X personas en el coworking".


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



-- ===================================================================
-- sp_GenerarReporteDiario
-- ===================================================================
-- en este procesimiento use principalmente
-- pues lo mas facil fue hacer sud consultas dentro de una mas grande
-- tambien guarde la fecha de hoy con CURDATE() en una variable y en otra lo mismo
-- pero para dentrode un dia para lass validaciones en sub consultas 
a este tambien le agregue unos 3 datos que no tenia para ese dia estan justo abajo
-- a una cosa fue que por practicidad use una fecha vieja

-- ===================================================================
-- Consulta
-- ===================================================================
-- esta consulta use principalmente
-- un CONCAT para agregar el texto que me solicitaban 
-- tambien en el mismo CONCATuse el CASE para usar un condicional para asegurar si era uno pues decir en sigular
-- y si no en plural y ya  el resto condicion pues estado exitoso que la hora de salir sea null
-- y que cuando entro pues sea menorque ahora
-- use tambien datos del insert anteror