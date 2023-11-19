--Función para cambios en la valoración
CREATE OR REPLACE FUNCTION updRatingsFunction()
RETURNS TRIGGER AS $$
DECLARE
    mean_value numeric(3,2);
    count_value integer;
BEGIN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        SELECT COUNT(rating_id) INTO count_value FROM ratings
        WHERE movie_id = NEW.movie_id;
        SELECT AVG(rating) INTO mean_value FROM ratings
        WHERE movie_id = NEW.movie_id;
        
        UPDATE imdb_movies
        SET ratingmean = mean_value, ratingcount = count_value
        WHERE movieid = NEW.movie_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN 
        SELECT COUNT(rating_id) INTO count_value FROM ratings
        WHERE movie_id = OLD.movie_id;
        SELECT AVG(rating) INTO mean_value FROM ratings
        WHERE movie_id = OLD.movie_id;
        
        UPDATE imdb_movies
        SET ratingmean = mean_value, ratingcount = count_value
        WHERE movieid = OLD.movie_id;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;
							   
--Trigger para cambios en la valoración							   
CREATE OR REPLACE TRIGGER updRatings
AFTER INSERT OR DELETE OR UPDATE ON ratings
FOR EACH ROW
EXECUTE FUNCTION updRatingsFunction();


--DROP FUNCTION updRatingsFunction;
--DROP TRIGGER updRatings ON ratings;