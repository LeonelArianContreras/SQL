/*11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferente de
productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
el año 2012.*/

SELECT fami_detalle, COUNT(DISTINCT item_producto), SUM(isnull(item_precio * item_cantidad, 0))
FROM Familia JOIN Producto ON fami_id = prod_familia --> No cambia atomicidad
JOIN Item_Factura ON prod_codigo = item_producto --> Cambia atomicidad
GROUP BY fami_detalle, fami_id --> En el HAVING va toda columna de dato simple (No aggregate functions) que se usa en el HAVING y en el SELECT
HAVING fami_id IN (SELECT prod_familia --> El IN lo que hace es buscar el fami_id en toda fila de la columna que devuelve la subquery, 
									   --> va haciendo como un if(fami_id == prod_familia) ..., por eso no hace falta hacer el WHERE prod_familia = fami_id 
									   --> como SÍ habría que hacerlo si usas EXISTS (no eficiente)
				   FROM Producto JOIN Item_Factura ON prod_codigo = item_producto --> Cambia atomicidad
				   JOIN Factura ON item_numero+item_sucursal+item_tipo=fact_numero+fact_sucursal+fact_tipo --> No cambia atomicidad
				   WHERE YEAR(fact_fecha) = 2012 --> Siempre las comparaciones particulares van en el WHERE!!!
				   GROUP BY prod_familia
				   HAVING SUM(isnull(item_precio * item_cantidad, 0)) > 20000)				  
ORDER BY 2 DESC