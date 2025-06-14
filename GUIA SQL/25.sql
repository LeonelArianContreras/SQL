/*25. Realizar una consulta SQL que para cada año y familia muestre :
a. Año
b. El código de la familia más vendida en ese año.
c. Cantidad de Rubros que componen esa familia.
d. Cantidad de productos que componen directamente al producto más vendido de
esa familia.
e. La cantidad de facturas en las cuales aparecen productos pertenecientes a esa
familia. --> Considero que es por año 
f. El código de cliente que más compro productos de esa familia. --> Considero que es por año 
g. El porcentaje que representa la venta de esa familia respecto al total de venta
del año.
El resultado deberá ser ordenado por el total vendido por año y familia en forma
descendente.*/

SELECT YEAR(F1.fact_fecha),
	  (SELECT TOP 1 prod_familia 
	   FROM Producto
	   JOIN Item_Factura ON prod_codigo = item_producto
	   JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
	   WHERE YEAR(fact_fecha) = YEAR(F1.fact_fecha)
	   GROUP BY prod_familia
	   ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC) AS familia_mas_vendida,
	  (SELECT COUNT(DISTINCT prod_rubro)
	   FROM Producto 
	   JOIN Familia ON prod_familia = fami_id AND fami_id = (SELECT TOP 1 prod_familia 
															FROM Producto
															JOIN Item_Factura ON prod_codigo = item_producto
															JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
															WHERE YEAR(fact_fecha) = YEAR(F1.fact_fecha)
															GROUP BY prod_familia
															ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC)) 
	   AS cant_rubros,
	  (SELECT COUNT(DISTINCT P2.prod_codigo)
	   FROM Producto P1
	   JOIN Composicion C1 ON P1.prod_codigo = C1.comp_producto
	   JOIN Producto P2 ON P2.prod_codigo = comp_componente
	   WHERE P1.prod_codigo IN (SELECT TOP 1 prod_codigo
								FROM Producto
								JOIN Item_Factura ON item_producto = prod_codigo
								WHERE prod_familia =  (SELECT TOP 1 prod_familia 
													   FROM Producto
													   JOIN Item_Factura ON prod_codigo = item_producto
													   JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
													   WHERE YEAR(fact_fecha) = YEAR(F1.fact_fecha)
													   GROUP BY prod_familia
													   ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC)
								GROUP BY prod_codigo
								ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC)) AS cant_componentes_producto,
	  (SELECT COUNT(DISTINCT item_tipo+item_sucursal+item_numero)
	   FROM Item_Factura
	   JOIN Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal AND YEAR(fact_fecha) = YEAR(F1.fact_fecha)
	   JOIN Producto ON item_producto = prod_codigo
	   WHERE prod_familia = (SELECT TOP 1 prod_familia 
							 FROM Producto
							 JOIN Item_Factura ON prod_codigo = item_producto
							 JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND YEAR(fact_fecha) = YEAR(F1.fact_fecha)
							 GROUP BY prod_familia
							 ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC))
	  AS cant_facturas,
	 (SELECT TOP 1 fact_cliente
	  FROM Factura
	  JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal AND YEAR(fact_fecha) = YEAR(F1.fact_fecha)
	  JOIN Producto ON prod_codigo = item_producto
	  WHERE prod_familia = (SELECT TOP 1 prod_familia 
							FROM Producto
							JOIN Item_Factura ON prod_codigo = item_producto
							JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
							WHERE YEAR(fact_fecha) = YEAR(F1.fact_fecha)
							GROUP BY prod_familia
							ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC)
	  GROUP BY fact_cliente
	  ORDER BY COUNT(DISTINCT fact_cliente) DESC) AS cliente_mas_comprador,
	 (SELECT SUM(ISNULL(item_cantidad, 0) * ISNULL(item_precio, 0))
	  FROM Item_Factura
	  JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND YEAR(fact_fecha) = YEAR(F1.fact_fecha)
	  JOIN Producto ON item_producto = prod_codigo
	  WHERE prod_familia = (SELECT TOP 1 prod_familia 
							FROM Producto
							JOIN Item_Factura ON prod_codigo = item_producto
							JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
							WHERE YEAR(fact_fecha) = YEAR(F1.fact_fecha)
							GROUP BY prod_familia
							ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC))
	 * 100 / SUM(F1.fact_total) AS porcentaje_venta_anual
FROM Factura F1
GROUP BY YEAR(F1.fact_fecha)


