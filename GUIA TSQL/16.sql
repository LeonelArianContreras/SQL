/*16. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto.*/

GO
CREATE TRIGGER ej16 ON Item_Factura AFTER INSERT
AS
BEGIN
	DECLARE @depo VARCHAR(10),
			@cant INT,
			@prod VARCHAR(10),
			@componente VARCHAR(10),
			@cant_en_depo INT,
			@ultimo_depo VARCHAR(10)
	
	IF (SELECT COUNT(*) FROM inserted) > 0
	BEGIN
		DECLARE cVenta CURSOR FOR SELECT item_cantidad, item_producto
								  FROM inserted

		OPEN cVenta
		FETCH NEXT FROM cVenta INTO @cant, @prod

		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE cDepo CURSOR FOR SELECT stoc_deposito, stoc_cantidad
								     FROM Stock
									 WHERE stoc_producto = @prod
									 ORDER BY stoc_cantidad DESC
			OPEN cDepo
			FETCH NEXT FROM cDepo INTO @depo, @cant_en_depo
			
			WHILE @@FETCH_STATUS = 0 AND @cant_en_depo > 0
			BEGIN
				IF @cant_en_depo >= @cant
				BEGIN
					UPDATE Stock
					SET stoc_cantidad = stoc_cantidad - @cant
					WHERE stoc_producto = @prod AND stoc_deposito = @depo
				END

				ELSE
				BEGIN
					UPDATE Stock
					SET stoc_cantidad = 0
					WHERE stoc_producto = @prod AND stoc_deposito = @depo
				END
				
				SET @cant = @cant - @cant_en_depo
				SET @ultimo_depo = @depo
				FETCH NEXT FROM cDepo INTO @depo, @cant_en_depo
			END

			IF @cant > 0
			BEGIN
				UPDATE Stock
				SET stoc_cantidad = stoc_cantidad - @cant
				WHERE stoc_producto = @prod AND stoc_deposito = @ultimo_depo
			END

			CLOSE cDepo
			DEALLOCATE cDepo
			FETCH NEXT FROM cVenta INTO @cant, @prod
		END

		CLOSE cVenta
		DEALLOCATE cVenta
	END
END

SELECT TOP 1 stoc_deposito
FROM Stock 
WHERE stoc_producto = '00000030' AND stoc_cantidad > 222
ORDER BY stoc_cantidad DESC

select * from stock