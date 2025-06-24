
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