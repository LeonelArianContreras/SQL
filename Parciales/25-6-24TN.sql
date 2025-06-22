--- SQL ---
SELECT prod_detalle,
	   CASE
		WHEN COUNT(DISTINCT item_tipo+item_sucursal+item_numero) > 100
		THEN 'Popular'
		ELSE 'Sin Interés'
		END AS leyenda_x_ventas,
	  COUNT(DISTINCT item_sucursal+item_tipo+item_numero) AS cant_facturas_2012,
	 (SELECT TOP 1 fact_cliente
	  FROM Item_Factura
	  JOIN Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
	  WHERE item_producto = P.prod_codigo AND YEAR(fact_fecha) = 2012
	  GROUP BY fact_cliente
	  ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC, fact_cliente ASC) AS cliente_estrella_2012
FROM Producto P
JOIN Item_Factura ON item_producto = P.prod_codigo
JOIN Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_detalle, prod_codigo
HAVING SUM(ISNULL(item_cantidad, 0) * ISNULL(item_cantidad, 0)) >
			0.15 * (SELECT AVG(item_cantidad * item_precio)
					FROM Item_Factura
					JOIN Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
					WHERE YEAR(fact_fecha) IN (2011, 2012))

--- TSQL ---
GO
CREATE FUNCTION cantDiasVendidoConsecutivamente (@producto CHAR(8), @fechaBase SMALLDATETIME)
RETURNS INT
AS
BEGIN
	DECLARE @cantDias INT,
			@fechaInicial SMALLDATETIME,
			@fechaSeguida SMALLDATETIME,
			@maxDias INT = 0
	
	DECLARE cDias CURSOR FOR SELECT fact_fecha
						     FROM Factura
							 JOIN Item_Factura ON fact_tipo = item_tipo AND fact_numero = item_numero AND fact_sucursal = item_sucursal
							 WHERE fact_fecha >= @fechaBase AND item_producto = @producto
	OPEN cDias
	FETCH NEXT FROM cDias INTO @fechainicial
	WHILE @@FETCH_STATUS = 0
	BEGIN
		FETCH NEXT FROM cDias INTO @fechaSeguida
		SET @cantDias = 1
		WHILE @@FETCH_STATUS = 0 AND @fechainicial = DATEADD(DAY, -1, @fechaSeguida) 
		BEGIN
			SET @cantDias = @cantDias + 1
			SET @fechaInicial = @fechaSeguida
			FETCH NEXT FROM cDias INTO @fechaSeguida
		END
		IF @maxDias < @cantDias
			SET @maxDias = @cantDias

		SET @fechaInicial = @fechaSeguida
	END
	CLOSE cDias
	DEALLOCATE cDias
	RETURN @maxDias
END
