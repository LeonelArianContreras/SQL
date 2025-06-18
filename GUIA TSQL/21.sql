/*21. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.*/
GO
CREATE OR ALTER TRIGGER ej21 ON Item_Factura INSTEAD OF INSERT
AS
BEGIN
	IF EXISTS (SELECT 1 
			   FROM inserted
			   JOIN Producto ON item_producto = prod_codigo
			   GROUP BY item_tipo, item_sucursal, item_numero
			   HAVING COUNT(DISTINCT prod_familia) > 1)
	BEGIN
		DELETE FROM Factura
		WHERE fact_tipo+fact_sucursal+fact_numero IN (SELECT item_tipo+item_sucursal+item_numero
													  FROM inserted
													  JOIN Producto ON item_producto = prod_codigo
													  GROUP BY item_tipo+item_sucursal+item_numero
													  HAVING COUNT(DISTINCT prod_familia) > 1)
		PRINT 'No puede comprar items de diferentes familias'
	END

	ELSE
	BEGIN
		INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
		SELECT item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio 
		FROM inserted
		WHERE item_tipo+item_sucursal+item_numero NOT IN (SELECT item_tipo+item_sucursal+item_numero
														  FROM inserted
														  JOIN Producto ON item_producto = prod_codigo
														  GROUP BY item_tipo+item_sucursal+item_numero
														  HAVING COUNT(DISTINCT prod_familia) > 1)
	END
END

BEGIN TRANSACTION
INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0003', 'FFFFFFF1', GETDATE(), 4, 100, 0, '01634')

INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
VALUES ('A', '0003', 'FFFFFFF1', '00000030', 1, 1),
	   ('A', '0003', 'FFFFFFF1', '00000123', 1, 1)

ROLLBACK

SELECT * FROM Factura WHERE fact_numero = 'FFFFFFF1'
SELECT * FROM Item_Factura WHERE item_numero = 'FFFFFFF1'
SELECT * FROM Producto WHERE prod_codigo = '00000030'

SELECT 1 
			   FROM Item_Factura
			   JOIN Producto ON item_producto = prod_codigo
			   GROUP BY item_tipo+item_sucursal+item_numero
			   HAVING COUNT(DISTINCT prod_familia) > 1

