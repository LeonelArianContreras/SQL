/*18. Sabiendo que el limite de credito de un cliente es el monto maximo que se le
puede facturar mensualmente, cree el/los objetos de base de datos necesarios
para que dicha regla de negocio se cumpla automaticamente. No se conoce la
forma de acceso a los datos ni el procedimiento por el cual se emiten las facturas*/
GO
CREATE TRIGGER ej18 ON Factura FOR INSERT
AS
BEGIN
	IF EXISTS (SELECT F1.fact_cliente
			   FROM inserted F1
			   JOIN Cliente ON clie_codigo = F1.fact_cliente
			   GROUP BY F1.fact_cliente, YEAR(F1.fact_fecha), MONTH(F1.fact_fecha), clie_limite_credito
			   HAVING SUM(ISNULL(F1.fact_total, 0)) > clie_limite_credito - (SELECT SUM(ISNULL(F2.fact_total, 0))
																			 FROM Factura F2
																			 WHERE F2.fact_cliente = F1.fact_cliente
																				AND YEAR(F2.fact_fecha) = YEAR(F1.fact_fecha)
																				AND MONTH(F2.fact_fecha) = MONTH(F1.fact_fecha)))
	BEGIN
		ROLLBACK
		RAISERROR('El limite del cliente ya ha sido alcanzado!', 16, 1)
	END
END

BEGIN TRANSACTION;

INSERT INTO Factura (fact_tipo, fact_sucursal, fact_numero, fact_fecha, fact_vendedor, fact_total, fact_total_impuestos, fact_cliente)
VALUES ('A', '0001', 'F0000002', GETDATE(), 1, 2000, 0, '00656');  -- Esto, sumado a 9000, excede el límite

SELECT * FROM Factura WHERE fact_cliente = '000001';

ROLLBACK;

SELECT * FROM Factura WHERE fact_cliente = '00656'
SELECT clie_limite_credito FROM Cliente WHERE clie_codigo = '00656'
