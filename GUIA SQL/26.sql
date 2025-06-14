/*26. Escriba una consulta sql que retorne un ranking de empleados devolviendo las
siguientes columnas:
 Empleado
 Depósitos que tiene a cargo
 Monto total facturado en el año corriente --> Claramente devuelve 0 porque la base de datos es vieja
 Codigo de Cliente al que mas le vendió
 Producto más vendido
 Porcentaje de la venta de ese empleado sobre el total vendido ese año.
Los datos deberan ser ordenados por venta del empleado de mayor a menor.*/

SELECT RTRIM(E1.empl_nombre)+SPACE(1)+E1.empl_apellido,
	  (SELECT COUNT(depo_codigo)
	   FROM Deposito
	   JOIN Empleado ON depo_encargado = empl_codigo AND empl_codigo = E1.empl_codigo) AS cant_depositos, --> Se hace en un subselect ya que si lo joineamos, altera el resultado, eliminando los empleados que no son encargados de ningun deposito, por ende, el ranking estaría incompleto
	   SUM(ISNULL(F1.fact_total, 0)) AS monto_total_año_corriente,
	  (SELECT TOP 1 fact_cliente
	   FROM Factura
	   WHERE fact_vendedor = E1.empl_codigo
	   GROUP BY fact_cliente
	   ORDER BY COUNT(fact_tipo+fact_sucursal+fact_numero) DESC) AS cliente_estrella,
	   (SELECT TOP 1 item_producto
	   FROM Item_Factura
	   JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND fact_vendedor = E1.empl_codigo
	   GROUP BY item_producto
	   ORDER BY COUNT(item_cantidad) DESC) AS producto_estrella,
	  SUM(ISNULL(fact_total, 0)) * 100 / (SELECT SUM(ISNULL(fact_total, 0))
										  FROM Factura
										  WHERE YEAR(fact_fecha) = 2012) AS porcentaje_venta 
FROM Empleado E1
JOIN Factura F1 ON F1.fact_vendedor = E1.empl_codigo AND YEAR(fact_fecha) = 2012
GROUP BY RTRIM(E1.empl_nombre)+SPACE(1)+E1.empl_apellido, E1.empl_codigo
ORDER BY monto_total_año_corriente DESC

