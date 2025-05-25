/*18. Escriba una consulta que retorne una estadística de ventas para todos los rubros.
La consulta debe retornar:
DETALLE_RUBRO: Detalle del rubro
VENTAS: Suma de las ventas en pesos de productos vendidos de dicho rubro
PROD1: Código del producto más vendido de dicho rubro
PROD2: Código del segundo producto más vendido de dicho rubro
CLIENTE: Código del cliente que compro más productos del rubro en los últimos 30
días
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por cantidad de productos diferentes vendidos del rubro.*/

SELECT rubr_detalle, SUM(isnull(item_cantidad, 0) * isnull(item_precio, 0)),
	ISNULL((SELECT TOP 1 P1.prod_codigo
	 FROM Producto P1 JOIN Item_Factura ON item_producto = P1.prod_codigo
	 WHERE prod_rubro = rubr_id
	 GROUP BY P1.prod_codigo
	 ORDER BY SUM(isnull(item_cantidad, 0)) DESC), 'N/A'),

	ISNULL((SELECT TOP 1 prod_codigo
			FROM Producto
			WHERE prod_rubro = rubr_id
			GROUP BY prod_codigo
			HAVING prod_codigo NOT IN (SELECT TOP 1 P1.prod_codigo
									   FROM Producto P1 JOIN Item_Factura ON item_producto = P1.prod_codigo
									   WHERE prod_rubro = rubr_id
									   GROUP BY P1.prod_codigo
									   ORDER BY SUM(isnull(item_cantidad, 0)) DESC)), 'N/A'),

	ISNULL((SELECT TOP 1 fact_cliente
			FROM Factura JOIN Item_Factura ON item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo
						 JOIN Producto ON prod_codigo = item_producto AND prod_rubro = rubr_id
			WHERE fact_fecha >= DATEADD(DAY, -30, GETDATE())
			GROUP BY fact_cliente
			ORDER BY SUM(isnull(item_cantidad, 0)) DESC), 'N/A')
	 
FROM Rubro JOIN Producto ON prod_rubro = rubr_id
		   JOIN Item_Factura ON prod_codigo = item_producto
GROUP BY rubr_detalle, rubr_id
ORDER BY COUNT(DISTINCT item_producto) DESC