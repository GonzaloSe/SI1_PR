// Encontrar pares de personas que han trabajado juntas en más de una película
MATCH (person1)-[:ACTED_IN|DIRECTED]->(movie)<-[:ACTED_IN|DIRECTED]-(person2)

// Filtrar pares de personas distintas
WHERE id(person1) < id(person2)

// Contar el número de películas en las que han trabajado juntas
WITH person1, person2, count(movie) AS collaborations

// Filtrar pares con más de una colaboración
WHERE collaborations > 1

// Devolver los resultados
RETURN person1.name AS person1Name, person2.name AS person2Name, collaborations
ORDER BY collaborations DESC;

