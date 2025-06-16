

/*12. Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.*/
GO
CREATE FUNCTION combo_de_combo(@combo VARCHAR(10), @componente VARCHAR(10))
RETURNS INT
AS
BEGIN
	DECLARE @hayMalCombo INT = 0,
			@otroComponente VARCHAR(10)

	IF @combo = @componente
		SET @hayMalCombo = 1

	BEGIN
		DECLARE cCombo CURSOR FOR SELECT comp_componente
								  FROM Composicion
								  WHERE comp_producto = @combo
		OPEN cCombo
		FETCH NEXT FROM cCombo INTO @otroComponente
		WHILE @@FETCH_STATUS = 0 AND @hayMalCombo = 0
		BEGIN
			SET @hayMalCombo = dbo.combo_de_combo(@combo, @otroComponente)
			FETCH NEXT FROM cCombo INTO @otroComponente
		END
		CLOSE cCombo
		DEALLOCATE cCombo
	END
	RETURN @hayMalCombo
END
GO

CREATE TRIGGER ej12 ON Composicion FOR INSERT, UPDATE
AS
BEGIN
	IF (SELECT COUNT(*) FROM inserted WHERE (dbo.combo_de_combo(comp_producto, comp_componente)) = 1) > 0
	BEGIN
		ROLLBACK
		RAISERROR('Un producto no puede ser su propio combo')
	END
END
