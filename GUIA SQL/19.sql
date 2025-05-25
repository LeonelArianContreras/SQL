/*19. En virtud de una recategorizacion de productos referida a la familia de los mismos se
solicita que desarrolle una consulta sql que retorne para todos los productos:
 Codigo de producto
 Detalle del producto
 Codigo de la familia del producto
 Detalle de la familia actual del producto
 Codigo de la familia sugerido para el producto
 Detalla de la familia sugerido para el producto

La familia sugerida para un producto es aquella la cual los productos cuyo
detalle coinciden en los primeros 5 caracteres.

En caso que 2 o mas familias pudieran ser sugeridas se debera seleccionar la de menor
codigo. Solo se deben mostrar los productos para los cuales la familia actual sea
diferente a la sugerida

Los resultados deben ser ordenados por detalle de producto de manera ascendente*/

SELECT P1.prod_codigo, P1.prod_detalle, F1.fami_id, F1.fami_detalle, 

	(SELECT TOP 1 F2.fami_id
	 FROM Familia F2 JOIN Producto P2 ON P2.prod_familia = F2.fami_id 
	 WHERE LEFT(P1.prod_detalle, 5) = LEFT(P2.prod_detalle, 5)
	 GROUP BY F2.fami_id
	 ORDER BY F2.fami_id ASC) AS fami_id_sugerida,
	
	(SELECT TOP 1 F3.fami_detalle
	 FROM Familia F3 JOIN Producto P2 ON P2.prod_familia = F3.fami_id 
	 WHERE LEFT(P1.prod_detalle, 5) = LEFT(P2.prod_detalle, 5)
	 GROUP BY F3.fami_detalle, F3.fami_id
	 ORDER BY F3.fami_id ASC) AS fami_detalle_sugerida

FROM Producto P1 JOIN Familia F1 ON F1.fami_id = P1.prod_familia
GROUP BY P1.prod_codigo, P1.prod_detalle, F1.fami_id, F1.fami_detalle
HAVING F1.fami_id <> (SELECT TOP 1 F2.fami_id
				      FROM Familia F2 JOIN Producto P2 ON P2.prod_familia = F2.fami_id 
					  WHERE LEFT(P1.prod_detalle, 5) = LEFT(P2.prod_detalle, 5)
					  GROUP BY F2.fami_id
					  ORDER BY F2.fami_id ASC)
ORDER BY prod_detalle ASC
