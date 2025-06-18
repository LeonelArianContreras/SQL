/*19. Cree el/los objetos de base de datos necesarios para que se cumpla la siguiente
regla de negocio automáticamente “Ningún jefe puede tener menos de 5 años de
antigüedad y tampoco puede tener más del 50% del personal a su cargo
(contando directos e indirectos) a excepción del gerente general”. Se sabe que en
la actualidad la regla se cumple y existe un único gerente general.*/
GO
ALTER FUNCTION cantidad_subordinados(@jefe VARCHAR(10))
RETURNS INT
AS
BEGIN
	DECLARE @empleado VARCHAR(10) = 0,
			@cantidad_sub INT

	IF @jefe NOT IN (SELECT empl_jefe FROM Empleado)
		SET @cantidad_sub = 0

	BEGIN
		DECLARE cJefe CURSOR FOR SELECT empl_codigo
							     FROM Empleado
								 WHERE empl_jefe = @jefe
		OPEN cJefe
		FETCH NEXT FROM cJefe INTO @empleado

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @cantidad_sub = @cantidad_sub + 1 + dbo.cantidad_subordinados(@empleado)
			FETCH NEXT FROM cJefe INTO @empleado
		END

		CLOSE cJefe
		DEALLOCATE cJefe
	END
	RETURN @cantidad_sub
END

GO
ALTER TRIGGER ej19 ON Empleado FOR INSERT, UPDATE, DELETE
AS
BEGIN
	IF EXISTS (SELECT 1 
			   FROM inserted E
			   JOIN Empleado J ON J.empl_codigo = E.empl_jefe AND E.empl_jefe IS NOT NULL
			   WHERE DATEDIFF(YEAR, J.empl_ingreso, GETDATE()) < 5
					AND dbo.cantidad_subordinados(J.empl_codigo) > 0.50 * (SELECT COUNT(*) FROM Empleado))																													
	BEGIN
		ROLLBACK
		RAISERROR('Ningún jefe puede tener menos de 5 años de
					antigüedad y tampoco puede tener más del 50% del personal a su cargo
				(contando directos e indirectos) a excepción del gerente general', 16, 1)
	END
END

BEGIN TRANSACTION
	INSERT INTO Empleado (empl_codigo, empl_nombre, empl_apellido, empl_nacimiento, empl_ingreso, empl_tareas, empl_salario, empl_comision, empl_jefe, empl_departamento)
	VALUES (10, 'Leonel', 'Contreras', GETDATE(), GETDATE(), 'Vendedor', 2, 0, 3, 2)

	INSERT INTO Empleado (empl_codigo, empl_nombre, empl_apellido, empl_nacimiento, empl_ingreso, empl_tareas, empl_salario, empl_comision, empl_jefe, empl_departamento)
	VALUES (11, 'Matias', 'Cao', GETDATE(), GETDATE(), 'Vendedor', 2, 0, 3, 2)

ROLLBACK

SELECT * FROM Empleado
