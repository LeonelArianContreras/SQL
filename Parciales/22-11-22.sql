--- SQL ---
SELECT P.prod_codigo,
	   P.prod_detalle,
	  (SELECT SUM(ISNULL(item_cantidad, 0))
	   FROM Item_Factura 
	   JOIN Factura ON item_tipo = fact_tipo 
			AND item_sucursal = fact_sucursal 
			AND item_numero = fact_numero 
			AND YEAR(fact_fecha) = 2012
	   WHERE item_producto IN (SELECT comp_componente
							   FROM Composicion
							   WHERE comp_producto = P.prod_codigo)),
	   SUM(ISNULL(item_cantidad, 0) * ISNULL(item_precio, 0))
FROM Producto P
JOIN Item_Factura ON item_producto = P.prod_codigo
JOIN Factura ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
WHERE P.prod_codigo IN (SELECT P1.prod_codigo
						FROM Producto P1
						JOIN Composicion ON comp_producto = P1.prod_codigo
						JOIN Producto P2 ON comp_componente = P2.prod_codigo
						GROUP BY P1.prod_codigo
						HAVING COUNT(comp_componente) = 3 AND COUNT(DISTINCT P2.prod_rubro) = 2)
GROUP BY P.prod_codigo, P.prod_detalle
ORDER BY (SELECT COUNT(DISTINCT fact_numero+fact_tipo+fact_sucursal)
	   FROM Item_Factura 
	   JOIN Factura ON item_tipo = fact_tipo 
			AND item_sucursal = fact_sucursal 
			AND item_numero = fact_numero 
			AND YEAR(fact_fecha) = 2012
	   WHERE item_producto IN (SELECT comp_componente
							   FROM Composicion
							   WHERE comp_producto = P.prod_codigo)) DESC


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