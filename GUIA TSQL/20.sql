
/*20. Crear el/los objeto/s necesarios para mantener actualizadas las comisiones del
vendedor.
El cálculo de la comisión está dado por el 5% de la venta total efectuada por ese
vendedor en ese mes, más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.*/
GO
CREATE PROCEDURE ej20 
AS
BEGIN
	DECLARE @vendedor NUMERIC(6),
			@mes INT,
			@año INT

	BEGIN
		DECLARE cComi CURSOR FOR SELECT fact_vendedor, MONTH(fact_fecha), YEAR(fact_fecha)
								 FROM Factura
		OPEN cComi
		FETCH NEXT FROM cComi INTO @vendedor, @mes, @año

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF (SELECT COUNT(DISTINCT item_producto) 
				FROM Factura 
				JOIN Item_Factura ON item_tipo = fact_tipo 
					AND item_sucursal = fact_sucursal 
					AND item_numero = fact_numero 
					AND fact_vendedor = @vendedor AND YEAR(fact_fecha) = @año AND MONTH(fact_fecha) = @mes) >= 50
			BEGIN
				UPDATE Empleado
				SET empl_comision = 0.05 * 1.03 * (SELECT SUM(ISNULL(fact_total, 0))
												   FROM Factura
												   WHERE fact_vendedor = @vendedor AND YEAR(fact_fecha) = @año AND MONTH(fact_fecha) = @mes)			
				WHERE empl_codigo = @vendedor
			END
				
			ELSE
			BEGIN
				UPDATE Empleado
				SET empl_comision = 0.05 * (SELECT SUM(ISNULL(fact_total, 0))
										    FROM Factura
										    WHERE fact_vendedor = @vendedor AND YEAR(fact_fecha) = @año AND MONTH(fact_fecha) = @mes)			
				WHERE empl_codigo = @vendedor
			END
			FETCH NEXT FROM cComi INTO @vendedor, @mes, @año
		END
		CLOSE cComi
		DEALLOCATE cComi
	END
	RETURN
END
