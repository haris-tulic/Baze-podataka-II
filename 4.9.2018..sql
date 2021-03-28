CREATE DATABASE IB170030
USE IB170030

CREATE TABLE Autori(
AutorID  nvarchar (11) CONSTRAINT PK_Autori PRIMARY KEY (AutorID),
Prezime nvarchar (25) not null,
Ime nvarchar (25) not null,
Telefon nvarchar(20) default null,
DatumKreiranjaZapisa date default getdate() not null,
DatumModifikovanjaZapisa date default null
)
CREATE TABLE Izdavaci(
IzdavacID nvarchar (4)  CONSTRAINT PK_Izdavaci PRIMARY KEY(IzdavacID),
Naziv nvarchar (100) not null UNIQUE,
Biljeske nvarchar (1000) default 'Loprem ipsum',
DatumKreiranja date default getdate() not null,
DatumModifikovanjaZapisa date default null
)
CREATE TABLE Naslovi(
NaslovID nvarchar(6) CONSTRAINT PK_Naslovi PRIMARY KEY(NaslovID),
IzdavacID nvarchar (4) CONSTRAINT FK_IzdavaciNaslovi FOREIGN KEY (IzdavacID) REFERENCES Izdavaci(IzdavacID),
Naslov nvarchar(100) not null,
Cijena money,
DatumIzdavanja date default getdate() not null,
DatumKreiranjaZapisa date default getdate() not null,
DatumModifikovanjaZapisa date default null
)
CREATE TABLE NasloviAutori(
AutorID nvarchar (11) CONSTRAINT FK_AutoriNasloviAutori FOREIGN KEY (AutorID) REFERENCES Autori(AutorID),
NaslovID nvarchar(6)  CONSTRAINT FK_AutoriNasloviNaslovi FOREIGN KEY (NaslovID) REFERENCES Naslovi(NaslovID),
DatumKreiranjaZapisa date default getdate() not null,
DatumModifikovanjaZapisa date default null,
constraint PK_NasloviAutori PRIMARY KEY (AutorID,NaslovID)
)



insert into Autori(AutorID,Prezime,Ime,Telefon)
select au_id,au_lname,au_fname,phone
from pubs.dbo.authors as A
where A.au_id in(select au_id from pubs.dbo.authors)
order by newid()
select *from Autori

insert into Izdavaci(IzdavacID,Naziv,Biljeske)
select P.pub_id,P.pub_name,SUBSTRING(pubI.pr_info,0,100) as Biljeske
from pubs.dbo.publishers as P inner join pubs.dbo.pub_info as pubI
on P.pub_id=pubI.pub_id
where p.pub_id in( select pub_id from pubs.dbo.publishers)
order by newid()
select *from Izdavaci

insert into Naslovi(NaslovID,IzdavacID,Naslov,Cijena)
select t.title_id,t.pub_id,t.title,t.price
from pubs.dbo.titles as t
where t.title_id in(select title_id from pubs.dbo.titles)
order by newid()
select *from Naslovi

insert into NasloviAutori(AutorID,NaslovID)
select ta.au_id,ta.title_id
from pubs.dbo.titleauthor as ta
where ta.title_id in(select title_id from pubs.dbo.titleauthor)
order by newid()
select *from NasloviAutori

create table Gradovi(
GradID int  constraint PK_Gradovi primary key (GradID) identity(5,5),
Naziv nvarchar(100) not null unique,
DatumKreiranjaZapisa date default getdate() not null,
DatumModifikovanjaZapisa date default null
)

insert into Gradovi(Naziv)
select distinct A.city
from pubs.dbo.authors as A
where A.au_id in
(select au_id from pubs.dbo.authors)
select *from Gradovi

ALTER TABLE Autori
ADD GradID int 

ALTER TABLE Autori
ADD CONSTRAINT FK_GradID foreign key (GradID) references Gradovi(GradID)

create procedure autor_san_francisco
as
begin
update top(10) Autori
set GradID=(select GradID
from Gradovi where Naziv ='San Francisco')
end

exec autor_san_francisco

create procedure autor_berkeley
as
begin
update Autori
set GradID=(select GradID from Gradovi where Naziv='Berkeley')
where GradID is null
end
exec autor_berkeley

create view autori_pogled
as
select A.Prezime+' '+A.Ime as ImePrezime,G.Naziv,N.Naslov,N.Cijena,I.Naziv as Izdavac,I.Biljeske
from Naslovi as N join Izdavaci as I
on N.IzdavacID=I.IzdavacID
join NasloviAutori as NA
on N.NaslovID=NA.NaslovID
join Autori as A
on NA.AutorID=A.AutorID
join Gradovi as G
on G.GradID=A.GradID
where N.Cijena is not null and N.Cijena>10
 and I.Naziv Like('%&%') and A.GradID=(select GradID from Gradovi where Naziv='San Francisco')

select *from autori_pogled


alter table Autori
add Email nvarchar(100) default null

create procedure autor_email_san
as
begin
update Autori
set Email=Ime+'.'+Prezime+'@fit.ba'
where GradID=(select GradID from Gradovi where Naziv='San Francisco')
end
exec autor_email_san

create procedure autor_email_ber
as
begin
update Autori
set Email=Prezime+'.'+Ime+'@fit.ba'
where Email is null
end
exec autor_email_ber

select isnull(P.Title,'N/A') as Title,P.LastName,P.FirstName,
EA.EmailAddress,PP.PhoneNumber,CC.CardNumber,
P.FirstName+'.'+P.LastName as UserName,
replace(lower(left(convert(nvarchar(MAX), newid()),16)),'-','7')as Password
into #privremena
from AdventureWorks2017.Person.Person as P join
AdventureWorks2017.Person.EmailAddress as EA
on P.BusinessEntityID=EA.BusinessEntityID
join AdventureWorks2017.Sales.PersonCreditCard as PCC
on P.BusinessEntityID=PCC.BusinessEntityID
join AdventureWorks2017.Sales.CreditCard as CC
on PCC.CreditCardID=CC.CreditCardID
join AdventureWorks2017.Person.PersonPhone as PP
on P.BusinessEntityID=PP.BusinessEntityID
order by 2,3

select *from #privremena 

CREATE INDEX IX_Prvi on #privremena
(Username)

CREATE INDEX IX_Drugi on #privremena
(LastName, FirstName)

select Username, LastName, FirstName
from #privremena
where Username like 'Humberto.Acevedo'

create procedure izbrisi_Kartice
as
begin
delete 
from #privremena
where CardNumber is null
end

exec izbrisi_Kartice


backup database IB170030 to 
disk ='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\IB170030.bak'

drop table #privremena

create procedure brisanje
as
begin
delete from Naslovi
delete from Izdavaci
delete from NasloviAutori
delete from Autori
delete from Gradovi
end

exec brisanje
