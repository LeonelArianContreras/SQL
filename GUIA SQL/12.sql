/*12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/

/*12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/

SELECT prod_detalle, COUNT(DISTINCT fact_cliente), AVG(item_precio)
FROM Producto JOIN Stock ON stoc_producto = prod_codigo --> Cambia atomicidad
			  JOIN Item_Factura ON prod_codigo = item_producto --> Cambia atomicidad				  
			  JOIN Factura ON fact_sucursal+fact_tipo+fact_numero=item_sucursal+item_tipo+item_numero --> No cambia atomicidad
			  JOIN Cliente ON fact_cliente = clie_codigo --> No cambia atomicidad
GROUP BY prod_detalle, prod_codigo
HAVING prod_codigo IN (SELECT prod_codigo 
					   FROM Producto JOIN Item_Factura ON prod_codigo = item_producto --> Cambia atomicidad				  
									 JOIN Factura ON fact_sucursal+fact_tipo+fact_numero=item_sucursal+item_tipo+item_numero --> No cambia atomicidad
					   WHERE YEAR(fact_fecha) = 2012)
ORDER BY MAX(item_precio) DESC

/*-------------------------------------------------*/

SELECT prod_codigo, prod_detalle, COUNT(DISTINCT fact_cliente), AVG(ISNULL(item_precio, 0))
FROM Producto JOIN Stock ON stoc_producto = prod_codigo --> Cambia atomicidad
			  JOIN Item_Factura ON prod_codigo = item_producto --> Cambia atomicidad				  
			  JOIN Factura ON fact_sucursal+fact_tipo+fact_numero=item_sucursal+item_tipo+item_numero --> No cambia atomicidad
			  JOIN Cliente ON fact_cliente = clie_codigo --> No cambia atomicidad
WHERE YEAR(fact_fecha) = 2012 --> Más eficiente que la anterior ya que primero filtro el dato con respecto a la fecha, en cambio, en la resu de arriba, primero agrupo todo y despues filtro, ineficiente.
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_precio * item_cantidad) DESC

/*-------------------------------------------------*/

SELECT prod_codigo, prod_detalle, COUNT(DISTINCT fact_cliente), AVG(isnull(item_precio, 0)), 
																							(SELECT COUNT(depo_codigo)
																							 FROM Deposito JOIN Stock ON stoc_deposito = depo_codigo
																							 WHERE stoc_cantidad > 0 AND stoc_producto = prod_codigo),
																							(SELECT SUM(isnull(stoc_cantidad, 0))
																							 FROM Stock
																							 WHERE stoc_producto = prod_codigo)
FROM Producto JOIN Item_Factura ON prod_codigo = item_producto
JOIN Factura ON item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_precio * item_cantidad) DESC
