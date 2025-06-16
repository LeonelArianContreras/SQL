/*11. Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo.*/
GO
CREATE FUNCTION cant_subordinados(@empleado VARCHAR(10))
RETURNS INT
AS
BEGIN
	DECLARE @cant_empleados INT,
			@subordinado VARCHAR(10)

	IF @empleado NOT IN (SELECT empl_jefe FROM Empleado)
		SET @cant_empleados = 0

	BEGIN
		DECLARE cSubordinados CURSOR FOR SELECT empl_codigo
									     FROM Empleado 
										 WHERE empl_jefe = @empleado AND empl_codigo > @empleado
		SET @cant_empleados = 0
		OPEN cSubordinados
		FETCH NEXT FROM cSubordinados INTO @subordinado

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @cant_empleados = @cant_empleados + 1 + DBO.cant_subordinados(@subordinado)

			FETCH NEXT FROM cSubordinados INTO @subordinado			
		END
		CLOSE cSubordinados
		DEALLOCATE cSubordinados
	END
	RETURN @cant_empleados
END

