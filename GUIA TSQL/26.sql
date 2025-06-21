/*26. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.*/
GO
CREATE OR ALTER TRIGGER ej26 ON Item_Factura FOR INSERT
AS
BEGIN
	DECLARE @factura CHAR(13)

	IF EXISTS (SELECT 1
			   FROM inserted
			   WHERE item_producto IN (SELECT comp_componente FROM Composicion))
	BEGIN
		PRINT 'HOLA'
		DECLARE cItem CURSOR FOR SELECT item_tipo+item_numero+item_sucursal
								 FROM inserted
								 WHERE item_producto IN (SELECT comp_componente FROM Composicion) 
								 GROUP BY item_tipo+item_numero+item_sucursal
		OPEN cItem
		FETCH NEXT FROM cItem INTO @factura
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM Item_Factura
			WHERE item_tipo+item_numero+item_sucursal = @factura

			DELETE FROM Factura
			WHERE fact_tipo+fact_numero+fact_sucursal = @factura
			
			PRINT 'No pueden facturarse productos que sean componentes de otros'
			FETCH NEXT FROM cItem INTO @factura
		END
		CLOSE cItem
		DEALLOCATE cItem
	END
END
GO

BEGIN TRANSACTION
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0003', 'FAFAFAFA', GETDATE(), 4, 1, 0, '01634')
INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0003', 'FAFAFAFA', '00001109', 0, 0)
ROLLBACK

SELECT * FROM Item_Factura
SELECT * FROM Factura WHERE fact_numero = 'FAFAFAFA'
SELECT * FROM Item_Factura WHERE item_numero = 'FAFAFAFA'
SELECT * FROM Composicion
