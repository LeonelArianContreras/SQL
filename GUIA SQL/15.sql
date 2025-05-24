/*15. Escriba una consulta que retorne los pares de productos que hayan sido vendidos juntos
(en la misma factura) más de 500 veces. El resultado debe mostrar el código y
descripción de cada uno de los productos y la cantidad de veces que fueron vendidos
juntos. El resultado debe estar ordenado por la cantidad de veces que se vendieron
juntos dichos productos. Los distintos pares no deben retornarse más de una vez.
Ejemplo de lo que retornaría la consulta:
PROD1	DETALLE1			PROD2	   DETALLE2			VECES
1731  MARLBORO KS			1718  PHILIPS MORRIS KS		507
1718  PHILIPS MORRIS KS		1705  PHILIPS MORRIS BOX	10562*/

SELECT P1.prod_codigo, P1.prod_detalle, P2.prod_codigo, P2.prod_detalle, COUNT(fact_numero)
FROM Producto P1 JOIN Item_Factura IT1 ON P1.prod_codigo = IT1.item_producto --> Cambia atomicidad
				 JOIN Factura ON IT1.item_tipo+IT1.item_sucursal+IT1.item_numero = fact_tipo+fact_sucursal+fact_numero --> No cambia atomicidad
				 JOIN Item_Factura IT2 ON IT2.item_tipo+IT2.item_sucursal+IT2.item_numero = fact_tipo+fact_sucursal+fact_numero --> No cambia atomicidad
				 JOIN Producto P2 ON P2.prod_codigo = IT2.item_producto --> No cambia atomicidad
WHERE P2.prod_codigo > P1.prod_codigo
GROUP BY P1.prod_codigo, P1.prod_detalle, P2.prod_codigo, P2.prod_detalle
HAVING COUNT(fact_numero) > 500
ORDER BY 5

/* No cambia atomicidad debido a que todo es union con PKs*/