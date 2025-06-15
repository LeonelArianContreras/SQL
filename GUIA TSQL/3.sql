/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.*/

CREATE PROCEDURE ej3 @cant_gerenteGral INT OUTPUT
AS
BEGIN
	DECLARE @jefe NUMERIC

	SELECT @cant_gerenteGral = COUNT(DISTINCT empl_codigo)
	FROM Empleado
	WHERE empl_jefe IS NULL

	SET @jefe = (SELECT TOP 1 empl_codigo
				 FROM Empleado
				 WHERE empl_jefe IS NULL
				 GROUP BY empl_codigo
				 ORDER BY SUM(ISNULL(empl_salario, 0)) DESC)
	
	IF(@cant_gerenteGral > 1) 
		UPDATE Empleado
		SET empl_jefe = @jefe
		WHERE empl_codigo <> @jefe AND empl_jefe IS NULL

END
GO

BEGIN
DECLARE @cantidad INT
EXEC dbo.ej3 @cantidad OUTPUT
PRINT @cantidad 
END
GO

