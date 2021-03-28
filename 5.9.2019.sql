/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
create database ispit5_9
use ispit5_9


/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu narudzba sljedeće strukture:
	narudzbaID, cjelobrojna varijabla, primarni ključ
	dtm_narudzbe, datumska varijabla za unos samo datuma
	dtm_isporuke, datumska varijabla za unos samo datuma
	prevoz, novčana varijabla
	klijentID, 5 unicode karaktera
	klijent_naziv, 40 unicode karaktera
	prevoznik_naziv, 40 unicode karaktera
*/
create table narudzbe(
narudzbaID int constraint PK_Narudzba primary key (narudzbaID),
dtm_narudzbe date,
dtm_isporuke date,
prevoz money,
klijentID nvarchar(5),
klijent_naziv nvarchar(40),
prevoznik_naziv nvarchar(50)
)

/*
II. Kreirati tabelu proizvod sljedeće strukture:
	- proizvodID, cjelobrojna varijabla, primarni ključ
	- mj_jedinica, 20 unicode karaktera
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_web, tekstualna varijabla
*/
create table proizvod(
proizvodID int constraint PK_Proizvod primary key (proizvodID),
mj_jedinica nvarchar(20),
jed_cijena money,
kateg_naziv nvarchar(15),
dobavljac_naziv nvarchar(40),
dobavljac_web text
)

/*
III. Kreirati tabelu narudzba_proizvod sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- proizvodID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/
create table narudzba_proizvod(
narudzbaID int not null,
proizvodID int not null,
uk_cijena money,
constraint PK_narudzba_proizvod primary key(narudzbaID,proizvodID),
constraint FK_narudzba foreign key (narudzbaID) references narudzbe(narudzbaID),
constraint FK_proizvod foreign key(proizvodID) references proizvod(proizvodID),
)

--10 bodova



-------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Customers, Orders i Shipers baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- Freight -> prevoz
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/
insert into narudzbe
select O.OrderID,O.OrderDate,O.ShippedDate,O.Freight,C.CustomerID,C.CompanyName,S.CompanyName
from NORTHWND.dbo.Orders as O inner join NORTHWND.dbo.Customers as C on O.CustomerID=C.CustomerID
inner join NORTHWND.dbo.Shippers as S on S.ShipperID=O.ShipVia

/*
b) Iz tabela Categories, Product i Suppliers baze Northwind importovati podatke prema pravilu:
	- ProductID -> proizvodID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- HomePage -> dobavljac_web
*/
insert into proizvod
select P.ProductID,P.QuantityPerUnit,P.UnitPrice,C.CategoryName,S.CompanyName,S.HomePage
from NORTHWND.dbo.Products as P inner join NORTHWND.dbo.Categories as C on P.CategoryID=C.CategoryID
inner join NORTHWND.dbo.Suppliers as S on S.SupplierID=P.SupplierID

/*
c) Iz tabele Order Details baze Northwind importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> proizvodID
	- uk_cijena <- proizvod jedinične cijene i količine
uz uslov da nije odobren popust na proizvod.
*/
insert into narudzba_proizvod
select OD.OrderID,OD.ProductID,OD.UnitPrice*Od.Quantity
from NORTHWND.dbo.[Order Details] as OD
where Discount=0
--10 bodova


-------------------------------------------------------------------
/*
3. 
Koristeći tabele proizvod i narudzba_proizvod kreirati pogled view_kolicina koji će imati strukturu:
	- proizvodID
	- kateg_naziv
	- jed_cijena
	- uk_cijena
	- kolicina - količnik ukupne i jedinične cijene
U pogledu trebaju biti samo oni zapisi kod kojih količina ima smisao (nije moguće da je na stanju 1,23 proizvoda).
Obavezno pregledati sadržaj pogleda.
*/
create view view_kolicina
as
select P.proizvodID,P.kateg_naziv,P.jed_cijena,NP.uk_cijena,NP.uk_cijena/P.jed_cijena as kolicina
from proizvod as P inner join narudzba_proizvod as NP 
on P.proizvodID=NP.proizvodID
where floor(NP.uk_cijena/P.jed_cijena)=NP.uk_cijena/P.jed_cijena
--7 bodova
select *from view_kolicina

-------------------------------------------------------------------
/*
4. 
Koristeći pogled kreiran u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće nazive kategorija:
1. Produce
2. Beverages
*/

create procedure proc_kolicina
(
	@proizvodID int = NULL,
	@kateg_naziv NVARCHAR (15) = NULL,
	@jed_cijena decimal (5,2) = null,
	@uk_cijena decimal (5,2) = null,
	@kolicina decimal (5,2) = null
)
as
begin
select proizvodID,kateg_naziv,jed_cijena,uk_cijena,kolicina
from view_kolicina 
where 
	proizvodID=@proizvodID or
	kateg_naziv=@kateg_naziv or
	jed_cijena=@jed_cijena or
	uk_cijena=@uk_cijena or
	kolicina= @kolicina
end

exec proc_kolicina @kateg_naziv = 'Produce'
exec proc_kolicina @kateg_naziv = 'Beverages'
--8 bodova

------------------------------------------------
/*
5.
Koristeći pogled kreiran u 3. zadatku kreirati proceduru proc_br_kat_naziv koja će vršiti prebrojavanja po nazivu kategorije. Nakon kreiranja pokrenuti proceduru.
*/
create procedure proc_br_kat_naziv
as
begin
select kateg_naziv, count(kateg_naziv) as broj_kateg_naziv
from view_kolicina
group by kateg_naziv
end

exec proc_br_kat_naziv
--8
/*
kateg_naziv     broj_kateg_naziv
--------------- ----------------
Condiments      112
Beverages       220
Seafood         166
Dairy Products  189
Grains/Cereals  117
Confections     156
Produce         72
Meat/Poultry    68
*/
--5 bodova


-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba_proizvod kreirati pogled view_suma sljedeće strukture:
	- narudzbaID
	- suma - sume ukupne cijene po ID narudžbe
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati srednja vrijednost sume zaokružena na dvije decimale.
c) Iz pogleda kreiranog pod a) dati pregled zapisa čija je suma veća od prosječne sume. Osim kolona iz pogleda, potrebno je prikazati razliku sume i srednje vrijednosti.
Razliku zaokružiti na dvije decimale.
*/
create view view_suma
as
select np.narudzbaID, sum(np.uk_cijena) as suma
from narudzba_proizvod as np
group by np.narudzbaID

select round(AVG(suma),2)
from view_suma

select narudzbaID,suma, suma-(select round(avg(suma),2) from view_suma)
from view_suma
where suma>(select avg(suma) from view_suma)
--15 bodova


-------------------------------------------------------------------
/*
7.
a) U tabeli narudzba dodati kolonu evid_br, 30 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone evid_br na sljedeći način:
	- ako u datumu isporuke nije unijeta vrijednost, evid_br se dobija generisanjem slučajnog niza znakova
	- ako je u datumu isporuke unijeta vrijednost, evid_br se dobija spajanjem datum narudžbe i datuma isprouke uz umetanje donje crte između datuma
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/

alter table narudzbe
add  evid_br nvarchar(30)

create procedure proc_evid_br
as
begin
	update narudzbe
	set evid_br =left(newid(),30)
	where dtm_isporuke is null
	update narudzbe
	set evid_br = convert (nvarchar(15), dtm_narudzbe) + '_' +convert (nvarchar (15), dtm_isporuke)
	where dtm_isporuke is not null
end

exec proc_evid_br
select *from narudzbe
-------------------------------------------------------------------
/*
8. Kreirati proceduru kojom će se dobiti pregled sljedećih kolona:
	- narudzbaID,
	- klijent_naziv,
	- proizvodID,
	- kateg_naziv,
	- dobavljac_naziv
Uslov je da se dohvate samo oni zapisi u kojima naziv kategorije sadrži samo 1 riječ.
Pokrenuti proceduru.
*/
create procedure proc_kateg_rijec
as
begin
	select n.narudzbaID,n.klijent_naziv,np.proizvodID,P.kateg_naziv,P.dobavljac_naziv
	from narudzbe as n inner join narudzba_proizvod as np
	on n.narudzbaID=np.narudzbaID
	inner join proizvod as P 
	on P.proizvodID=np.proizvodID
	where CHARINDEX('/', P.kateg_naziv)=0 and CHARINDEX(' ',P.kateg_naziv)=0
end
exec proc_kateg_rijec
--10 bodova

-------------------------------------------------------------------
/*
9.
U tabeli proizvod izvršiti update kolone dobavljac_web tako da se iz kolone dobavljac_naziv uzme prva riječ, a zatim se formira web adresa u formi www.prva_rijec.com. Update izvršiti pomoću dva upita, vodeći računa o broju riječi u nazivu. 
*/

update proizvod
set dobavljac_web = 'www.'+ dobavljac_naziv +'.com'
where (charindex (' ', dobavljac_naziv)-1) < 0

update proizvod
set dobavljac_web='www'+left (dobavljac_naziv, (charindex (' ', dobavljac_naziv)-1))+'.com'
where (charindex (' ', dobavljac_naziv)-1) >= 0

select *from proizvod
-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/

BACKUP DATABASE ispit5_9
TO DISK = 'ispit5_9.bak'

create procedure proc_brisanje
as
begin
	drop view view_kolicina, view_suma
	drop procedure proc_br_kat_naziv, proc_evid_br, proc_kateg_rijec, proc_kolicina
end
exec proc_brisanje
