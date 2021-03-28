create database IspitSep16
use IspitSep16
create table Klijenti(
KlijentID int identity(1,1) constraint PK_Klijent primary key,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null,
Telefon nvarchar(20) not null,
Mail nvarchar(50) not null constraint UQ_Mail unique,
BrojRacuna nvarchar(15) not null,
KorisnickoIme nvarchar(20) not null,
Lozinka nvarchar(20) not null
)
create table Transakcije(
TransakcijaID int identity(1,1) constraint PK_Transakcija primary key,
Datum datetime not null,
TipTransakcije nvarchar(30) not null,
PosiljalacID int not null constraint FK_Posiljalac foreign key(PosiljalacID) references Klijenti(KlijentID),
PrimalacID int not null constraint FK_Primalac foreign key (PrimalacID) references Klijenti(KlijentID),
Svrha nvarchar(50) not null,
Iznos decimal not null
)

insert into Klijenti
select top 10 P.FirstName,P.LastName,PP.PhoneNumber,EA.EmailAddress,SC.AccountNumber,P.FirstName+'.'+P.LastName as 'KorisnickoIme',RIGHT(PPas.PasswordHash,8) as 'Lozinka'
from AdventureWorks2017.Person.Person as P
join AdventureWorks2017.Person.PersonPhone as PP
on P.BusinessEntityID=PP.BusinessEntityID
join AdventureWorks2017.Person.EmailAddress as EA
on P.BusinessEntityID=EA.BusinessEntityID
join AdventureWorks2017.Person.Password as PPas
on P.BusinessEntityID=PPas.BusinessEntityID
join AdventureWorks2017.Sales.Customer as SC
on P.BusinessEntityID=SC.PersonID

insert into Transakcije(Datum,TipTransakcije,PosiljalacID,PrimalacID,Svrha,Iznos)
values ('2019-08-02','transakcija2',1,2,'treba',152),
		('2018-4-13','transakcija1',2,3,'svrha',100),
		('2014-10-22','transakcija3',3,4,'fudo reko treba',152.5),
		('2008-10-09','transakcija4',4,5,'evo ne znam',34.56),
		('2007-05-30','transakcija5',5,6,'treba za faks',1026),
		('2011-05-28','transakcija6',6,7,'svrha',542.10),
		('1999-03-15','transakcija7',7,8,'neophodno',658.30),
		('2013-06-14','transakcija8',8,9,'primarna vaznost',120),
		('2019-01-08','transakcija9',9,10,'nebitno al haj',160),
		('2019-01-16','transakcija10',1,8,'potrebno',1900),
		('2019-07-15','transakcija11',2,7,'obavezno',487.78)

create nonclustered index IX_Klijenti
on Klijenti(Ime,Prezime)
include (BrojRacuna)

select Ime,Prezime,BrojRacuna
from Klijenti
where Ime like 'J%' AND BrojRacuna LIKE '%0'

alter index IX_Klijenti
on Klijenti
disable


create procedure proc_Unos
(@Ime nvarchar(30), 
@Prezime nvarchar(30),
@Telefon nvarchar(20),
@Mail nvarchar(50), 
@BrojRacuna nvarchar(15), 
@KorisnickoIme nvarchar(20),
@Lozinka nvarchar(20))
as 
begin
insert into Klijenti
	values(@Ime,@Prezime,@Telefon,@Mail,@BrojRacuna,@KorisnickoIme,@Lozinka)
end


exec proc_Unos 'novi','klijent','0123456','nk@gmail.com','123123123','novi.klijent','password'

create view pogled_prikaz
as
select T.Datum,T.TipTransakcije,K1.Ime+' '+K1.Prezime as 'Posiljalac',K1.BrojRacuna as 'Racun posiljaoca',K2.Ime+' '+K2.Prezime as 'Primalac',K2.BrojRacuna as 'Racun primaoca',T.Svrha,T.Iznos
from Transakcije as T
join Klijenti as K1
on T.PosiljalacID=K1.KlijentID
join Klijenti as K2 
on T.PrimalacID =K2.KlijentID

create procedure prikaz_transakcija
(@BrRac nvarchar(15))
as
begin
select *
from pogled_prikaz 
where [Racun posiljaoca]=@BrRac
end
exec prikaz_transakcija 'AW00011020'

 select YEAR(Datum) as Godina,COUNT(TransakcijaID) as 'Broj transakcija'
 from Transakcije
 group by YEAR(Datum)
 order by Godina

 create procedure brisanje_Klijenti
 (@ID int)
 as
 begin
	delete from Transakcije
	where PosiljalacID=@ID or PrimalacID=@ID

	delete from Klijenti
	where KlijentID=@ID
end

exec brisanje_Klijenti 2

create procedure proc_Pretraga
(@brRac nvarchar(15)=NULL,@prezime nvarchar(30)=NULL)
as
begin
	select *
	from pogled_prikaz
	where ([Racun posiljaoca]=@brRac or @brRac is null) and  (RIGHT(Posiljalac,LEN(Posiljalac)-CHARINDEX(' ',Posiljalac))Like @prezime+'%' or @prezime is null)
end

exec proc_Pretraga
exec proc_Pretraga 'AW00011025'
exec proc_Pretraga 'Zhao'
exec proc_Pretraga 'AW00011048','Powell'


















