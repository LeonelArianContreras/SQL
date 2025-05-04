/*9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.*/

SELECT empl_jefe, empl_codigo, empl_nombre, (SELECT COUNT(depo_encargado) 
										     FROM Deposito WHERE depo_encargado = empl_codigo) + 
											(SELECT COUNT(depo_encargado) 
											 FROM Deposito WHERE depo_encargado = empl_jefe) 
FROM Empleado

--> Resolución del profesor, la anterior es la mía
select empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre), count(depo_codigo) 
from Empleado left join DEPOSITO on empl_codigo = depo_encargado or empl_jefe = depo_encargado
group by empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre)
