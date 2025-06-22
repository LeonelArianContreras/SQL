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
	DECLARE @combo CHAR(8),
			@cantCombo INT,
			@cantComponentes INT,
			@componente CHAR(8),
			@nroFactura CHAR(8),
			@tipoFactura CHAR(1),
			@nroSucursal CHAR(4),
			@precioComponente DECIMAL(12,2)
	BEGIN
		DECLARE cCombo CURSOR FOR SELECT comp_producto, 
										 item_cantidad, 
										 item_numero,
										 item_sucursal, 
										 item_tipo								  
								  FROM Composicion
								  JOIN Item_Factura ON item_producto = comp_producto
		OPEN cCombo
		FETCH NEXT FROM cCombo INTO @combo, @cantCombo, @nroFactura, @nroSucursal, @tipoFactura
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE cComp CURSOR FOR SELECT comp_componente, comp_cantidad, prod_precio
									 FROM Composicion
									 JOIN Producto P2 ON P2.prod_codigo = comp_componente
									 WHERE comp_producto = @combo
			OPEN cComp
			FETCH NEXT FROM cComp INTO @componente, @cantComponentes, @precioComponente
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO Item_Factura (item_tipo, item_sucursal, item_numero, item_producto, item_cantidad, item_precio)
				VALUES (@tipoFactura, @nroSucursal, @nroFactura, @componente, @cantCombo * @cantComponentes, @precioComponente)

				FETCH NEXT FROM cComp INTO @componente, @cantComponentes
			END
			CLOSE cComp
			DEALLOCATE cComp
			
			DELETE FROM Item_Factura
			WHERE item_tipo = @tipoFactura AND item_sucursal = @nroSucursal AND item_numero = @nroFactura

		FETCH NEXT FROM cCombo INTO @combo, @cantCombo, @nroFactura, @nroSucursal, @tipoFactura
		END
		CLOSE cCombo
		DEALLOCATE cCombo
	END
END SELECT * FROM Item_Factura

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