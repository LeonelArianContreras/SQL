--- SQL ---
SELECT P1.prod_codigo,
       P1.prod_detalle,
	  (SELECT SUM(ISNULL(item_cantidad, 0))
	   FROM Item_Factura
	   JOIN Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
	   WHERE YEAR(fact_fecha) = 2012 AND item_producto IN (SELECT comp_componente
														   FROM Composicion
														   WHERE comp_producto = P1.prod_codigo)) AS cant_ventas_componentes,
	  (SELECT SUM(ISNULL(item_cantidad, 0) * ISNULL(item_cantidad, 0))
	   FROM Item_Factura
	   WHERE item_producto = P1.prod_codigo) AS monto_total
FROM Producto P1
WHERE P1.prod_codigo IN (SELECT comp_producto
					  FROM Composicion
					  JOIN Producto PP ON PP.prod_codigo = comp_componente
					  GROUP BY comp_producto
					  HAVING COUNT(comp_componente) = 3 AND COUNT(DISTINCT PP.prod_rubro) = 2)
ORDER BY (SELECT COUNT(DISTINCT item_tipo+item_sucursal+item_numero)
		  FROM Item_Factura
		  JOIN Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
		  WHERE YEAR(fact_fecha) = 2012 AND item_producto IN (SELECT comp_componente
															  FROM Composicion
														      WHERE comp_producto = P1.prod_codigo))


--- TSQL ---
GO
CREATE TRIGGER comboDeMismoRubro ON Producto FOR INSERT, UPDATE, DELETE
AS
BEGIN
	IF EXISTS (SELECT 1
			   FROM inserted P1
			   JOIN Composicion ON comp_producto = P1.prod_codigo
			   JOIN Producto P2 ON comp_componente = P2.prod_codigo
			   GROUP BY P1.prod_codigo
			   HAVING COUNT(P2.prod_rubro) > 1)
	BEGIN
		ROLLBACK
		RAISERROR('Un producto no puede tener componentes con rubros distintos al que tiene él', 16, 1)
	END
END

--- Tests ---
SELECT P1.prod_codigo
FROM Producto P1
JOIN Composicion ON comp_producto = P1.prod_codigo
JOIN Producto P2 ON comp_componente = P2.prod_codigo
GROUP BY P1.prod_codigo
HAVING COUNT(P2.prod_rubro) > 1

SELECT * FROM Composicion

SELECT prod_rubro FROM Producto WHERE prod_codigo = '00001123'