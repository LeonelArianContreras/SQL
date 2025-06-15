/*7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. Debe
insertar una línea por cada artículo con los movimientos de stock generados por
las ventas entre esas fechas. La tabla se encuentra creada y vacía.*/

CREATE TABLE VentasEj7 (
	articulo VARCHAR(10),
	detalle VARCHAR(50),
	cant_movimientos NUMERIC(5),
	precio NUMERIC(10,4),
	ganancia NUMERIC(12,4)
)
GO

CREATE PROCEDURE ej7 @fechaInicio SMALLDATETIME, @fechaFin SMALLDATETIME
AS
BEGIN
	DECLARE @producto VARCHAR(10),
			@prod_detalle VARCHAR(50),
			@cantidad NUMERIC(4),
			@promedioPrecio NUMERIC(10,2),
			@ganancia NUMERIC(10,2)

	BEGIN
	DECLARE cVenta CURSOR FOR
		SELECT prod_codigo,
			   prod_detalle,
			   COUNT(item_producto),
			   AVG(item_precio),
			   SUM((item_precio - prod_precio) * item_cantidad)
		FROM Producto
		JOIN Item_Factura ON prod_codigo = item_producto
		JOIN Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
			AND fact_fecha BETWEEN @fechaInicio AND @fechaFin
		GROUP BY prod_codigo, prod_detalle

	OPEN cVenta
	FETCH NEXT FROM cVenta INTO @producto,
								@prod_detalle,
								@cantidad,
								@promedioPrecio,
								@ganancia
	
	WHILE(@@FETCH_STATUS = 0) 
		BEGIN
			INSERT INTO VentasEj7 (
				articulo,
				detalle,
				cant_movimientos,
				precio,
				ganancia
			)
			VALUES (
				@producto,
				@prod_detalle,
				@cantidad,
				@promedioPrecio,
				@ganancia
			)

			FETCH NEXT FROM cVenta INTO @producto,
								@prod_detalle,
								@cantidad,
								@promedioPrecio,
								@ganancia
		END
		CLOSE cVenta
		DEALLOCATE cVenta
	END
	RETURN
END

BEGIN
EXEC dbo.ej7 @fechaInicio = '2009-12-12', @fechaFin = '2014-12-12'
END

SELECT * FROM VentasEj7