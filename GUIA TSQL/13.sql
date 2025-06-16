
/*13. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha
regla se cumple y que la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías*/
GO
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


GO
CREATE TRIGGER ej13 ON Empleado FOR INSERT, DELETE
AS
BEGIN
	IF (SELECT COUNT(*) FROM inserted I1 WHERE (SELECT empl_salario FROM Empleado E1 WHERE empl_codigo = I1.empl_jefe) > 
																						0.20 * dbo.suma_salarios_subordinados(I1.empl_jefe)) > 0
	BEGIN
		ROLLBACK
		RAISERROR('Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
				  sus empleados totales (directos + indirectos)')
	END

	IF (SELECT COUNT(*) FROM deleted I1 WHERE (SELECT empl_salario FROM Empleado E1 WHERE empl_codigo = I1.empl_jefe) > 
																						0.20 * dbo.suma_salarios_subordinados(I1.empl_jefe)) > 0 
	BEGIN
		ROLLBACK
		RAISERROR('Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
				  sus empleados totales (directos + indirectos)')
	END
END