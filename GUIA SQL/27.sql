/*27. Escriba una consulta sql que retorne una estadística basada en la facturacion por año y
envase devolviendo las siguientes columnas:
 Año
 Codigo de envase
 Detalle del envase
 Cantidad de productos que tienen ese envase
 Cantidad de productos facturados de ese envase
 Producto mas vendido de ese envase
 Monto total de venta de ese envase en ese año
 Porcentaje de la venta de ese envase respecto al total vendido de ese año
Los datos deberan ser ordenados por año y dentro del año por el envase con más
facturación de mayor a menor*/

SELECT YEAR(F1.fact_fecha) AS año,
	   E1.enva_codigo,
	   E1.enva_detalle,
	  (SELECT COUNT(DISTINCT prod_codigo)
	   FROM Producto
	   WHERE prod_envase = E1.enva_codigo
	  ) AS cant_productos,  
	   COUNT(DISTINCT item_producto) AS cant_facturados,
	  (SELECT TOP 1 item_producto
	   FROM Item_Factura
	   JOIN Producto ON item_producto = prod_codigo AND prod_envase = E1.enva_codigo
	   JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero AND YEAR(fact_fecha) = YEAR(F1.fact_fecha)
	   GROUP BY item_producto
	   ORDER BY SUM(ISNULL(item_cantidad, 0))) AS producto_estrella,
	   SUM(ISNULL(item_cantidad, 0) * ISNULL(item_precio, 0)) AS monto_total,

	   SUM(ISNULL(item_cantidad, 0) * ISNULL(item_precio, 0)) * 100 /
	   (SELECT SUM(ISNULL(item_cantidad, 0) * ISNULL(item_precio, 0))
	    FROM Item_Factura) AS porcentaje_venta
FROM Factura F1
JOIN Item_Factura IT1 ON IT1.item_tipo+IT1.item_sucursal+IT1.item_numero = F1.fact_tipo+F1.fact_sucursal+F1.fact_numero
RIGHT JOIN Producto P1 ON IT1.item_producto = P1.prod_codigo
RIGHT JOIN Envases E1 ON P1.prod_envase = E1.enva_codigo --> Pongo el RIGHT ya que el WHERE que hago en el subselect, si no hay item facturado para un envase, ese envase no existiría cuando vaya al subselect. Con el RIGHT me aseguro que no pase eso
GROUP BY YEAR(F1.fact_fecha), E1.enva_codigo, E1.enva_detalle
ORDER BY monto_total DESC