
/*20. Escriba una consulta sql que retorne un ranking de los mejores 3 empleados del 2012
Se debera retornar legajo, nombre y apellido, anio de ingreso, puntaje 2011, puntaje
2012. El puntaje de cada empleado se calculara de la siguiente manera: para los que
hayan vendido al menos 50 facturas el puntaje se calculara como la cantidad de facturas
que superen los 100 pesos que haya vendido en el año, para los que tengan menos de 50
facturas en el año el calculo del puntaje sera el 50% de cantidad de facturas realizadas
por sus subordinados directos en dicho año.*/

SELECT 
TOP 3  E.empl_codigo,
	   RTRIM(E.empl_nombre)+SPACE(1)+LTRIM(E.empl_apellido) AS nombre_apellido,
	   YEAR(E.empl_ingreso) AS año_ingreso,
	   CASE 
			WHEN (SELECT COUNT(fact_vendedor) 
				  FROM Factura
				  WHERE fact_vendedor = E.empl_codigo AND YEAR(fact_fecha) = 2011) >= 50 

			THEN (SELECT COUNT(fact_vendedor) 
				  FROM Factura 
				  WHERE fact_total > 100 AND fact_vendedor = E.empl_codigo AND YEAR(fact_fecha) = 2011)

			ELSE (SELECT COUNT(S.empl_codigo)
				  FROM Empleado S 
				  JOIN Factura F ON F.fact_vendedor = S.empl_codigo AND YEAR(F.fact_fecha) = 2011
				  WHERE S.empl_jefe = E.empl_codigo) * 0.50
			
		END AS puntaje_2011,
		CASE 
			WHEN (SELECT COUNT(fact_vendedor) 
				  FROM Factura
				  WHERE fact_vendedor = E.empl_codigo AND YEAR(fact_fecha) = 2012) >= 50 

			THEN (SELECT COUNT(fact_vendedor) 
				  FROM Factura 
				  WHERE fact_total > 100 AND fact_vendedor = E.empl_codigo AND YEAR(fact_fecha) = 2012)

			ELSE (SELECT COUNT(S.empl_codigo)
				  FROM Empleado S 
				  JOIN Factura F ON F.fact_vendedor = S.empl_codigo AND YEAR(F.fact_fecha) = 2012
				  WHERE S.empl_jefe = E.empl_codigo) * 0.50
			
		END AS puntaje_2012
FROM Empleado E 
ORDER BY puntaje_2012 DESC

