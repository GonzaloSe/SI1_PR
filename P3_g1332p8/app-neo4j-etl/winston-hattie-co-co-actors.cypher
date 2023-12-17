// Encontrar actores que no han trabajado con "Winston, Hattie"
MATCH (actor:Actor)
WHERE actor.name <> "Winston, Hattie"

// Encontrar actores que han trabajado con un tercer actor en común
MATCH (actor)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(coActor),
      (coActor)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(thirdActor)

// Filtrar actores que no han trabajado con "Winston, Hattie"
AND NOT (actor)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(:Actor {name: "Winston, Hattie"})

// Filtrar actores que no son "Winston, Hattie" ni el tercer actor
AND actor <> "Winston, Hattie" AND actor <> thirdActor

// Devolver los resultados ordenados alfabéticamente y limitar a 10 resultados
RETURN actor.name AS actorName
ORDER BY actorName
LIMIT 10;
