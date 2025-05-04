/*7. Generar una consulta que muestre para cada artículo código, detalle, mayor precio
menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
stock. */

SELECT prod_codigo, prod_detalle, MAX(item_precio) as max_precio, MIN(item_precio) as min_precio, (MAX(item_precio)-MIN(item_precio))/MIN(item_precio) * 100 AS dif_porcentual_max_min
FROM Producto JOIN Item_Factura ON prod_codigo = item_producto -- Cambia la atomicidad
GROUP BY prod_codigo, prod_detalle
HAVING prod_codigo IN (SELECT item_producto 
					   FROM Item_Factura JOIN Stock ON item_producto = stoc_producto --> No cambia atomicidad
					   GROUP BY item_producto
					   HAVING SUM(stoc_cantidad) > 0)
ORDER BY 1
