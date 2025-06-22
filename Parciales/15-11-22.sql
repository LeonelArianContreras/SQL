SELECT P1.prod_codigo,
	   P1.prod_detalle
FROM Producto P1
JOIN Composicion ON P1.prod_codigo = comp_producto
JOIN Producto P2 ON P2.prod_codigo = comp_componente
JOIN Rubro ON P2.prod_rubro = rubr_id
JOIN Item_Factura ON item_producto = P2.prod_codigo
JOIN Factura ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
GROUP BY P1.prod_codigo, P1.prod_detalle
HAVING COUNT(P2.prod_codigo) = 3 AND COUNT(DISTINCT P2.prod_rubro) = 2

--- SQL ---
SELECT F.fact_cliente,
	  (SELECT TOP 1 item_producto
	   FROM Item_Factura
	   JOIN Factura ON item_tipo = fact_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
	   WHERE YEAR(fact_fecha) = 2012 AND fact_cliente = F.fact_cliente
	   GROUP BY item_producto
	   ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC) AS producto_estrella,

	  (SELECT TOP 1 prod_detalle
	   FROM Producto
	   JOIN Item_Factura ON item_producto = prod_codigo
	   JOIN Factura ON item_tipo = fact_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
	   WHERE YEAR(fact_fecha) = 2012 AND fact_cliente = F.fact_cliente
	   GROUP BY prod_detalle
	   ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC) AS detalle_producto_estrella,

	   COUNT(DISTINCT item_producto) AS cant_prod_comprados,
	  (SELECT SUM(ISNULL(item_cantidad, 0))
	   FROM Item_Factura
	   JOIN Factura ON item_tipo = fact_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
	   WHERE fact_cliente = F.fact_cliente AND item_producto IN (SELECT comp_producto FROM Composicion)) AS cant_combos_comprados

FROM Factura F
JOIN Item_Factura IT ON IT.item_tipo = F.fact_tipo AND F.fact_numero = IT.item_numero AND F.fact_sucursal = IT.item_sucursal
WHERE YEAR(F.fact_fecha) = 2012 AND F.fact_cliente IN (SELECT fact_cliente
													   FROM Factura 
													   JOIN Item_Factura ON item_tipo = fact_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
													   JOIN Producto ON prod_codigo = item_producto
													   GROUP BY fact_cliente
													   HAVING COUNT(DISTINCT prod_rubro) = (SELECT COUNT(*) FROM Rubro))
GROUP BY F.fact_cliente
ORDER BY (SELECT clie_razon_social FROM Cliente WHERE clie_codigo = F.fact_cliente) ASC,
		 CASE
			WHEN SUM(ISNULL(fact_total, 0)) 
				BETWEEN 0.20 * (SELECT SUM(ISNULL(fact_total, 0)) FROM Factura WHERE YEAR(fact_fecha) = 2012)
						AND 0.30 * (SELECT SUM(ISNULL(fact_total, 0)) FROM Factura WHERE YEAR(fact_fecha) = 2012)
			THEN 0
			ELSE 1
		 END

--- TSQL ---
CREATE TRIGGER 
