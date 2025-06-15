/*8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por
cantidad de sus componentes, se aclara que un producto que compone a otro,
también puede estar compuesto por otros y así sucesivamente, la tabla se debe
crear y está formada por las siguientes columnas:*/
GO
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


GO
CREATE PROCEDURE ej8 
AS
BEGIN
	INSERT INTO Diferencias (
		codigo,
		detalle,
		cant_componentes,
		precio_total_componentes,
		precio_producto
	) 
	SELECT P1.prod_codigo,
		   P1.prod_detalle,
		   COUNT(DISTINCT P2.prod_codigo),
		   dbo.total_precio_componentes(IT1.item_producto),
		   P1.prod_precio
	FROM Producto P1
	JOIN Composicion ON comp_producto = P1.prod_codigo
	JOIN Producto P2 ON P2.prod_codigo = comp_componente
	JOIN Item_Factura IT1 ON IT1.item_producto = P1.prod_codigo 
		AND IT1.item_precio <> dbo.total_precio_componentes(IT1.item_producto)
	GROUP BY P1.prod_codigo, P1.prod_detalle, P1.prod_precio

	RETURN
END
