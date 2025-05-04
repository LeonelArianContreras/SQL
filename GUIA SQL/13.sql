/*13. Realizar una consulta que retorne para cada producto que posea composición nombre
del producto, precio del producto, precio de la sumatoria de los precios por la cantidad
de los productos que lo componen. Solo se deberán mostrar los productos que estén
compuestos por más de 2 productos y deben ser ordenados de mayor a menor por
cantidad de productos que lo componen.*/

SELECT Combo.prod_codigo, Combo.prod_detalle, Combo.prod_precio, SUM(isnull(Comp.prod_precio * comp_cantidad, 0)) 
FROM Producto Combo JOIN Composicion ON Combo.prod_codigo = comp_producto
JOIN Producto Comp ON Comp.prod_codigo = comp_componente
GROUP BY Combo.prod_codigo, Combo.prod_detalle, Combo.prod_precio
HAVING COUNT(comp_componente) > 2
ORDER BY COUNT(comp_componente) DESC