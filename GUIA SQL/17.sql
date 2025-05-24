/*17. Escriba una consulta que retorne una estadística de ventas por año y mes para cada
producto.
La consulta debe retornar:
PERIODO: Año y mes de la estadística con el formato YYYYMM
PROD: Código de producto
DETALLE: Detalle del producto
CANTIDAD_VENDIDA= Cantidad vendida del producto en el periodo
VENTAS_AÑO_ANT= Cantidad vendida del producto en el mismo mes del periodo
pero del año anterior
CANT_FACTURAS= Cantidad de facturas en las que se vendió el producto en el
periodo
La consulta no puede mostrar NULL en ninguna de sus columnas y debe estar ordenada
por periodo y código de producto.
*/

SELECT isnull(STR(YEAR(F1.fact_fecha), 4) + '/' + RIGHT('00' + LTRIM(STR(MONTH(F1.fact_fecha), 2)), 2), 'No vendido') AS periodo, 
	   prod_codigo, prod_detalle, SUM(isnull(item_cantidad, 0)),
	   isnull((SELECT SUM(isnull(item_cantidad, 0)) 
	    FROM Item_Factura IT2 JOIN Factura F2 ON IT2.item_tipo+IT2.item_sucursal+IT2.item_numero = F2.fact_tipo+F2.fact_sucursal+F2.fact_numero
											AND YEAR(F2.fact_fecha) = (YEAR(F1.fact_fecha) - 1) AND MONTH(F2.fact_fecha) = MONTH(F1.fact_fecha)), 0),
	   COUNT(fact_numero)
FROM Producto JOIN Item_Factura ON prod_codigo = item_producto --> Cambia atomicidad
		      JOIN Factura F1 ON item_tipo+item_sucursal+item_numero = F1.fact_tipo+F1.fact_sucursal+F1.fact_numero --> No cambia atomicidad
GROUP BY YEAR(f1.fact_fecha), MONTH(f1.fact_fecha), prod_codigo, prod_detalle
ORDER BY 1, prod_codigo DESC
