
CREATE FUNCTION total_precio_componentes(@producto VARCHAR(6))
RETURNS DECIMAL(12,2)
AS
BEGIN
	DECLARE @precio_combo_separado DECIMAL(12,2) = 0,
			@cant DECIMAL(12,2),
			@componente VARCHAR(10)

	-- Caso base
	IF(@producto NOT IN (SELECT comp_producto FROM Composicion))
		SET @precio_combo_separado = (SELECT prod_precio
									  FROM Producto
									  WHERE prod_codigo = @producto)
	ELSE
	BEGIN
		DECLARE cCompo CURSOR FOR
			SELECT comp_cantidad, P2.prod_codigo
			FROM Composicion
			JOIN Producto P2 ON P2.prod_codigo = comp_componente
			WHERE @producto = comp_producto

		OPEN cCompo
		FETCH NEXT FROM cCompo INTO 
			@cant,
			@componente

		-- Caso recursivo
		WHILE(@@FETCH_STATUS = 0)
			BEGIN
				SET @precio_combo_separado = @precio_combo_separado + @cant * dbo.total_precio_componentes(@componente)

				FETCH NEXT FROM cCompo INTO 
					@cant,
					@componente
			END
		CLOSE cCompo
		DEALLOCATE cCompo
	END
	RETURN @precio_combo_separado
END
