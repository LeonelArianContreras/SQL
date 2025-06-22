--- SQL ---
SELECT prod_codigo,
	   prod_detalle,
	   depo_domicilio,
	  (SELECT COUNT(stoc_deposito)
	   FROM STOCK
	   WHERE stoc_cantidad > stoc_punto_reposicion AND stoc_producto = P.prod_codigo) AS cant_depos_repo
FROM Producto P
JOIN STOCK ON stoc_producto = P.prod_codigo
JOIN DEPOSITO D ON stoc_deposito = D.depo_codigo
WHERE stoc_cantidad = 0 or stoc_cantidad IS NULL 
	AND stoc_producto IN (SELECT stoc_producto
						  FROM STOCK 
						  WHERE stoc_producto > stoc_punto_reposicion
							AND stoc_deposito <> D.depo_codigo)
ORDER BY prod_codigo DESC

--- TSQL ---
GO
CREATE TRIGGER controlInflacionario ON Item_Factura AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT 1
			   FROM inserted IT1
			   JOIN Factura F ON F.fact_tipo = item_tipo AND F.fact_sucursal = item_sucursal AND F.fact_numero = item_numero
			   WHERE item_precio NOT BETWEEN
						   (SELECT TOP 1 item_precio
							FROM Item_Factura
							JOIN Factura ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = item_numero
							WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha) AND fact_fecha = DATEADD(MONTH, -1, F.fact_fecha) AND item_producto = IT1.item_producto)
				AND 1.05 * (SELECT TOP 1item_precio
							FROM Item_Factura
							JOIN Factura ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = item_numero
							WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha) AND fact_fecha = DATEADD(MONTH, -1, F.fact_fecha) AND item_producto = IT1.item_producto)
			  OR item_precio > 
					 1.5 * (SELECT TOP 1 item_precio
							FROM Item_Factura
							JOIN Factura ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = item_numero
							WHERE fact_fecha = DATEADD(MONTH, -12, F.fact_fecha) AND item_producto = IT1.item_producto))
	BEGIN
		ROLLBACK
		RAISERROR('No se puede vender ese item por cuestiones políticas y financieras', 16, 1)
	END
END

