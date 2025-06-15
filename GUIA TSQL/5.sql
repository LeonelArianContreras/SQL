/*5. Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
Create table Fact_table
( anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2)
)
Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)*/

CREATE TABLE Fact_table (
    anio CHAR(4) NOT NULL,
    mes CHAR(2) NOT NULL,
    familia CHAR(3) NOT NULL,
    rubro CHAR(4) NOT NULL,
    zona CHAR(3) NOT NULL,
    cliente CHAR(6) NOT NULL,
    producto CHAR(8) NOT NULL,
    cantidad DECIMAL(12,2),
    monto DECIMAL(12,2)
)
GO

ALTER TABLE Fact_table ADD CONSTRAINT PK_Fact_table PRIMARY KEY (anio, mes, familia, rubro, zona, cliente, producto)
GO

ALTER PROCEDURE ej5 
AS
BEGIN
	INSERT INTO Fact_table (
		anio,
		mes,
		familia,
		rubro,
		zona,
		cliente,
		producto,
		cantidad,
		monto 
	)

	SELECT YEAR(fact_fecha),
		   MONTH(fact_fecha),
		   prod_familia,
		   prod_rubro,
		   depa_zona,
		   fact_cliente,
		   prod_codigo,
		   ISNULL(SUM(item_cantidad), 0),
		   ISNULL(SUM(item_cantidad * item_precio), 0)

	FROM Factura 
	JOIN Item_Factura ON fact_tipo+fact_numero+fact_sucursal = item_tipo+item_numero+item_sucursal
	JOIN Empleado ON fact_vendedor = empl_codigo
	JOIN Departamento ON depa_codigo = empl_departamento
	JOIN Producto ON item_producto = prod_codigo
	GROUP BY YEAR(fact_fecha), MONTH(fact_fecha), prod_familia, prod_rubro, depa_zona, fact_cliente, prod_codigo
	RETURN
END
GO

EXEC dbo.ej5
GO