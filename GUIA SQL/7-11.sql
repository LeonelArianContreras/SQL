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


/*8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.*/

SELECT prod_detalle, MAX(stoc_cantidad) 
FROM Producto JOIN Stock ON prod_codigo = stoc_producto -- Cambia la atomicidad
GROUP BY prod_detalle
HAVING COUNT(DISTINCT stoc_producto) = (SELECT COUNT(*) FROM Deposito)


/*9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
mismo y la cantidad de depósitos que ambos tienen asignados.*/

SELECT empl_jefe, empl_codigo, empl_nombre, (SELECT COUNT(depo_encargado) 
										     FROM Deposito WHERE depo_encargado = empl_codigo) + 
											(SELECT COUNT(depo_encargado) 
											 FROM Deposito WHERE depo_encargado = empl_jefe) 
FROM Empleado

--> Resolución del profesor, la anterior es la mía
select empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre), count(depo_codigo) 
from Empleado left join DEPOSITO on empl_codigo = depo_encargado or empl_jefe = depo_encargado
group by empl_jefe, empl_codigo, rtrim(empl_apellido)+' '+rtrim(empl_nombre)


/*10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
mayor compra realizo.*/

SELECT prod_codigo, (SELECT TOP 1 clie_codigo 
					 FROM Cliente JOIN Factura ON fact_cliente = clie_codigo 
					 GROUP BY clie_codigo 
					 ORDER BY COUNT(fact_cliente) DESC)
FROM Producto
GROUP BY prod_codigo
HAVING prod_codigo IN (SELECT TOP 10 item_producto
					   FROM Item_Factura
					   WHERE item_producto = prod_codigo
					   GROUP BY item_producto
					   ORDER BY SUM(item_cantidad) DESC)
	OR prod_codigo IN (SELECT TOP 10 item_producto
					   FROM Item_Factura
					   WHERE item_producto = prod_codigo
					   GROUP BY item_producto
					   ORDER BY SUM(item_cantidad) ASC)

/*Cuando usamos las subqueries como en el IN, no podemos poner dos columnas ya que rompe todo, si queremos un criterio, directamente lo ponemos en el ORDER BY, como lo
hicimos con SUM(item_cantidad) DESC o en la primer subquery de cliente con COUNT(fact_cliente) DESC*/

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
