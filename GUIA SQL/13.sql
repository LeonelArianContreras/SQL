/*13. Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.*/

SELECT prod_codigo, prod_detalle, (SELECT SUM(isnull(prod_precio, 0)) * comp_cantidad
								   FROM Producto
								   WHERE comp_componente = prod_codigo)
FROM Producto JOIN Composicion ON prod_codigo = comp_producto
WHERE comp_cantidad > 2
ORDER BY comp_cantidad DESC