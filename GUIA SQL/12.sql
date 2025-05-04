/*12. Mostrar nombre de producto, cantidad de clientes distintos que lo compraron, importe
promedio pagado por el producto, cantidad de depósitos en los cuales hay stock del
producto y stock actual del producto en todos los depósitos. Se deberán mostrar
aquellos productos que hayan tenido operaciones en el año 2012 y los datos deberán
ordenarse de mayor a menor por monto vendido del producto.*/

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
ORDER BY MAX(item_precio)
