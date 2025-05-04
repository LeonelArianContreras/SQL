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