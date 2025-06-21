/*23. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura.*/
GO
CREATE TRIGGER ej23 ON Item_Factura INSTEAD OF INSERT
AS
BEGIN
	DECLARE @factura CHAR(13)

	IF EXISTS (SELECT 1
			   FROM Item_Factura
			   JOIN Composicion ON comp_producto = item_producto
			   GROUP BY item_numero+item_tipo+item_sucursal
			   HAVING COUNT(item_producto) > 2)
	BEGIN
		DECLARE cFactura CURSOR FOR SELECT item_numero+item_sucursal+item_tipo
								    FROM inserted
		OPEN cFactura
		FETCH NEXT FROM cFactura INTO @factura

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @factura IN (SELECT item_numero+item_sucursal+item_tipo
							FROM inserted
							JOIN Composicion ON comp_producto = item_precio
							GROUP BY item_numero+item_sucursal+item_tipo
							HAVING COUNT(item_producto) > 2)
			BEGIN
				DELETE FROM Factura
				WHERE fact_numero+fact_sucursal+fact_tipo = @factura
			END

			ELSE
			BEGIN
				INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
				SELECT * FROM inserted WHERE item_numero+item_sucursal+item_tipo = @factura
			END
			SELECT * FROM Item_Factura
			FETCH NEXT FROM cFactura INTO @factura
		END
		CLOSE cFactura
		DEALLOCATE cFactura
	END
END
