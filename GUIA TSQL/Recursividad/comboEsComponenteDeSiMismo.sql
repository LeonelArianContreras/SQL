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
