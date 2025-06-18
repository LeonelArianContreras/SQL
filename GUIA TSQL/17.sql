/*17. Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock*/
GO
CREATE TRIGGER ej17 ON Stock FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted WHERE stoc_cantidad > stoc_stock_maximo OR stoc_cantidad < stoc_punto_reposicion)
	BEGIN
		ROLLBACK
		RAISERROR('Stock invalido', 16, 1)
	END
END

BEGIN TRANSACTION
UPDATE Stock
SET stoc_cantidad = 51
WHERE stoc_producto = '00000030' AND stoc_deposito = '00'
ROLLBACK

SELECT * FROM STOCK