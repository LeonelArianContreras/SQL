--- SQL ---
SELECT ROW_NUMBER() OVER (ORDER BY MAX(ISNULL(item_cantidad, 0))) AS posicion,
	   F.fact_cliente,
	  (SELECT TOP 1 item_producto
	   FROM Item_Factura
	   JOIN Factura ON fact_tipo = item_tipo 
			AND fact_sucursal = item_sucursal
			AND fact_numero = item_numero
	   WHERE fact_cliente = F.fact_cliente
	   GROUP BY item_producto
	   ORDER BY SUM(ISNULL(item_cantidad, 0)) DESC) AS producto_estrella,
	  (SELECT SUM(ISNULL(item_cantidad, 0))
	   FROM Factura
	   JOIN Item_Factura ON fact_tipo = item_tipo 
			AND fact_sucursal = item_sucursal
			AND fact_numero = item_numero
	   WHERE YEAR(fact_fecha) = 2012) AS producto_estrella_reciente --> Deberia ser MAX(YEAR) pero como es vieja la db...
FROM Factura F
JOIN Item_Factura ON F.fact_tipo = item_tipo 
			AND F.fact_sucursal = item_sucursal
			AND F.fact_numero = item_numero
WHERE F.fact_cliente IN (SELECT fact_cliente
						 FROM Factura
						 WHERE YEAR(fact_fecha) % 2 = 0)
GROUP BY F.fact_cliente
ORDER BY MAX(ISNULL(item_cantidad, 0)) DESC



--- TSQL ---
GO
CREATE TRIGGER auditoriaCliente ON Cliente FOR INSERT, DELETE
AS
BEGIN
	IF (SELECT COUNT(*) FROM inserted) > 1
	BEGIN
		ROLLBACK
		RAISERROR('No se puede modificar masivamente al cliente!', 16, 1)
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM deleted)
		BEGIN
			INSERT INTO modificacionesClientes (
				clie_codigo,
				clie_razon_social,
				clie_telefono,
				clie_domicilio,
				clie_limite_credito,
				clie_vendedor,
				tipo_operacion,
				fecha_ejecucion
			)
			SELECT clie_codigo, 
				   clie_razon_social,
				   clie_telefono,
				   clie_domicilio,
				   clie_limite_credito,
				   clie_vendedor,
				   'DELETE',
				   GETDATE()
				   FROM deleted
		END

		IF EXISTS (SELECT 1 FROM inserted)
		BEGIN
			INSERT INTO modificacionesClientes (
				clie_codigo,
				clie_razon_social,
				clie_telefono,
				clie_domicilio,
				clie_limite_credito,
				clie_vendedor,
				tipo_operacion,
				fecha_ejecucion
			)
			SELECT clie_codigo, 
				   clie_razon_social,
				   clie_telefono,
				   clie_domicilio,
				   clie_limite_credito,
				   clie_vendedor,
				   'INSERT',
				   GETDATE()
				   FROM inserted
		END

	END
END

CREATE TABLE modificacionesCliente ( -- Supongo que no cambia el codigo
	clie_codigo CHAR(5),
	clie_razon_social VARCHAR(50),
	clie_telefono VARCHAR(20),
	clie_domicilio VARCHAR(50),
	clie_limite_credito DECIMAL(12,2),
	clie_vendedor CHAR(1),
	tipo_operacion VARCHAR(20),
	fecha_ejecucion DATETIME
)