--- SQL ---
SELECT ROW_NUMBER() OVER (ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC) AS nro_fila,
	   clie_codigo,
	   clie_razon_social,
	   SUM(ISNULL(item_cantidad, 0)) AS cantidades_facturadas,
	  (SELECT TOP 1 prod_familia
	   FROM Producto
	   JOIN Item_Factura ON item_producto = prod_codigo
	   JOIN Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
	   WHERE fact_cliente = C.clie_codigo
	   GROUP BY prod_familia
	   ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC) AS familia_estrella_2012
FROM Cliente C
JOIN Factura ON fact_cliente = C.clie_codigo
JOIN Item_Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
WHERE clie_codigo IN (SELECT fact_cliente
					  FROM Factura F1
					  JOIN Item_Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
					  JOIN Producto ON prod_codigo = item_producto
					  WHERE YEAR(F1.fact_fecha) = 2012 
					  GROUP BY fact_cliente
					  HAVING COUNT(DISTINCT prod_rubro) > 3
							AND NOT EXISTS (SELECT 1
											FROM Factura
											WHERE YEAR(fact_fecha) % 2 = 0))
GROUP BY clie_codigo, clie_razon_social
ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC

--- TSQL ---
CREATE TABLE topDiezProductos (
	prod_codigo CHAR(8),
	año INT
)
GO
CREATE TRIGGER productosTop ON Item_Factura AFTER INSERT
AS
BEGIN
	INSERT INTO topDiezProductos (prod_codigo, año)
	SELECT YEAR(F1.fact_fecha) AS año,
		   item_producto
		   FROM Item_Factura 
		   JOIN Factura F1 ON F1.fact_tipo = item_tipo AND F1.fact_numero = item_numero AND F1.fact_sucursal = item_sucursal
		   WHERE item_producto IN (SELECT TOP 10 IT.item_producto
								   FROM Item_Factura IT
								   JOIN Factura F ON F.fact_tipo = IT.item_tipo AND F.fact_numero = IT.item_numero AND F.fact_sucursal = IT.item_sucursal
								   WHERE YEAR(F.fact_fecha) = YEAR(F1.fact_fecha)
								   GROUP BY IT.item_producto
								   ORDER BY SUM(ISNULL(IT.item_cantidad, 0)) DESC)
		   GROUP BY YEAR(F1.fact_fecha), item_producto
		   
END