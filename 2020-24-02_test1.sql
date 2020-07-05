DROP TABLE IF EXISTS person CASCADE; -- löscht abhängige Tabellen gleich mit

CREATE TABLE person(
	pname CHAR(25),
	city CHAR(50),
	birthdate DATE PRIMARY KEY) WITH OIDS;

CREATE TABLE professor(
	dept CHAR(20),
	field CHAR(20),
	tenure BOOL) INHERITS (person) with OIDS;

CREATE TABLE student(
	studid CHAR(12),
	college CHAR(10),
	major CHAR(10),
	level CHAR(20)) INHERITS (person) with OIDS;
	
SELECT OID,* FROM person;
SELECT * from student WHERE OID=130041;
SELECT * from student WHERE MAJOR='CS';

-- Achtung: Bei kompletter Ausführung werden die über den Insertion-Assistenten eingetragenen Daten gelöscht und die Tabellen neu erstellt
-- Zur Vermeidung: INSERT INTO-Anweisung einfügen!

-- Sichten (Views; unter MS Access: "Abfragen")
CREATE VIEW studentview AS
	SELECT pname, birthdate, college, major, level FROM student;

-- kann behandelt werden wie jede andere Tabelle --
SELECT * from studentview;

INSERT INTO studentview VALUES
	('Benjamin Krause', '1994-06-16', 'IT', 'CS', '4');

SELECT * from studentview

-- Arrays als mehrwertige Attribute
ALTER TABLE student ADD geschwister VARCHAR(25)[];

UPDATE student SET geschwister='{"Trick", "Track"}' WHERE pname='Tick Duck';
UPDATE student SET geschwister='{"Tick Duck", "Track Duck"}' WHERE pname='Trick Duck';
UPDATE student SET geschwister='{"Tick", "Trick Duck"}' WHERE pname='Track Duck';

SELECT geschwister FROM student WHERE pname='Tick Duck';
SELECT geschwister[1] FROM student WHERE pname='Tick Duck';
SELECT geschwister[2] FROM student WHERE pname='Tick Duck';

-- Funktionen
-- ##########

-- mathematische Funktionen
SELECT ABS(-34.579);
SELECT PI();
SELECT ROUND(7.345, 2);
SELECT RANDOM();
SELECT SQRT(2);
SELECT CEIL(4.1);
SELECT FLOOR(4.1);
SELECT MOD(1925, 10);

-- Zeichenkettenfunktionen
SELECT ASCII('A');
SELECT CHR(65);
SELECT LOWER('Konsequente Kleinschreibung');
SELECT UPPER('konsequente großschreibung');
SELECT POSITION('e' IN 'konsequent');
SELECT 'Konsequente' || 'Kleinschreibung' || 'oder' || 'Großschreibung' || '.';
SELECT SUBSTRING('PostgreSQL', 1, 7);

SELECT TRIM(BOTH '*' FROM '***PostgreSQL***');
-- BTRIM, LTRIM, RTRIM für einen Trim am bzw. an den jeweiligen Enden des Strings

SELECT INITCAP('wir sind schreibfaul und schreiben alles klein');
SELECT TO_HEX(65);
SELECT REPEAT('Fülltext ', 10);
SELECT TRANSLATE('7350', '012345689', 'abcdefghijklmno');
SELECT TRANSLATE('IBM', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'ZABCDEFGHIJKLMNOPQRSTUVWXY');

-- Datum und Uhrzeit
SELECT CURRENT_DATE;
SELECT CURRENT_TIME;
SELECT CURRENT_TIMESTAMP;
SELECT LOCALTIME; 
SELECT LOCALTIMESTAMP;
SELECT NOW();
SELECT TIMEOFDAY();

-- Berechnungen mit Datum/Uhrzeit
SELECT AGE('1994-06-16', '2020-02-24');
SELECT AGE(CURRENT_DATE, '1994-06-16');
SELECT EXTRACT(YEAR FROM AGE(CURRENT_DATE, '1994-06-16'));
SELECT CURRENT_DATE + INTERVAL '30 DAYS' AS "+ 30 Tage";
SELECT DATE '2020-02-24' + INTERVAL '30 DAYS' AS "+ 30 Tage";

-- SQL Funktionen
CREATE OR REPLACE FUNCTION geschwister(TEXT, INT)
	RETURNS VARCHAR(30) AS 
	$$
		SELECT geschwister[$2] FROM student WHERE pname =$1;
		$$ LANGUAGE SQL;

SELECT geschwister ('Track Duck', 2);

-- PL/pgSQL Funktionen
CREATE OR REPLACE FUNCTION Arith_Mittel(INT, INT)
	RETURNS NUMERIC AS
	$$
		SELECT ($1 + $2) / 2.0
		$$ LANGUAGE SQL;

SELECT Arith_Mittel(2,5);

-- mit Variablendeklaration
CREATE OR REPLACE FUNCTION Arith_Mittel(INT, INT)
	RETURNS NUMERIC AS
	$$
	DECLARE
		Zahl1 ALIAS FOR $1;
		Zahl2 ALIAS FOR $2;
		ergebnis NUMERIC;
	BEGIN
		ergebnis := (Zahl1 + Zahl2)/2.0;
		RETURN ergebnis;
	END
	$$ LANGUAGE plpgsql;

SELECT Arith_Mittel(2,5);
