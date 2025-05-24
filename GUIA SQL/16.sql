/*16. Con el fin de lanzar una nueva campaña comercial para los clientes que menos compran
en la empresa, se pide una consulta SQL que retorne aquellos clientes cuyas compras
son inferiores a 1/3 del monto de ventas del producto que más se vendió en el 2012.
Además mostrar
1. Nombre del Cliente
2. Cantidad de unidades totales vendidas en el 2012 para ese cliente.
3. Código de producto que mayor venta tuvo en el 2012 (*/

SELECT clie_razon_social, clie_codigo, SUM(isnull(item_cantidad, 0)), isnull((SELECT TOP 1 item_producto
																	   FROM Item_Factura JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
																						              AND YEAR(fact_fecha) = 2012
																	   WHERE clie_codigo = fact_cliente
																	   GROUP BY item_producto
																	   ORDER BY SUM(isnull(item_cantidad, 0)) DESC), 'Ninguno')
FROM Cliente JOIN Factura ON clie_codigo = fact_cliente --> Cambia atomicidad
			 JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND YEAR(fact_fecha) = 2012
GROUP BY clie_razon_social, clie_codigo
HAVING (SELECT SUM(isnull(fact_total, 0)) FROM Factura WHERE clie_codigo = fact_cliente) > 1/3 * 
																	  (SELECT TOP 1 SUM(isnull(item_cantidad, 0) * isnull(item_precio, 0))
																	   FROM Item_Factura JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero 
																						              AND YEAR(fact_fecha) = 2012
																	   ORDER BY SUM(isnull(item_cantidad, 0)) DESC)
ORDER BY 3