--- SQL ---
SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS nro_fila,
	   C.clie_codigo,
	   C.clie_razon_social,

	  (SELECT COUNT(DISTINCT item_producto)
	   FROM Item_Factura
	   JOIN Factura ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = item_numero
	   WHERE fact_cliente = C.clie_codigo) AS cant_productos_distintos,
	   
	   SUM(ISNULL(fact_total, 0)) AS total_facturado

FROM Cliente C
JOIN Factura F ON C.clie_codigo = F.fact_cliente
GROUP BY C.clie_codigo, C.clie_razon_social
HAVING DATEADD(MONTH, 5, MIN(F.fact_fecha)) < (SELECT TOP 1 fact_fecha
											  FROM Factura
											  WHERE fact_cliente = C.clie_codigo AND fact_fecha <> MIN(F.fact_fecha)
											  ORDER BY fact_fecha ASC)
ORDER BY (SELECT SUM(ISNULL(item_cantidad, 0))
		  FROM Item_Factura
		  JOIN Factura ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = item_numero
		  WHERE fact_cliente = C.clie_codigo) DESC


--- TSQL ---
GO
CREATE PROCEDURE correccionCombos
AS
BEGIN
	DECLARE @componente CHAR(8),
		    @cantidad INT,
			@nroFactura CHAR(8),
			@tipoFactura CHAR(1),
			@nroSucursal CHAR(4),
			@precio DECIMAL(12,2)
	BEGIN
		DECLARE cCombo CURSOR FOR SELECT comp_componente, 
										 comp_cantidad, 
										 item_numero, 
										 item_sucursal, 
										 item_tipo,
										 item_precio
								  FROM Composicion
								  JOIN Item_Factura ON item_producto = comp_producto
		OPEN cCombo
		FETCH NEXT FROM cCombo INTO @componente, @cantidad, @nroFactura, @nroSucursal, @tipoFactura, @precio
		WHILE @@FETCH_STATUS = 0
		BEGIN
			INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
			VALUES (@tipoFactura, @nroSucursal, @nroFactura, @componente, @cantidad, @precio)

			IF NOT EXISTS (SELECT 1
						   FROM Item_Factura 
						   WHERE item_numero = @nroFactura AND item_sucursal = @nroSucursal AND item_tipo = @tipoFactura
								AND item_producto IN (SELECT comp_producto FROM Composicion))
			BEGIN
				DELETE FROM Item_Factura
				WHERE item_numero = @nroFactura AND item_sucursal = @nroSucursal AND item_tipo = @tipoFactura 
			END

			FETCH NEXT FROM cCombo INTO @componente, @cantidad, @nroFactura, @nroSucursal, @tipoFactura, @precio
		END 
		CLOSE cCombo
		DEALLOCATE cCombo
	END
END

GO
CREATE TRIGGER consistenciaCombos ON Item_Factura AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT 1
			   FROM inserted
			   WHERE item_producto IN (SELECT comp_producto FROM Composicion))
	BEGIN
		ROLLBACK
		RAISERROR('No pueden facturarse combos!', 16, 1)
	END
END