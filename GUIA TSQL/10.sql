/*10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.*/
-- No sé por qué el profe no usa cursor, pero bueno
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
		WHERE prod_codigo = (SELECT prod_codigo FROM deleted)
END
GO

