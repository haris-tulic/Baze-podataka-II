create database ispit7_9_2017
use ispit7_9_2017

create table Klijenti(
KlijentID int identity(1,1) constraint PK_Klijent primary key,
Ime nvarchar(50) not null,
Prezime nvarchar(50) not null,
Grad nvarchar(50) not null,
Email nvarchar(50) not null,
Telefon nvarchar(50) not null
)
create table Racuni(
RacunID int identity(1,1) constraint PK_Racun primary key,
DatumOtvaranja date not null,
TipRacuna nvarchar(50) not null,
BrojRacuna nvarchar(16) not null,
Stanje decimal(8,2) not null,
KlijentID int not null constraint FK_Klijent foreign key(KlijentID) references Klijenti(KlijentID)
)
create table Transakcije(
TransakcijaID int identity(1,1) constraint PK_Transakcija primary key,
Datum datetime not null,
Primatelj nvarchar(50) not null,
BrojRacunaPrimatelj nvarchar(16) not null,
MjestoPrimatelja nvarchar(50) not null,
AdresaPrimatelja nvarchar(50),
Svrha nvarchar(200),
Iznos decimal(8,2) not null,
RacunID int not null constraint FK_RacunTransakcija foreign key(RacunID) references Racuni(RacunID)
)

create index IX_Email on Klijenti(Email)
create unique index IX_Racun on Racuni(BrojRacuna)

create procedure unos_Racuna
(
@DatumOtvaranja DATE,
@TipRacuna NVARCHAR(50),
@BrojRacuna NVARCHAR(16),
@Stanje DECIMAL(8,2),
@KlijentID INT
)
as 
begin
insert into Racuni values(@DatumOtvaranja,@TipRacuna,@BrojRacuna,@Stanje,@KlijentID)
end

insert into Klijenti
select LEFT(C.ContactName,CHARINDEX(' ',C.ContactName)-1),SUBSTRING(C.ContactName,CHARINDEX(' ',C.ContactName),30),C.City,REPLACE(C.ContactName,' ','.')+'@northwind.ba',C.Phone
from NORTHWND.dbo.Customers as C
join NORTHWND.dbo.Orders as O
on C.CustomerID=O.CustomerID
where year(O.OrderDate)=1996


EXEC unos_Racuna @DatumOtvaranja='2.3.2017',@TipRacuna='Rucni',@BrojRacuna='1111',@Stanje='200',@KlijentID=1
EXEC unos_Racuna @DatumOtvaranja='4.3.2017',@TipRacuna='Ne Rucni',@BrojRacuna='1112',@Stanje='300',@KlijentID=1
EXEC unos_Racuna @DatumOtvaranja='8.3.2017',@TipRacuna='Rucni',@BrojRacuna='1113',@Stanje='400',@KlijentID=2
EXEC unos_Racuna @DatumOtvaranja='6.3.2017',@TipRacuna='Ne Rucni',@BrojRacuna='1114',@Stanje='500',@KlijentID=5
EXEC unos_Racuna @DatumOtvaranja='7.3.2017',@TipRacuna='Rucni',@BrojRacuna='1115',@Stanje='600',@KlijentID=1
EXEC unos_Racuna @DatumOtvaranja='8.3.2017',@TipRacuna='Ne Rucni',@BrojRacuna='1116',@Stanje='200',@KlijentID=2
EXEC unos_Racuna @DatumOtvaranja='2.3.2017',@TipRacuna='Rucni',@BrojRacuna='1117',@Stanje='300',@KlijentID=4
EXEC unos_Racuna @DatumOtvaranja='3.3.2017',@TipRacuna='Ne Rucni',@BrojRacuna='1118',@Stanje='400',@KlijentID=4
EXEC unos_Racuna @DatumOtvaranja='5.3.2017',@TipRacuna='Ne Rucni',@BrojRacuna='1119',@Stanje='600',@KlijentID=7
EXEC unos_Racuna @DatumOtvaranja='8.3.2017',@TipRacuna='Rucni',@BrojRacuna='1120',@Stanje='500',@KlijentID=9

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,1
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,2
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,3
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,4
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,5
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,6
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,7
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,8
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,9
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

insert into Transakcije
select top 10 O.OrderDate,O.ShipName,CONVERT(nvarchar(20),O.OrderID)+'00000123456',O.ShipCity,
O.ShipAddress,null,OD.UnitPrice*OD.Quantity,10
from NORTHWND.dbo.Orders as O tablesample(10 percent)
join NORTHWND.dbo.[Order Details] as OD
on O.OrderID=OD.OrderID

select *from Klijenti

update Racuni
set Stanje=Stanje+500
where (select top 1 Grad From Klijenti where Klijenti.KlijentID=Racuni.KlijentID) like 'London'
		and month(Racuni.DatumOtvaranja)=2

create view pogled_prikaz
as
select K.Ime+' '+K.Prezime as 'ImePrezime', K.Grad,K.Telefon,R.TipRacuna,R.BrojRacuna,R.Stanje,T.BrojRacunaPrimatelj,T.Iznos
from Klijenti as K left join Racuni as R on K.KlijentID=R.KlijentID left join Transakcije as T on R.RacunID=T.RacunID

select *from pogled_prikaz

create procedure proc_Prikaz
(
@BrojRacuna nvarchar(16)='-1'
)
as
begin
if(@BrojRacuna='-1')
(
	select P.ImePrezime,P.Grad,ISNULL(P.BrojRacuna,'N/A'),
	ISNULL(convert(nvarchar(10),P.Stanje),'N/A'),
	ISNULL(convert(nvarchar(10),sum(P.Iznos)),'N/A') as 'Ukupno transakcija'
	from pogled_prikaz as P
	group by P.ImePrezime,P.Grad,P.BrojRacuna,P.Stanje
)
else(
SELECT pogled.ImePrezime,pogled.Grad,ISNULL(pogled.BrojRacuna,'N/A'),
		ISNULL(CONVERT(NVARCHAR(10),pogled.Stanje),'N/A'),
		ISNULL(CONVERT(NVARCHAR(10),SUM(pogled.Iznos)),'N/A') AS 'Ukupno transakcija'
	FROM pogled_prikaz AS pogled
	WHERE pogled.BrojRacuna=@BrojRacuna
	GROUP BY pogled.ImePrezime,pogled.Grad,pogled.BrojRacuna,pogled.Stanje
)
end
exec proc_Prikaz @BrojRacuna='1112'
exec proc_Prikaz

create procedure brisanje_klijenta
(
@KlijentID int
)
as
begin
delete Transakcije
where Transakcije.RacunID in(
select R.RacunID
from Klijenti as K join Racuni as R on K.KlijentID=R.KlijentID
where R.KlijentID=@KlijentID
)
delete Racuni
where Racuni.KlijentID=@KlijentID
delete Klijenti
where KlijentID=@KlijentID
end

exec brisanje_klijenta @KlijentID=9

create procedure proc_9
(
@Grad NVARCHAR(50),
@Mjesec INT,
@IznosUvecanja DECIMAL(8,2)
)
as
begin
UPDATE Transakcije
SET Iznos=Iznos+@IznosUvecanja
WHERE @Grad IN (SELECT pogled_prikaz.Grad FROM pogled_prikaz) AND MONTH(Transakcije.Datum)=@Mjesec
end

exec proc_9 @Grad='London',@Mjesec=7,@IznosUvecanja=200
SELECT *
FROM Klijenti AS K JOIN Racuni AS R ON K.KlijentID=R.KlijentID JOIN Transakcije AS T ON R.RacunID=T.RacunID
