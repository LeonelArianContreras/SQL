/*9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.*/

CREATE TRIGGER ej9 ON Item_Factura AFTER INSERT, DELETE
AS
BEGIN
	DECLARE @articulo VARCHAR(10),
			@cant INT,
			@depo VARCHAR(10)

	-- Para alta
	IF (SELECT COUNT(*) FROM inserted) > 0
	BEGIN
		DECLARE cAlta CURSOR FOR SELECT item_cantidad, item_producto
								 FROM Item_Factura
								 JOIN Composicion ON item_producto = comp_producto
		OPEN cAlta
		FETCH NEXT FROM cAlta INTO @cant, @articulo

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @depo = (SELECT TOP 1 stoc_deposito 
						 FROM Stock 
						 WHERE stoc_producto = @articulo
						 ORDER BY stoc_cantidad DESC)
			IF @depo IS NULL
			BEGIN
				PRINT 'No es posible realizar esta operación'
				CLOSE cAlta
				DEALLOCATE cAlta
				ROLLBACK --> Si algo sale mal, es decir, entra a este if, tira un rollback, es decir, vuelve a su estado inicial como si nada hubiese pasado
			END

			UPDATE Stock
			SET stoc_cantidad = stoc_cantidad - @cant
			WHERE stoc_producto = @articulo AND stoc_deposito = @depo

			FETCH NEXT FROM cAlta INTO @articulo, @cant
		END
	END
	
	-- Para baja
	ELSE
	BEGIN
		DECLARE cBaja CURSOR FOR SELECT item_cantidad, item_producto
								 FROM Item_Factura
								 JOIN Composicion ON item_producto = comp_producto
		OPEN cBaja
		FETCH NEXT FROM cBaja INTO @cant, @articulo

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @depo = (SELECT TOP 1 stoc_deposito 
						 FROM Stock 
						 WHERE stoc_producto = @articulo
						 ORDER BY stoc_cantidad DESC)

			IF @depo IS NULL
			BEGIN
				PRINT 'No es posible realizar esta operación'
				CLOSE cBaja
				DEALLOCATE cBaja
				ROLLBACK
			END

			UPDATE Stock
			SET stoc_cantidad = stoc_cantidad + @cant
			WHERE stoc_producto = @articulo AND stoc_deposito = @depo

			FETCH NEXT FROM cBaja INTO @cant, @articulo
		END
		
	END
	CLOSE cBaja
	DEALLOCATE cBaja
END
