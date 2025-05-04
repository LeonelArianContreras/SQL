/*8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
artículo, stock del depósito que más stock tiene.*/

SELECT prod_detalle, MAX(stoc_cantidad) 
FROM Producto JOIN Stock ON prod_codigo = stoc_producto -- Cambia la atomicidad
GROUP BY prod_detalle
HAVING COUNT(DISTINCT stoc_producto) = (SELECT COUNT(*) FROM Deposito)
