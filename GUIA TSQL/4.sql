/*4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año.*/

ALTER PROCEDURE ej4 @vendedor_estrella NUMERIC(6) OUTPUT
AS
BEGIN
	SET @vendedor_estrella = (SELECT TOP 1 fact_vendedor
							  FROM Factura
							  GROUP BY fact_vendedor
							  ORDER BY SUM(ISNULL(fact_total, 0)) DESC)
	
	UPDATE Empleado
	SET empl_comision = (SELECT ISNULL(SUM(F1.fact_total), 0)
						 FROM Factura F1
						 WHERE empl_codigo = F1.fact_vendedor AND YEAR(F1.fact_fecha) = (select max(year(fact_fecha)) from factura))
	RETURN
END
GO

SELECT * FROM Empleado

SELECT SUM(fact_total), fact_vendedor
FROM Factura
GROUP BY fact_vendedor
ORDER BY SUM(fact_total) DESC

UPDATE Empleado SET empl_comision = 0

BEGIN
DECLARE @vendedor NUMERIC(6)
EXEC dbo.ej4 @vendedor OUTPUT
SELECT @vendedor
END