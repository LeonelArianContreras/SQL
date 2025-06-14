
/*28. Escriba una consulta sql que retorne una estadística por Año y Vendedor que retorne las
siguientes columnas:
 Año.
 Codigo de Vendedor
 Detalle del Vendedor
 Cantidad de facturas que realizó en ese año
 Cantidad de clientes a los cuales les vendió en ese año.
 Cantidad de productos facturados con composición en ese año
 Cantidad de productos facturados sin composicion en ese año.
 Monto total vendido por ese vendedor en ese año
Los datos deberan ser ordenados por año y dentro del año por el vendedor que haya
vendido mas productos diferentes de mayor a menor.*/

SELECT YEAR(F1.fact_fecha),
	   F1.fact_vendedor,
	   E1.empl_apellido,
	   COUNT(DISTINCT fact_tipo+fact_sucursal+fact_numero) AS cant_facturas,
	   COUNT(DISTINCT fact_cliente) AS cant_clientes,
	  (SELECT COUNT(DISTINCT item_producto)
	   FROM Item_Factura
	   JOIN Producto P2 ON item_producto = P2.prod_codigo AND prod_codigo IN (SELECT P3.prod_codigo FROM Producto P3 JOIN Composicion ON P3.prod_codigo = comp_producto)
	   JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND YEAR(fact_fecha) = YEAR(F1.fact_fecha) AND E1.empl_codigo = fact_vendedor) AS cant_compuestos_facturados,
	  (SELECT COUNT(DISTINCT item_producto)
	   FROM Item_Factura 
	   JOIN Producto ON item_producto = prod_codigo AND prod_codigo NOT IN (SELECT P3.prod_codigo FROM Producto P3 JOIN Composicion ON P3.prod_codigo = comp_producto)
	   JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND YEAR(fact_fecha) = YEAR(F1.fact_fecha) AND E1.empl_codigo = fact_vendedor) AS cant_no_compuestos_facturados
FROM Factura F1
JOIN Item_Factura IT1 ON IT1.item_tipo+IT1.item_sucursal+IT1.item_numero = F1.fact_tipo+F1.fact_sucursal+F1.fact_numero
JOIN Empleado E1 ON F1.fact_vendedor = E1.empl_codigo
GROUP BY YEAR(F1.fact_fecha), F1.fact_vendedor, E1.empl_apellido, E1.empl_codigo
ORDER BY YEAR(F1.fact_fecha) DESC, COUNT(DISTINCT item_producto) DESC