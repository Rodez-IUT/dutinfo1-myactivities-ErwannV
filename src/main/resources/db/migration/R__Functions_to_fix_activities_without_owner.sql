CREATE OR REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$
    DECLARE
        defaultOwner "user"%rowtype;
        defaultOwnerUsername varchar(500) := 'Default Owner';
        
    BEGIN
    
        SELECT * INTO defaultOwner from "user"
            WHERE username = defaultOwnerUsername;
            
        IF NOT FOUND THEN
            INSERT INTO "user" (id, username)
                VALUES(nextval('id_generator'), defaultOwnerUsername);
            SELECT * INTO defaultOwner from "user"
                WHERE username = defaultOwnerUsername;
                
        END IF;
        RETURN defaultOwner;
        
    END
    
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fix_activities_without_owner() RETURNS SETOF activity AS $$
    DECLARE
        defaultOwner"user"%rowtype;
        nowDate date=now();
    
    BEGIN
        defaultOwner := get_default_owner();
		return query
		    update activity
		    SET owner_id = defaultOwner.id,
		        modification_date = nowDate
		    where owner_id is null 
		    returning *;
    
    END
--1 Chercher les activités sans "Owner";            
--2 Attribuer à ses activités le "Default owner";    
--3 Retourner les activités modifiées

$$ LANGUAGE plpgsql;