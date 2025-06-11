/*23. Realizar una consulta SQL que para cada año muestre :
 Año
 El producto con composición más vendido para ese año.
 Cantidad de productos que componen directamente al producto más vendido
 La cantidad de facturas en las cuales aparece ese producto.
 El código de cliente que más compro ese producto.
 El porcentaje que representa la venta de ese producto respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año en forma descendente*/

SELECT YEAR(F1.fact_fecha) AS año,
	   IT1.item_producto,
	   COUNT(DISTINCT P1.prod_codigo) AS cant_componentes,
	   COUNT(DISTINCT F1.fact_numero+F1.fact_sucursal+F1.fact_tipo) AS cant_ventas,
	   (SELECT TOP 1 F3.fact_cliente
	    FROM Factura F3
		JOIN Item_Factura IT3 ON IT3.item_tipo+IT3.item_numero+IT3.item_sucursal = F3.fact_tipo+F3.fact_numero+F3.fact_sucursal AND IT3.item_producto = IT1.item_producto
		GROUP BY F3.fact_cliente
		ORDER BY COUNT(*) DESC) AS top_cliente,
	   AVG(ISNULL(item_cantidad, 0) * ISNULL(item_precio, 0)) AS porcentaje_venta_total_anual

FROM Item_Factura IT1
JOIN Factura F1 ON IT1.item_tipo+IT1.item_numero+IT1.item_sucursal = F1.fact_tipo+F1.fact_numero+F1.fact_sucursal
JOIN Composicion C1 ON C1.comp_producto = IT1.item_producto
JOIN Producto P1 ON C1.comp_componente = P1.prod_codigo
GROUP BY item_producto, YEAR(F1.fact_fecha)
HAVING item_producto IN (SELECT TOP 1 IT2.item_producto
						 FROM Item_Factura IT2 
						 JOIN Factura F2 ON IT2.item_tipo+IT2.item_numero+IT2.item_sucursal = F2.fact_tipo+F2.fact_numero+F2.fact_sucursal AND YEAR(F1.fact_fecha) = YEAR(F2.fact_fecha)
						 JOIN Composicion ON comp_producto = item_producto
						 GROUP BY IT2.item_producto
						 ORDER BY COUNT(item_producto) DESC)
