CREATE FUNCTION suma_salarios_subordinados(@jefe VARCHAR(10)) 
RETURNS DECIMAL(12,2)
AS
BEGIN
	DECLARE @suma_salarios DECIMAL(12,2),
			@emple VARCHAR(10),
			@salario DECIMAL(12,2)

	IF @jefe NOT IN (SELECT empl_jefe FROM Empleado)
		SET @suma_salarios = 0

	BEGIN
		DECLARE cSalario CURSOR FOR SELECT empl_codigo, empl_salario
								    FROM Empleado
									WHERE empl_jefe = @jefe
		OPEN cSalario
		FETCH NEXT FROM cSalario INTO @emple, @salario
		SET @suma_salarios = 0

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @suma_salarios = @suma_salarios + @salario + dbo.suma_salarios_subordinados(@emple)
			FETCH NEXT FROM cSalario INTO @emple, @salario
		END

		CLOSE cSalario
		DEALLOCATE cSalario
	END

	RETURN @suma_salarios
END