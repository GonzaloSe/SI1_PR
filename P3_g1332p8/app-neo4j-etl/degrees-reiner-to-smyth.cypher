// Encontrar el nodo del director "Reiner, Carl"
MATCH (director:Director {name: "Reiner, Carl"})

// Encontrar el nodo de la actriz "Smyth, Lisa (I)"
MATCH (actress:Actor {name: "Smyth, Lisa (I)"})

// Encontrar el camino mínimo entre el director y la actriz
MATCH path = shortestPath((director)-[*]-(actress))

// Devolver el camino mínimo y la longitud del camino
RETURN path, length(path) AS degrees;

