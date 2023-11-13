CREATE OR REPLACE FUNCTION getTopActors(Genre_given CHAR, OUT Actor VARCHAR, OUT Num INT, OUT Debut INT, OUT Film VARCHAR, OUT Director VARCHAR)
RETURNS SETOF RECORD AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        WITH gen_actor_stats AS (
            SELECT 
                am.actorid, 
                a.actorname, 
                COUNT(*) AS num_movies,
                MIN(m.year) AS debut_year
            FROM imdb_actormovies am
            JOIN imdb_movies m ON am.movieid = m.movieid 
            JOIN imdb_actors a ON am.actorid = a.actorid
            JOIN imdb_moviegenres mg ON m.movieid = mg.movieid
            WHERE mg.genre = Genre_given
            GROUP BY am.actorid, a.actorname
        ),
        filtered_actors AS (
            SELECT 
                ga.actorid, 
                ga.actorname, 
                ga.num_movies, 
                ga.debut_year,
                STRING_AGG(CASE WHEN m.year = ga.debut_year THEN m.movietitle END, ', ') AS movie_titles,
                STRING_AGG(CASE WHEN m.year = ga.debut_year THEN d.directorname END, ', ') AS director_names
            FROM gen_actor_stats ga
            JOIN imdb_actormovies am ON ga.actorid = am.actorid
            JOIN imdb_movies m ON am.movieid = m.movieid 
            JOIN imdb_directormovies md ON m.movieid = md.movieid
            JOIN imdb_directors d ON md.directorid = d.directorid
            WHERE ga.num_movies > 4
            GROUP BY ga.actorid, ga.actorname, ga.num_movies, ga.debut_year
        )
        SELECT * FROM filtered_actors
        ORDER BY num_movies DESC;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        EXIT WHEN NOT FOUND;
        
        Actor := rec.actorname;
        Num := rec.num_movies;
        Debut := rec.debut_year;
        Film := rec.movie_titles;
        Director := rec.director_names;
        
        RETURN NEXT;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM getTopActors('Comedy');

--DROP FUNCTION IF EXISTS getTopActors(character);








