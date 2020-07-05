DROP TABLE IF EXISTS versuch CASCADE;

CREATE TABLE versuch(
	vnr VARCHAR(5) PRIMARY KEY,
	vname VARCHAR(30),
	datum TIMESTAMP,
	benutzer VARCHAR(30));

CREATE OR REPLACE FUNCTION versuch_datum_geaendert()
	RETURNS TRIGGER AS
	$$
		BEGIN
			IF NEW.vnr IS NULL THEN
				RAISE EXCEPTION 'Feld vnr nicht ausgefüllt!';
				END IF;
			IF NEW.vname IS NULL THEN
				RAISE EXCEPTION 'Feld vname nicht ausgefüllt!';
				END IF;
			NEW.datum := NOW();
			NEW.benutzer := CURRENT_USER;
			RETURN NEW;
		END
	$$ LANGUAGE plpgsql;

-- Trigger sollte denselben Namen haben wie Funktion
CREATE TRIGGER versuch_datum_geaendert
	BEFORE INSERT OR UPDATE ON versuch
	FOR EACH ROW EXECUTE PROCEDURE versuch_datum_geaendert();

