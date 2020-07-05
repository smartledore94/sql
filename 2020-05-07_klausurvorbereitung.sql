DROP TABLE IF EXISTS angestellte CASCADE;
DROP TABLE IF EXISTS vertriebsmitarbeiter CASCADE;
DROP TABLE IF EXISTS techniker CASCADE;

-- Tabellen anlegen
CREATE TABLE angestellte (
	nachname VARCHAR(30),
	vorname VARCHAR(30),
	geburtsdatum TIMESTAMP,
	pnr VARCHAR(20) PRIMARY KEY) WITH OIDS;

CREATE TABLE vertriebsmitarbeiter (
	vertriebsbereiche VARCHAR(50),
	jahresumsatz FLOAT) INHERITS (angestellte) with OIDS;
	
CREATE TABLE techniker (
	qualifikationen VARCHAR(50) INHERITS (angestellte) with OIDS);

-- Beispieldatensätze hinzufügen
INSERT INTO vertriebsmitarbeiter (nachname, vorname, geburtsdatum, pnr, vertriebsbereiche, jahresumsatz) VALUES
	('Krause', 'Maria', 1994-06-16, '100000', 'Software, Lizenzen', 10000.22),
	('Sascha', 'Richter', 1992-02-24, '100001', 'Hardware', 15000.33);
	
INSERT INTO techniker (nachname, vorname, geburtsdatum, pnr, qualifikationen) VALUES
	('Krause', 'Benjamin', 1994-06-16, '100000', 'M.Sc. Elektrotechnik');

-- View (Abfrage bei MS Access) anlegen
CREATE VIEW vertriebsmitarbeiterView AS
	SELECT nachname, vorname, jahresumsatz FROM vertriebsmitarbeiter;

-- Tabelle für Triggerfunktion erweitern
ALTER TABLE techniker ADD datum TIMESTAMP;
ALTER TABLE techniker ADD benutzer VARCHAR(30); 

-- Triggerfunktion definieren
CREATE OR REPLACE FUNCTION datum_geaendert() 
	RETURNS TRIGGER AS
		$$
		BEGIN
			NEW.datum := NOW();
			NEW.benutzer := CURRENT_USER;
			RETURN NEW;
		END
	$$ LANGUAGE plpgsql;

-- Trigger anlegen
CREATE TRIGGER datum_geaendert
	BEFORE INSERT OR UPDATE ON techniker;
	FOR EACH ROW EXECUTE PROCEDURE datum_geaendert();
	
-- Beispiel aus Uebung 2, Buchausleihe
CREATE OR REPLACE FUNCTION buch_ausleihe(VARCHAR)
	RETURNS TRIGGER AS
		$$
		DECLARE
			ausleiher ALIAS FOR $1;
		BEGIN
			NEW.ausleihdatum := NOW();
			NEW.bearbeiter := CURRENT_USER;
			NEW.ausgeliehenVon := ausleiher;
			RETURN NEW;
		END
	$$ LANGUAGE plpgsql;

CREATE TRIGGER buch_ausleihe
	BEFORE INSERT OR UPDATE ON [buchtabelle]
	FOR EACH ROW EXECUTE PROCEDURE buch_ausleihe();