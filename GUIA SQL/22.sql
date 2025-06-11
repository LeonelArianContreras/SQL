/*22. Escriba una consulta sql que retorne una estadistica de venta para todos los rubros por
trimestre contabilizando todos los años. Se mostraran como maximo 4 filas por rubro (1
por cada trimestre).
Se deben mostrar 4 columnas:
 Detalle del rubro
 Numero de trimestre del año (1 a 4)
 Cantidad de facturas emitidas en el trimestre en las que se haya vendido al
menos un producto del rubro
 Cantidad de productos diferentes del rubro vendidos en el trimestre 

El resultado debe ser ordenado alfabeticamente por el detalle del rubro y dentro de cada
rubro primero el trimestre en el que mas facturas se emitieron.

No se deberan mostrar aquellos rubros y trimestres para los cuales las facturas emitiadas
no superen las 100.

En ningun momento se tendran en cuenta los productos compuestos para esta
estadistica.*/

SELECT rubr_detalle, 
	   MONTH(fact_fecha) / 4 + 1 AS trimestre, 
	   COUNT(DISTINCT fact_tipo+fact_numero+fact_sucursal) AS cant_facturas, 
	   COUNT(DISTINCT prod_codigo) AS cant_productos
FROM Rubro
LEFT JOIN Producto ON rubr_id = prod_rubro 
	AND prod_codigo NOT IN (SELECT comp_producto FROM Composicion)
JOIN Item_Factura ON prod_codigo = item_producto
JOIN Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
GROUP BY rubr_detalle, MONTH(fact_fecha) / 4 + 1
HAVING COUNT(DISTINCT fact_tipo+fact_numero+fact_sucursal) > 100
ORDER BY rubr_detalle ASC, cant_facturas DESC