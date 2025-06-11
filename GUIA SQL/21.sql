/*21. Escriba una consulta sql que retorne para todos los años, en los cuales se haya hecho al
menos una factura, la cantidad de clientes a los que se les facturo de manera incorrecta
al menos una factura y que cantidad de facturas se realizaron de manera incorrecta. Se
considera que una factura es incorrecta cuando la diferencia entre el total de la factura
menos el total de impuesto tiene una diferencia mayor a $ 1 respecto a la sumatoria de
los costos de cada uno de los items de dicha factura. Las columnas que se deben mostrar
son:
? Año
? Clientes a los que se les facturo mal en ese año
? Facturas mal realizadas en ese año*/
-- Fact total impuestos - fact total sin impuestos - sumatoria de costos de items de la misma factura > 1
SELECT YEAR(F1.fact_fecha),
	   COUNT(DISTINCT F1.fact_cliente),
	   COUNT(F1.fact_tipo+F1.fact_numero+F1.fact_sucursal)
FROM Factura F1
WHERE 1 < ABS(ABS(ISNULL(F1.fact_total_impuestos, 0) - ISNULL(F1.fact_total, 0))
	  - (SELECT SUM(ISNULL(IT1.item_cantidad, 0) * ISNULL(IT1.item_precio, 0))
		 FROM Item_Factura IT1
		 WHERE F1.fact_tipo = IT1.item_tipo AND F1.fact_numero = IT1.item_numero AND F1.fact_sucursal = IT1.item_sucursal --> Muchisimo mas eficiente la comparacion de este modo
		 ))
GROUP BY YEAR(F1.fact_fecha)
