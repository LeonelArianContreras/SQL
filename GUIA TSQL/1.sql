/*1. Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.*/

ALTER FUNCTION ej1(@articulo VARCHAR(30), @deposito VARCHAR(30))
RETURNS VARCHAR(40)
AS
BEGIN
	DECLARE @stock_actual NUMERIC(10,2),
			@stock_maximo NUMERIC(10,2),
			@text VARCHAR(40)

	SELECT @stock_actual = stoc_cantidad, @stock_maximo = stoc_stock_maximo 
	FROM Stock
	WHERE stoc_producto = @articulo AND stoc_deposito = @deposito

	IF(@stock_actual < @stock_maximo)
		SET @text = 'OCUPACION DEL DEPOSITO' + STR(@stock_actual / @stock_maximo * 100) + '%'
	ELSE
		SET @text = 'DEPOSITO COMPLETO'
	
	RETURN @text
END
GO

SELECT dbo.ej1(stoc_producto, stoc_deposito) FROM STOCK