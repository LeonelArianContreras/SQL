/*22. Se requiere recategorizar los rubros de productos, de forma tal que nigun rubro
tenga más de 20 productos asignados, si un rubro tiene más de 20 productos
asignados se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada.*/
GO
CREATE OR ALTER PROCEDURE ej22 
AS
BEGIN
	DECLARE 
			@rubro CHAR(4),
			@producto CHAR(8),
			@rubroDisponible CHAR(4),
			@idRubro CHAR(4)

	BEGIN
		DECLARE cRubros CURSOR FOR SELECT prod_rubro, prod_codigo
								   FROM Producto
								   
		OPEN cRubros
		FETCH NEXT FROM cRubros INTO @rubro,@producto
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF (SELECT COUNT(*) FROM Producto WHERE prod_rubro = @rubro) > 20
			BEGIN
				SET @rubroDisponible = (SELECT TOP 1 prod_rubro FROM Producto GROUP BY prod_rubro HAVING COUNT(*) < 20)
				IF @rubroDisponible IS NOT NULL
				BEGIN
					UPDATE Producto
					SET prod_rubro = @rubroDisponible
					WHERE prod_codigo = @producto 
				END

				ELSE
				BEGIN
					IF 'RUBRO REASIGNADO' IN (SELECT rubr_detalle FROM Rubro)
					BEGIN
						UPDATE Producto
						SET prod_rubro = (SELECT rubr_id FROM Rubro WHERE rubr_detalle = 'RUBRO REASIGNADO')
						WHERE prod_codigo = @producto
					END
					ELSE
					BEGIN
						INSERT INTO Rubro (rubr_id, rubr_detalle)
						VALUES ((SELECT MAX(rubr_id) + 1 FROM Rubro), 'RUBRO REASIGNADO')
					END
				END
			END
			FETCH NEXT FROM cRubros INTO @rubro, @producto
		END
		CLOSE cRubros
		DEALLOCATE cRubros
	END
END

BEGIN TRANSACTION
EXEC ej22
ROLLBACK

SELECT * FROM Rubro
SELECT * FROM Producto
SELECT COUNT(prod_codigo), prod_rubro FROM Producto GROUP BY prod_rubro HAVING COUNT(prod_codigo) >= 20

