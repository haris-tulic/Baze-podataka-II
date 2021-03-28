CREATE DATABASE PrimjerIspita

USE PrimjerIspita

CREATE TABLE Narudzba(
NarudzbaID INT CONSTRAINT PK_NarudzbaID PRIMARY KEY,
DatumNarudzbe DATE,
DatumPrijema DATE,
DatumIsporuke DATE,
TrosakPrevoza MONEY,
PunaAdresa NVARCHAR(70)
)
CREATE TABLE Dobavljac(
DobavljacID INT CONSTRAINT PK_DobavljacID PRIMARY KEY,
NazivDobavljaca NVARCHAR(40) NOT NULL,
PunaAdresa NVARCHAR(60),
Drzava NVARCHAR(15)
)
CREATE TABLE Proizvod(
NarudzbaID INT NOT NULL,
DobavljacID INT NOT NULL,
ProizvodID INT NOT NULL,
NazivProizvoda NVARCHAR(40) NOT NULL,
Cijena INT NOT NULL,
Kolicina INT NOT NULL,
Popust DECIMAL(8,2) NOT NULL,
Raspolozivost BIT NOT NULL,
CONSTRAINT PK_ProizvodID PRIMARY KEY(NarudzbaID,DobavljacID,ProizvodID),
CONSTRAINT FK_ProizvodDobavljac FOREIGN KEY(DobavljacID) REFERENCES Dobavljac(DobavljacID),
CONSTRAINT FK_ProizvodNarudzba FOREIGN KEY (NarudzbaID) REFERENCES Narudzba(NarudzbaID)
)

INSERT INTO Narudzba
SELECT O.OrderID, O.OrderDate, O.RequiredDate, O.ShippedDate, O.Freight,
		O.ShipAddress+' '+ISNULL(O.ShipPostalCode,'00000')+' '+O.ShipCity
FROM Northwind.dbo.Orders AS O
WHERE YEAR(O.OrderDate)>=1997 AND O.ShippedDate IS NOT NULL

INSERT INTO Dobavljac
SELECT S.SupplierID, S.CompanyName, S.Address+' '+ISNULL(S.PostalCode,'00000')+' '+S.City,S.Country
FROM Northwind.dbo.Suppliers AS S

INSERT INTO Proizvod
SELECT OD.OrderID,P.SupplierID,P.ProductID,P.ProductName,OD.UnitPrice,OD.Quantity,OD.Discount,P.Discontinued
FROM Northwind.dbo.[Order Details] AS OD JOIN Northwind.dbo.Products AS P ON
		OD.ProductID=P.ProductID JOIN Northwind.dbo.Orders AS O ON OD.OrderID=O.OrderID
WHERE P.UnitPrice>10 AND OD.Discount>0 AND YEAR(O.OrderDate)>=1997 AND O.ShippedDate IS NOT NULL

--Z3
SELECT D.NazivDobavljaca,P.NazivProizvoda, COUNT(P.DobavljacID) AS 'Ukupan broj narudzbi'
FROM Proizvod AS P JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID
GROUP BY D.NazivDobavljaca,P.NazivProizvoda
ORDER BY 3 DESC

--Z4
SELECT P.DobavljacID,P.NarudzbaID, SUM((P.Cijena-(P.Cijena*P.Popust))*P.Kolicina) AS 'Ukupno'
FROM Proizvod AS P
WHERE P.Popust>0.10
GROUP BY P.DobavljacID,P.NarudzbaID
HAVING SUM((P.Cijena-(P.Cijena*P.Popust))*P.Kolicina)<1000

-- sa podupitom
SELECT P.DobavljacID,P.NarudzbaID 
FROM Proizvod AS P
WHERE (SELECT SUM((PR.Cijena-(PR.Cijena*PR.Popust))*PR.Kolicina) 
		FROM Proizvod AS PR 
		WHERE P.DobavljacID=PR.DobavljacID AND P.NarudzbaID=PR.NarudzbaID)<1000 AND P.Popust>0.10
GROUP BY P.DobavljacID,P.NarudzbaID 

--Z5
SELECT N.NarudzbaID, DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke) AS 'Razlika dana', YEAR(GETDATE()) AS 'Godina'
FROM Narudzba AS N
WHERE YEAR(N.DatumNarudzbe)=1997 AND DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke)<10
UNION
SELECT N.NarudzbaID, DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke) AS 'Razlika dana', YEAR(GETDATE()) AS 'Godina'
FROM Narudzba AS N
WHERE YEAR(N.DatumNarudzbe)=1998 AND DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke)<10
ORDER BY 2 DESC


--Z6
SELECT N.NarudzbaID, DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke), MONTH(N.DatumNarudzbe),MONTH(N.DatumIsporuke),
	YEAR(N.DatumIsporuke)
FROM Narudzba AS N
WHERE MONTH(N.DatumNarudzbe)=MONTH(N.DatumIsporuke) AND YEAR(N.DatumNarudzbe)=1997
UNION 
SELECT N.NarudzbaID, DATEDIFF(DAY,N.DatumNarudzbe,N.DatumIsporuke), MONTH(N.DatumNarudzbe),MONTH(N.DatumIsporuke),
	YEAR(N.DatumIsporuke)
FROM Narudzba AS N
WHERE MONTH(N.DatumNarudzbe)=MONTH(N.DatumIsporuke) AND YEAR(N.DatumNarudzbe)=1998
ORDER BY 2 DESC

--Z7
SELECT N.PunaAdresa, RIGHT(N.PunaAdresa,4)
FROM Narudzba AS N
WHERE RIGHT(N.PunaAdresa,4) IN ('Graz','Köln')
ORDER BY 2 DESC

--Z8
GO
CREATE VIEW view_zad8
AS
SELECT P.NarudzbaID, YEAR(N.DatumNarudzbe) AS Godina, P.NazivProizvoda, D.NazivDobavljaca, 
	D.Drzava, N.TrosakPrevoza, 
FROM Narudzba AS N JOIN Proizvod AS P ON N.NarudzbaID=P.NarudzbaID JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID

--Z9

--Z10
CREATE VIEW view_zad10
AS
SELECT N.NarudzbaID, DAY(N.DatumPrijema) AS 'Dan prijema', P.Raspolozivost, RIGHT(N.PunaAdresa,7) AS Grad, D.Drzava
FROM Narudzba AS N JOIN Proizvod AS P ON N.NarudzbaID=P.NarudzbaID JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID
WHERE DAY(N.DatumPrijema)>11 AND DAY(N.DatumPrijema)<=31 AND RIGHT(N.PunaAdresa,7) LIKE 'Bergamo'

SELECT * FROM view_zad10

--Z11
CREATE PROCEDURE proc_zad11
(@BrojProizv INT =NULL)
AS
BEGIN
SELECT D.DobavljacID AS 'DobID', D.NazivDobavljaca, COUNT(ProizvodID)
FROM Proizvod AS P JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID
GROUP BY  D.DobavljacID,D.NazivDobavljaca
HAVING @BrojProizv=COUNT(ProizvodID)
END

EXEC proc_zad11 @BrojProizv=14
EXEC proc_zad11 @BrojProizv=22

--Z8

SELECT N.NarudzbaID, YEAR(N.DatumNarudzbe) AS 'Godina', P.NazivProizvoda,D.NazivDobavljaca,
	D.Drzava,N.TrosakPrevoza, (P.Cijena-(P.Cijena*P.Popust))*P.Kolicina AS 'Ukupno',
	LEFT(ROUND (N.TrosakPrevoza/((P.Cijena-(P.Cijena*P.Popust))*P.Kolicina)*100,2),5) AS 'Postotak'
FROM Narudzba AS N JOIN Proizvod AS P ON N.NarudzbaID=P.NarudzbaID JOIN Dobavljac AS D ON P.DobavljacID=D.DobavljacID
WHERE N.TrosakPrevoza> (P.Cijena-(P.Cijena*P.Popust))*P.Kolicina*0.3 AND N.TrosakPrevoza<(P.Cijena-(P.Cijena*P.Popust))*P.Kolicina




