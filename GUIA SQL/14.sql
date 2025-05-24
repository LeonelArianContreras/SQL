/*14. Escriba una consulta que retorne una estadística de ventas por cliente. Los campos que
debe retornar son:
- Código del cliente
- Cantidad de veces que compro en el último año
- Promedio por compra en el último año
- Cantidad de productos diferentes que compro en el último año
- Monto de la mayor compra que realizo en el último año
Se deberán retornar todos los clientes ordenados por la cantidad de veces que compro en
el último año.
No se deberán visualizar NULLs en ninguna columna*/

SELECT clie_codigo, COUNT(fact_cliente), AVG(isnull(fact_total, 0)), MAX(isnull(fact_total, 0)), 
	(SELECT COUNT(DISTINCT item_producto)
	 FROM Item_Factura JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND
									YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
	 WHERE fact_cliente = clie_codigo)
FROM Cliente LEFT JOIN Factura ON clie_codigo = fact_cliente AND YEAR(fact_fecha) = (SELECT MAX(YEAR(fact_fecha)) FROM Factura)
GROUP BY clie_codigo
ORDER BY 2 DESC
/* La subquery es para no afectar el AVG, ya que si joineamos de vuelta con item_factura, tendriamos la misma factura n veces,
lo que generaría que se cuente el mismo total de una unica factura n veces */