/*
Napomena:

A.
Prilikom  bodovanja rješenja prioritet ima rezultat koji upit treba da vrati (broj zapisa, vrijednosti agregatnih funkcija...).
U slučaju da rezultat upita nije tačan, a pogled, tabela... koji su rezultat tog upita se koriste u narednim zadacima, 
tada se rješenja narednih zadataka, bez obzira na tačnost koda, ne boduju punim brojem bodova, 
jer ni ta rješenja ne mogu vratiti tačan rezultat (broj zapisa, vrijednosti agregatnih funkcija...).

B.
Tokom pisanja koda obratiti posebnu pažnju na tekst zadatka i ono što se traži zadatkom. 
Prilikom pregleda rada pokreće se kod koji se nalazi u sql skripti i 
sve ono što nije urađeno prema zahtjevima zadatka ili je pogrešno urađeno predstavlja grešku. 
*/


------------------------------------------------
--1
/*
a) Kreirati bazu podataka pod vlastitim brojem indeksa.
*/
CREATE DATABASE bazeJuli;
USE bazeJuli;

--Prilikom kreiranja tabela voditi računa o međusobnom odnosu između tabela.
/*
b) Kreirati tabelu radnik koja će imati sljedeću strukturu:
	- radnikID, cjelobrojna varijabla, primarni ključ
	- drzavaID, 15 unicode karaktera
	- loginID, 256 unicode karaktera
	- god_rod, cjelobrojna varijabla
	- spol, 1 unicode karakter
*/
CREATE TABLE radnik
(
	radnikID INT CONSTRAINT PK_radnik PRIMARY KEY,
	drzavaID NVARCHAR(15),
	loginID NVARCHAR(256),
	god_rod INT,
	spol NVARCHAR(1)
);
/*
c) Kreirati tabelu nabavka koja će imati sljedeću strukturu:
	- nabavkaID, cjelobrojna varijabla, primarni ključ
	- status, cjelobrojna varijabla
	- radnikID, cjelobrojna varijabla
	- br_racuna, 15 unicode karaktera
	- naziv_dobavljaca, 50 unicode karaktera
	- kred_rejting, cjelobrojna varijabla
*/
CREATE TABLE nabavka
(
	nabavkaID INT CONSTRAINT PK_nabavka PRIMARY KEY,
	status INT,
	radnikID INT CONSTRAINT FK_radnik_nabavka FOREIGN KEY REFERENCES radnik (radnikID),
	br_racuna NVARCHAR(15),
	naziv_dobavljaca NVARCHAR(50),
	kred_rejting INT
);
/*
c) Kreirati tabelu prodaja koja će imati sljedeću strukturu:
	- prodajaID, cjelobrojna varijabla, primarni ključ, inkrementalno punjenje sa početnom vrijednošću 1, samo neparni brojevi
	- prodavacID, cjelobrojna varijabla
	- dtm_isporuke, datumsko-vremenska varijabla
	- vrij_poreza, novčana varijabla
	- ukup_vrij, novčana varijabla
	- online_narudzba, bit varijabla sa ograničenjem kojim se mogu unijeti samo cifre 0 ili 1
*/
CREATE TABLE prodaja
(
	prodajaID INT CONSTRAINT PK_prodaja PRIMARY KEY IDENTITY(1, 2),
	prodavacID INT CONSTRAINT FK_radnik_prodaja FOREIGN KEY REFERENCES radnik (radnikID),
	dtm_isporuke DATETIME,
	vrij_poreza MONEY,
	ukup_vrij MONEY,
	online_narudzba BIT
);
--10 bodova



--------------------------------------------
--2. Import podataka
/*
a) Iz tabele Employee iz šeme HumanResources baze AdventureWorks2017 u tabelu radnik importovati podatke po sljedećem pravilu:
	- BusinessEntityID -> radnikID
	- NationalIDNumber -> drzavaID
	- LoginID -> loginID
	- godina iz kolone BirthDate -> god_rod
	- Gender -> spol
*/
-------------------------------------------------
INSERT INTO radnik
SELECT 
	E.BusinessEntityID,
	E.NationalIDNumber,
	E.LoginID,
	YEAR(E.BirthDate),
	E.Gender
FROM AdventureWorks2017.HumanResources.Employee as E

/*
b) Iz tabela PurchaseOrderHeader i Vendor šeme Purchasing baze AdventureWorks2017 u tabelu nabavka importovati podatke po sljedećem pravilu:
	- PurchaseOrderID -> dobavljanjeID
	- Status -> status
	- EmployeeID -> radnikID
	- AccountNumber -> br_racuna
	- Name -> naziv_dobavljaca
	- CreditRating -> kred_rejting
*/
INSERT INTO nabavka
SELECT 
	POH.PurchaseOrderID,
	POH.Status,
	POH.EmployeeID,
	V.AccountNumber,
	V.Name,
	V.CreditRating
FROM AdventureWorks2017.Purchasing.PurchaseOrderHeader AS POH
	INNER JOIN AdventureWorks2017.Purchasing.Vendor AS V ON V.BusinessEntityID = POH.VendorID

/*
c) Iz tabele SalesOrderHeader šeme Sales baze AdventureWorks2017
u tabelu prodaja importovati podatke po sljedećem pravilu:
	- SalesPersonID -> prodavacID
	- ShipDate -> dtm_isporuke
	- TaxAmt -> vrij_poreza
	- TotalDue -> ukup_vrij
	- OnlineOrderFlag -> online_narudzba
*/
--10 bodova
INSERT INTO prodaja (prodavacID, dtm_isporuke, vrij_poreza, ukup_vrij, online_narudzba)
SELECT 
	SOH.SalesPersonID,
	SOH.ShipDate,
	SOH.TaxAmt,
	SOH.TotalDue,
	SOH.OnlineOrderFlag
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH



------------------------------------------
--3.
/*
a) U tabeli radnik dodati kolonu st_kat (starosna kategorija), tipa 3 karaktera.
*/
ALTER TABLE radnik
ADD st_kat NVARCHAR(3)
GO
/*
b) Prethodno kreiranu kolonu popuniti po principu:
	starosna kategorija		uslov
	I						osobe do 30 godina starosti (uključuje se i 30)
	II						osobe od 31 do 49 godina starosti
	III						osobe preko 50 godina starosti
*/
UPDATE radnik
SET st_kat = 
	CASE
		WHEN YEAR(CURRENT_TIMESTAMP) - god_rod <= 30 THEN 'I'
		WHEN YEAR(CURRENT_TIMESTAMP) - god_rod BETWEEN 31 AND 49 THEN 'II'
		WHEN YEAR(CURRENT_TIMESTAMP) - god_rod >= 50 THEN 'III'
	END;

SELECT * FROM radnik;

/*
c) Neka osoba sa navršenih 65 godina starosti odlazi u penziju.
Prebrojati koliko radnika ima 10 ili manje godina do penzije.
Rezultat upita isključivo treba biti poruka 
'Broj radnika koji imaju 10 ili manje godina do penzije je ' nakon čega slijedi prebrojani broj.
Neće se priznati rješenje koje kao rezultat upita vraća više kolona.
*/
SELECT 'Broj radnika koji imaju 10 ili manje godina do penzije je ' + CONVERT(NVARCHAR, COUNT(*))
FROM radnik
WHERE 65 - (YEAR(CURRENT_TIMESTAMP) - god_rod) BETWEEN 1 AND 10;
--15 bodova

------------------------------------------
--4.
/*
a) U tabeli prodaja kreirati kolonu stopa_poreza (10 unicode karaktera)
*/
ALTER TABLE prodaja
ADD stopa_poreza NVARCHAR(10)
/*
b) Prethodno kreiranu kolonu popuniti kao količnik vrij_poreza i ukup_vrij,
Stopu poreza izraziti kao cijeli broj sa oznakom %, pri čemu je potrebno 
da između brojčane vrijednosti i znaka % bude prazno mjesto. (npr. 14.00 %)
*/
UPDATE prodaja
SET stopa_poreza = CONVERT(NVARCHAR, vrij_poreza / ukup_vrij * 100) + ' %';
SELECT * FROM prodaja;
GO;
--10 bodova


-----------------------------------------
--5.
/*
a)
Koristeći tabelu nabavka kreirati pogled view_slova sljedeće strukture:
	- slova
	- prebrojano, prebrojani broj pojavljivanja slovnih dijelova podatka u koloni br_racuna. 
b)
Koristeći pogled view_slova odrediti razliku vrijednosti između prebrojanih i srednje vrijednosti kolone.
Rezultat treba da sadrži kolone slova, prebrojano i razliku.
Sortirati u rastućem redolsijedu prema razlici.
*/
--10 bodova
--a
CREATE VIEW view_slova
AS
	SELECT SUBSTRING(br_racuna, 0, LEN(br_racuna) - 3) AS slova, COUNT(*) AS prebrojano
	FROM nabavka
	GROUP BY SUBSTRING(br_racuna, 0, LEN(br_racuna) - 3)

SELECT * FROM view_slova

--b
SELECT 
	slova,
	prebrojano,
	prebrojano - (SELECT AVG(prebrojano) FROM  view_slova) AS razlika
FROM view_slova
ORDER BY razlika
-----------------------------------------
--6.
/*
a) Koristeći tabelu prodaja kreirati pogled view_stopa sljedeće strukture:
	- prodajaID
	- stopa_poreza
	- stopa_num, u kojoj će bit numerička vrijednost stope poreza 
b)
Koristeći pogled view_stopa, a na osnovu razlike između vrijednosti u koloni stopa_num i 
srednje vrijednosti stopa poreza za svaki proizvodID navesti poruku 'manji', odnosno, 'veći'. 
*/
--12 bodova
CREATE VIEW view_stopa
AS
	SELECT 
		prodajaID,
		stopa_poreza,
		CONVERT(FLOAT, SUBSTRING(stopa_poreza, 0, LEN(stopa_poreza) - 1)) AS stopa_num
	FROM prodaja


SELECT *,
	CASE
		WHEN stopa_num > (SELECT AVG(stopa_num) FROM view_stopa) THEN 'veci'
		WHEN stopa_num < (SELECT AVG(stopa_num) FROM view_stopa) THEN 'manji'
	END
FROM view_stopa

------------------------------------------
--7.
/*
Koristeći pogled view_stopa_poreza kreirati proceduru proc_stopa_poreza
tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara 
(možemo ostaviti bilo koji parametar bez unijete vrijednosti),
pri čemu će se prebrojati broja zapisa po stopi poreza uz uslova 
da se dohvate samo oni zapisi u kojima je stopa poreza veća od 10 %.
Proceduru pokrenuti za sljedeće vrijednosti:
	- stopa poreza = 12, 15 i 21 
*/
--10 bodova

CREATE PROCEDURE proc_stopa_poreza
(
	@prodajaID INT = NULL,
	@stopa_poreza NVARCHAR(10) = NULL,
	@stopa_num FLOAT = NULL
)
AS
BEGIN
	SELECT COUNT(*)
	FROM view_stopa
	WHERE 
		prodajaID = @prodajaID OR
		stopa_poreza = @stopa_poreza OR
		stopa_num = @stopa_num AND stopa_num > 10
END

EXEC proc_stopa_poreza 12
EXEC proc_stopa_poreza 15
EXEC proc_stopa_poreza 21

---------------------------------------------------------------------------------------------------
--8.
/*
Kreirati proceduru proc_prodaja kojom će se izvršiti 
promjena vrijednosti u koloni online_narudzba tabele prodaja. 
Promjena će se vršiti tako što će se 0 zamijeniti sa NO, a 1 sa YES. 
Pokrenuti proceduru kako bi se izvršile promjene, a nakon toga onemogućiti 
da se u koloni unosi bilo kakva druga vrijednost osim NO ili YES.
*/
--13 bodova

CREATE PROCEDURE proc_prodaja
AS
BEGIN
	ALTER TABLE prodaja
	ALTER COLUMN online_narudzba NVARCHAR(3)

	UPDATE prodaja
	SET online_narudzba =
		CASE
			WHEN online_narudzba = 1 THEN 'YES'
			WHEN online_narudzba = 0 THEN 'NO'
		END

	ALTER TABLE prodaja
	ADD CONSTRAINT online_narudzba_value_check CHECK (online_narudzba = 'YES' OR online_narudzba = 'NO')
END

EXEC proc_prodaja
SELECT * FROM prodaja

------------------------------------------
--9.
/*
a) 
Nad kolonom god_rod tabele radnik kreirati ograničenje kojim će
se onemogućiti unos bilo koje godine iz budućnosti kao godina rođenja.
Testirati funkcionalnost kreiranog ograničenja navođenjem 
koda za insert podataka kojim će se kao godina rođenja
pokušati unijeti bilo koja godina iz budućnosti.
*/
ALTER TABLE radnik
ADD CONSTRAINT god_buducnosti_check CHECK (god_rod < CONVERT(INT, YEAR(CURRENT_TIMESTAMP)))

INSERT INTO radnik
VALUES (20000, 'A', 'A', 2500, 'M', 'I');
/*
b) Nad kolonom drzavaID tabele radnik kreirati ograničenje kojim će se ograničiti dužina podatka na 7 znakova. 
Ako je prethodno potrebno, izvršiti prilagodbu kolone, pri čemu nije dozvoljeno prilagođavati podatke čiji 
dužina iznosi 7 ili manje znakova.
Testirati funkcionalnost kreiranog ograničenja navođenjem koda za insert podataka 
kojim će se u drzavaID pokušati unijeti podataka duži od 7 znakova bilo koja godina iz budućnosti.
*/
--10 bodova

UPDATE radnik
SET drzavaID = LEFT(drzavaID, 7)
WHERE LEN(drzavaID) > 7

ALTER TABLE radnik
ADD CONSTRAINT drzavaID_duzina_check CHECK (LEN(drzavaID) <= 7)

INSERT INTO radnik
VALUES (20000, '12345678', 'A', 1980, 'M', 'I');
-----------------------------------------------
--10.
/*
Kreirati backup baze na default lokaciju, obrisati bazu, a zatim izvršiti restore baze. 
Uslov prihvatanja koda je da se može izvršiti.
*/
--2 boda

BACKUP DATABASE BP2_2020_07_24
TO DISK = 'bazeJuli.bak'
GO

USE master
DROP DATABASE bazeJuli

RESTORE DATABASE bazeJuli FROM DISK = 'bazeJuli.bak'
USE bazeJuli