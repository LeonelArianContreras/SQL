/*24. Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resuelva, teniendo en
cuenta que un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, si
esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.*/
GO
CREATE OR ALTER PROCEDURE ej24
AS
BEGIN
	DECLARE @deposito CHAR(2),
			@zonaDepto CHAR(3)

	BEGIN
		DECLARE cEmple CURSOR FOR SELECT depo_codigo, depa_zona
								  FROM Departamento
								  JOIN Empleado ON empl_departamento = depa_codigo
								  JOIN DEPOSITO ON empl_codigo = depo_encargado
								  WHERE depa_zona <> depo_zona
		OPEN cEmple
		FETCH NEXT FROM cEmple INTO @deposito, @zonaDepto

		WHILE @@FETCH_STATUS = 0
		BEGIN	
			UPDATE DEPOSITO
			SET depo_encargado = (SELECT TOP 1 empl_codigo
								  FROM Empleado
								  JOIN DEPOSITO ON depo_encargado = empl_codigo
								  JOIN Departamento ON depa_codigo = empl_departamento AND depa_zona = @zonaDepto
								  GROUP BY empl_codigo
								  ORDER BY COUNT(depo_codigo) ASC)
			WHERE depo_codigo = @deposito

			FETCH NEXT FROM cEmple INTO @deposito, @zonaDepto
		END
		CLOSE cEmple
		DEALLOCATE cEmple
	END
END

BEGIN TRANSACTION
EXEC ej24
ROLLBACK


SELECT empl_codigo, depo_codigo
FROM Departamento
JOIN Empleado ON empl_departamento = depa_codigo
JOIN DEPOSITO ON empl_codigo = depo_encargado
WHERE depa_zona <> depo_zona
