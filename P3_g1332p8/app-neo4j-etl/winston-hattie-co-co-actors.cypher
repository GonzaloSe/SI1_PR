// Encontrar actores que no han trabajado con "Winston, Hattie"
MATCH (actor:Actor)
WHERE actor.name <> "Winston, Hattie"

// Encontrar actores que han trabajado con un tercer actor en común
MATCH (actor:Actor)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(coActor:Actor),
      (coActor:Actor)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(thirdActor:Actor)

// Filtrar actores que no han trabajado con "Winston, Hattie" y no son "Winston, Hattie" ni el tercer actor
WHERE NOT (actor:Actor)-[:ACTED_IN]->(:Movie)<-[:ACTED_IN]-(:Actor {name: "Winston, Hattie"})
  AND actor.name <> "Winston, Hattie"
  AND actor.name <> thirdActor.name

// Devolver los resultados ordenados alfabéticamente y limitar a 10 resultados
RETURN actor.name AS actorName
ORDER BY actorName
LIMIT 10;
