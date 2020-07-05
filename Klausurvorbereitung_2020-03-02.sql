-- Skript Klausurvorbereitung: siehe ER-Diagramm Ferienwohnungen
DROP TABLE IF EXISTS personen, ferienwohnungen, adressen, mietet CASCADE;

-- Aufgabe 4b
CREATE TABLE personen(
	vorname VARCHAR(30),
	nachname VARCHAR(50),
	telefon VARCHAR(20),
	id INT PRIMARY KEY) WITH OIDS;

CREATE TABLE vermieter(
	website_url VARCHAR(30),
	vid INT PRIMARY KEY) INHERITS(personen) WITH OIDS;

CREATE TABLE urlauber(
	uid INT PRIMARY KEY) INHERITS(personen) WITH OIDS;

CREATE TABLE hausmeister(
	faehigkeiten VARCHAR(50)[],
	hid INT PRIMARY KEY) INHERITS(personen) WITH OIDS;

CREATE TABLE ferienwohnungen(
	personenzahl INT,
	zimmerzahl INT,
	preis NUMERIC(8,2) CHECK (preis > 0),
	fid INT PRIMARY KEY) WITH OIDS;

CREATE TABLE adressen(
	strasse VARCHAR(50),
	hausnummer VARCHAR(10),
	plz CHAR(5),
	ort VARCHAR(50),
	aid INT PRIMARY KEY) WITH OIDS;

-- Beziehungen
-- bietet_an: 2-stellig 1:n --> ferienwohnungen die Vermieter-ID als Fremdschlüssel hinzufügen
ALTER TABLE ferienwohnungen ADD vid INT;
ALTER TABLE ferienwohnungen ADD CONSTRAINT "vermieter" FOREIGN KEY (vid) 
	REFERENCES vermieter(vid);

-- liegt: 2-stellig 1:n --> ferienwohnungen die Adress-ID als Fremdschlüssel hinzufügen
ALTER TABLE ferienwohnungen ADD aid INT;
ALTER TABLE ferienwohnungen ADD CONSTRAINT "adresse" FOREIGN KEY (aid) 
	REFERENCES adressen(aid);

-- wohnt: 2-stellig 1:n --> personen die Adress-ID als Fremdschlüssel hinzufügen
ALTER TABLE personen ADD aid INT;
ALTER TABLE personen ADD CONSTRAINT "adresse" FOREIGN KEY (aid)
	REFERENCES adressen(aid);

-- mietet: 2-stellig n:m --> keine Ausnahme, bildet in Tabelle ab
CREATE TABLE mietet(
	uid INT,
	fid INT,
	von DATE,
	bis DATE,
	personenzahl INT,
	FOREIGN KEY (uid) REFERENCES urlauber(uid),
	FOREIGN KEY (fid) REFERENCES ferienwohnungen(fid)) WITH OIDS;

-- Aufgabe 4c
-- jeden Tabelleneintrag hinzufügen und danach individuell Adressen mit zugehöriger, im vorherigen Eintrag angegebener AID hinzufügen
INSERT INTO vermieter (vorname, nachname, telefon, id, aid, website_url, vid) VALUES
	('Max', 'Muster', '0123/456', 1, 1, 'www.muster.test' , 1); 

INSERT INTO adressen (strasse, hausnummer, plz, ort, aid) VALUES
	('Dorfplatz', '1', '12345', 'Oedland', 1);

INSERT INTO urlauber (vorname, nachname, telefon, id, aid, uid) VALUES
	('Erika', 'Mustermann', '0456/123456', 2, 2, 1);

INSERT INTO adressen (strasse, hausnummer, plz, ort, aid) VALUES
	('Bahnhofsplatz', '2', '34567', 'Grossmusterstadt', 2);

INSERT INTO hausmeister (vorname, nachname, telefon, id, aid, faehigkeiten, hid) VALUES
	('Paul', 'Emsig', '0123/567', 3, 3, '{"Klemnerarbeiten","Malerarbeiten"}', 1);

INSERT INTO adressen (strasse, hausnummer, plz, ort, aid) VALUES
	('Dorfplatz', '1', '12345', 'Ödland', 3);

INSERT INTO adressen (strasse, hausnummer, plz, ort, aid) VALUES
	('Am Wald', '5', '12345', 'Ödland', 4);
	
-- Währungssymbol kann weggelassen werden
INSERT INTO ferienwohnungen (personenzahl, zimmerzahl, preis, fid, vid, aid) VALUES
	(4, 2, 58.00, 1, 1, 4);

INSERT INTO ferienwohnungen (personenzahl, zimmerzahl, preis, fid, vid, aid) VALUES
	(5, 3, 68.00, 2, 1, 4);

-- Aufgabe 4d
-- Tabelle aendern, ohne neu anzulegen
ALTER TABLE urlauber ADD aend_datum DATE;
ALTER TABLE urlauber ADD bearbeiter VARCHAR(20);

-- Triggerfunktion
CREATE OR REPLACE FUNCTION urlauber_geaendert()
	RETURNS TRIGGER AS
	$$
		BEGIN
			NEW.aend_datum := NOW();
			NEW.bearbeiter := CURRENT_USER;
			RETURN NEW;
		END
	$$ LANGUAGE plpgsql;

CREATE TRIGGER urlauber_geaendert
	BEFORE INSERT OR UPDATE ON urlauber
	FOR EACH ROW EXECUTE PROCEDURE urlauber_geaendert();