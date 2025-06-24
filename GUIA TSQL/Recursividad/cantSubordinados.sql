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