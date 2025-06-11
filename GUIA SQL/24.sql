/*24. Escriba una consulta que considerando solamente las facturas correspondientes a los
dos vendedores con mayores comisiones, retorne los productos con composición
facturados al menos en cinco facturas,
La consulta debe retornar las siguientes columnas:
 Código de Producto
 Nombre del Producto
 Unidades facturadas
El resultado deberá ser ordenado por las unidades facturadas descendente.*/

SELECT prod_codigo, 
	   prod_detalle, 
	   SUM(ISNULL(IT1.item_cantidad, 0)) AS cant_unidades_facturadas
FROM Producto P1
JOIN Item_Factura IT1 ON IT1.item_producto = P1.prod_codigo
JOIN Factura F1 ON F1.fact_tipo = IT1.item_tipo AND 
				   F1.fact_sucursal = IT1.item_sucursal AND 
				   F1.fact_numero = IT1.item_numero
JOIN Composicion C1 ON P1.prod_codigo = C1.comp_producto
WHERE F1.fact_vendedor IN (SELECT TOP 2 empl_codigo
							FROM Empleado
							GROUP BY empl_codigo
							ORDER BY SUM(ISNULL(empl_comision, 0)) DESC)
GROUP BY prod_codigo, prod_detalle
HAVING COUNT(DISTINCT F1.fact_tipo+F1.fact_sucursal+F1.fact_numero) >= 5
ORDER BY SUM(ISNULL(IT1.item_cantidad, 0)) DESC
