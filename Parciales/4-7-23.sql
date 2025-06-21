--- SQL ---
SELECT zona_detalle,
	  (SELECT COUNT(depo_codigo)
	   FROM DEPOSITO
	   WHERE depo_zona = Z1.zona_codigo) AS depo_x_zona,

	  (SELECT COUNT(DISTINCT comp_producto)
	   FROM Composicion
	   JOIN STOCK ON comp_producto = stoc_producto
	   WHERE stoc_deposito = D1.depo_codigo) as cant_combos,

	  (SELECT TOP 1 item_producto
	   FROM Item_Factura
	   JOIN Factura ON item_numero = fact_numero AND item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND YEAR(fact_fecha) = 2012
	   JOIN STOCK ON item_producto = stoc_producto AND stoc_cantidad > 0
	   JOIN DEPOSITO ON stoc_deposito = depo_codigo AND depo_zona = Z1.zona_codigo
	   GROUP BY item_producto
	   ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC) AS producto_estrella,

	  (SELECT TOP 1 fact_vendedor
	   FROM DEPOSITO
	   JOIN Factura ON fact_vendedor = depo_encargado
	   WHERE depo_zona = Z1.zona_codigo
	   GROUP BY fact_vendedor
	   ORDER BY COUNT(fact_vendedor) DESC) AS encargado_estrella
FROM Zona Z1
LEFT JOIN DEPOSITO D1 ON Z1.zona_codigo = D1.depo_zona --> No cambia atomicidad
GROUP BY Z1.zona_detalle, Z1.zona_codigo, D1.depo_encargado, D1.depo_codigo
HAVING (SELECT COUNT(depo_codigo)
	   FROM DEPOSITO
	   WHERE depo_zona = Z1.zona_codigo) >= 3
ORDER BY (SELECT SUM(ISNULL(fact_total, 0))
		  FROM Factura
		  WHERE fact_vendedor = D1.depo_encargado) DESC


--- TSQL ---
GO
CREATE TRIGGER vendedorRefEmpleado ON Factura FOR INSERT
AS
BEGIN
	DECLARE @vendedor CHAR(1)

	IF EXISTS (SELECT 1 FROM inserted WHERE fact_vendedor NOT IN (SELECT empl_codigo FROM Empleado))
	BEGIN
		DECLARE cVendedor CURSOR FOR SELECT fact_vendedor
									 FROM inserted
		OPEN cVendedor
		FETCH NEXT FROM cVendedor INTO @vendedor
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @vendedor NOT IN (SELECT empl_codigo FROM Empleado)
			BEGIN
				DELETE FROM Factura
				WHERE fact_vendedor = @vendedor
			END
			FETCH NEXT FROM cVendedor INTO @vendedor
		END
		CLOSE cVendedor
		DEALLOCATE cVendedor
	END
END
