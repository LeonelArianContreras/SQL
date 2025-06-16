/*15. Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. No se
conocen los nivles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
select.*/
GO
CREATE FUNCTION sumar_componentes(@articulo VARCHAR(10))
RETURNS DECIMAL(12,2)
AS
BEGIN
	DECLARE @suma DECIMAL(12,2)
	SET @suma = (SELECT SUM(comp_cantidad * C1.prod_precio)
				 FROM Composicion
				 JOIN Producto C1 ON C1.prod_codigo = comp_componente
				 WHERE comp_producto = @articulo)
	RETURN @suma
END


GO
CREATE FUNCTION EJ15bis(@articulo VARCHAR(10))
RETURNS DECIMAL(12,2)
AS
BEGIN
	DECLARE @precio_total DECIMAL(12,2)

	IF (SELECT COUNT(DISTINCT comp_componente)
		FROM Composicion 
		WHERE comp_producto = @articulo) > 0
		SET @precio_total = dbo.sumar_componentes(@articulo)

	ELSE
		SET @precio_total = (SELECT prod_precio FROM Producto WHERE prod_codigo = @articulo)
	
	RETURN @precio_total
END


-- Forma correcta (?
GO
CREATE FUNCTION ej15(@producto VARCHAR(10))
RETURNS DECIMAL(12,2)
AS
BEGIN
	DECLARE @suma_precios DECIMAL(12,2) = 0,
			@componente VARCHAR(10),
			@cant INT

	IF @producto NOT IN (SELECT comp_producto FROM Composicion)
		SET @suma_precios = (SELECT prod_precio FROM Producto WHERE prod_codigo = @producto)

	BEGIN
		DECLARE cCompo CURSOR FOR SELECT comp_componente, comp_cantidad
								  FROM Composicion
								  WHERE comp_producto = @producto
		OPEN cCompo
		FETCH NEXT FROM cCompo INTO @componente, @cant

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @suma_precios = @suma_precios + @cant * dbo.ej15(@componente)
			FETCH NEXT FROM cCompo INTO @componente, @cant
		END

		CLOSE cCompo
		DEALLOCATE cCompo
	END
	RETURN @suma_precios
END