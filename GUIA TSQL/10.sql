/*10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.*/
-- No se usa cursores porque éstos solo son necesarios para hacer validaciones o logica especifica para muchas filas, para operaciones CRUD son innecesarios


CREATE TRIGGER ej10 ON Producto AFTER DELETE
AS
BEGIN
	IF(SELECT COUNT(*) FROM deleted JOIN Stock ON stoc_producto = prod_codigo AND stoc_cantidad > 0) > 0
	BEGIN
		ROLLBACK
		RAISERROR('Operación inválida')
	END
END
GO

CREATE TRIGGER ej10 ON Producto INSTEAD OF DELETE
AS
BEGIN
	IF(SELECT COUNT(*) FROM deleted JOIN Stock ON stoc_producto = prod_codigo AND stoc_cantidad > 0) > 0
	BEGIN
		PRINT 'No puede borrar el artículo ahora mismo'
		ROLLBACK
	END
	ELSE
		DELETE FROM Producto
		WHERE prod_codigo IN (SELECT prod_codigo FROM deleted WHERE prod_codigo NOT IN (SELECT stoc_producto FROM Stock WHERE stoc_cantidad > 0))
END
GO
