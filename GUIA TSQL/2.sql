/*2. Realizar una función que dado un artículo y una fecha, retorne el stock que
existía en esa fecha*/

CREATE FUNCTION ej2(@articulo VARCHAR(30), @fecha SMALLDATETIME)
RETURNS NUMERIC(10,2)
AS
BEGIN
	DECLARE @stock NUMERIC(10,2), @fecha_prox_reposicion SMALLDATETIME
	SELECT @stock = stoc_cantidad, @fecha_prox_reposicion = stoc_proxima_reposicion
	FROM Stock
	WHERE stoc_producto = @articulo

	IF(@fecha < @fecha_prox_reposicion)
		RETURN @stock
	RETURN 0
END
GO