create database BrojIndexa
GO

USE  BrojIndexa

CREATE TABLE Proizvodi(
ProizvodID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_PROIZVODID PRIMARY KEY,
Sifra nvarchar(50) not null,
Naziv nvarchar(50) not null,
Cijena decimal(18,2) not null
)


CREATE TABLE Skladista(
SkladisteID INT NOT NULL IDENTITY(1,1) CONSTRAINT PK_SkladisteID PRIMARY KEY,
Naziv nvarchar(50) not null,
Lokacija nvarchar(50) not null,
Oznaka nvarchar(10) not null constraint uq_oznaka unique
)
CREATE TABLE SkladistaProizvodi(
SkladisteID INT NOT NULL  CONSTRAINT FK_SkladisteID FOREIGN KEY REFERENCES Skladista(SkladisteID),
ProizvodID INT NOT NULL  CONSTRAINT FK_ProizvodID FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
Stanje int not null
)


--zadatak 2
-- a)
insert into Skladista
values
('Skladiste1','Mostar','SK1'),
('Skladiste2','Sarajevo','SK2'),
('Skladiste3','Tuzla','SK3')

SELECT *  from Skladista 
--b)
insert into Proizvodi(Sifra,Naziv,Cijena)
select top 10 p.ProductNumber,p.Name,p.ListPrice
from AdventureWorks2014.Production.Product as p inner join AdventureWorks2014.Production.ProductSubcategory as ps
on p.ProductSubcategoryID=ps.ProductSubcategoryID inner join AdventureWorks2014.Production.ProductCategory as pc
on ps.ProductCategoryID=pc.ProductCategoryID
where pc.Name='Bikes'
GROUP BY p.ProductNumber,p.Name,p.ListPrice,p.ProductID
order by (select sum (pod.OrderQty) from  AdventureWorks2014.Purchasing.PurchaseOrderDetail as pod
 inner join AdventureWorks2014.Production.Product as p
 on pod.ProductID=p.ProductID  ) desc
                              
select *
from Proizvodi
--c)
insert into SkladistaProizvodi(SkladisteID,ProizvodID,Stanje)
select s.SkladisteID,p.ProizvodID,100
from [dbo].[Proizvodi] as p cross join [dbo].[Skladista] as s
where p.ProizvodID IS NOT NULL AND s.SkladisteID IS NOT NULl

SELECT * FROM SkladistaProizvodi

--zadatak 3
create procedure usp_Insert_SkladistaProizvodi(
@SkladisteID INT,
@ProizvodID INT,
@Stanje INT
)
as
begin
update SkladistaProizvodi
set Stanje+=@Stanje
where SkladisteID=@SkladisteID and ProizvodID=@ProizvodID
end;

exec usp_Insert_SkladistaProizvodi 3,1,23

select *
from SkladistaProizvodi

--zadatak 4
create nonclustered index ix_proizvodi
on Proizvodi (Sifra,Naziv)
include(Cijena)

select Sifra,Naziv
from Proizvodi

alter index ix_proizvodi on Proizvodi
disable;

--zadatak 5
create view view_Skladista_Proivodi
as
select p.Naziv as 'Naziv proizvoda',p.Sifra,p.Cijena,s.Lokacija,s.Naziv as 'Naziv lokacije',s.Oznaka,sp.Stanje
from Proizvodi as p inner join SkladistaProizvodi as sp
on p.ProizvodID=sp.ProizvodID
inner join Skladista as s
on sp.SkladisteID=s.SkladisteID

select *
from view_Skladista_Proivodi

--zadatak 6
create procedure usp_selectBySifra(
@Sifra nvarchar(50)
)
as
begin
select sp.[Sifra],sp.[Naziv proizvoda],sp.[Cijena],sp.Stanje
from view_Skladista_Proivodi as sp
where sp.Sifra=@Sifra
end;

exec usp_selectBySifra 'BK-M82S-38'


--zadatak 7
create procedure usp_insert_proizvodi(
@Sifra nvarchar(50),
@Naziv nvarchar(50),
@Cijena decimal(18,2)
)
as begin
insert into Proizvodi(Sifra,Naziv,Cijena)
values (@Sifra,@Naziv,@Cijena)
insert into SkladistaProizvodi(SkladisteID,ProizvodID,Stanje)
values ((select SkladisteID FROM Skladista WHERE Oznaka='SK1'),(SELECT ProizvodID FROM Proizvodi WHERE Sifra=@Sifra),0)
end;


EXEC usp_insert_proizvodi 'Sifra123','Cokolada',1.25


select *
from Proizvodi

select *
from SkladistaProizvodi


alter procedure usp_delete_proizvodi(
@Sifra nvarchar(50)
)
as
begin

delete from SkladistaProizvodi
from Proizvodi as p inner join SkladistaProizvodi as sp
on p.ProizvodID=sp.ProizvodID
where p.Sifra=@Sifra
delete from Proizvodi
where Sifra=@Sifra
end;

exec usp_delete_proizvodi 'BK-M82S-42'

backup database BrojIndexa TO
DISK='C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\BrojIndexafull.bak'

backup database BrojIndexa TO
DISK='C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\BrojIndexadiff.bak'
with differential