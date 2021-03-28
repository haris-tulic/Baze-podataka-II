
/*
1.
a) Kreirati bazu pod vlastitim brojem indeksa.
*/
create database grupaB
use grupaB


/* 
b) Kreiranje tabela.
Prilikom kreiranja tabela voditi računa o odnosima između tabela.
I. Kreirati tabelu produkt sljedeće strukture:
	- produktID, cjelobrojna varijabla, primarni ključ
	- jed_cijena, novčana varijabla
	- kateg_naziv, 15 unicode karaktera
	- mj_jedinica, 20 unicode karaktera
	- dobavljac_naziv, 40 unicode karaktera
	- dobavljac_post_br, 10 unicode karaktera
*/
create table produkt(
produktID int constraint PK_produkt primary key(produktID),
jed_cijena money,
kateg_naziv nvarchar(15),
mj_jedinica nvarchar(20),
dobavljac_naziv nvarchar(40),
dobavljac_post_br nvarchar(10)
)

/*
II. Kreirati tabelu narudzba sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, primarni ključ
	- dtm_narudzbe, datumska varijabla za unos samo datuma
	- dtm_isporuke, datumska varijabla za unos samo datuma
	- grad_isporuke, 15 unicode karaktera
	- klijentID, 5 unicode karaktera
	- klijent_naziv, 40 unicode karaktera
	- prevoznik_naziv, 40 unicode karaktera
*/
create table narudzba(
narudzbaID int constraint PK_narudzba primary key(narudzbaID),
dtm_narudzbe date,
dtm_isporuke date,
grad_isporuke nvarchar(15),
klijentID nvarchar(5),
klijent_naziv nvarchar(40),
prevoznik_naziv nvarchar(40)
)

/*
III. Kreirati tabelu narudzba_produkt sljedeće strukture:
	- narudzbaID, cjelobrojna varijabla, obavezan unos
	- produktID, cjelobrojna varijabla, obavezan unos
	- uk_cijena, novčana varijabla
*/
create table narudzba_produkt(
narudzbaID int not null,
produktID int not null,
uk_cijena money,
constraint PK_narudba_produkt primary key(narudzbaID,produktID),
constraint FK_narudzba foreign key(narudzbaID) references narudzba(narudzbaID),
constraint FK_produkt foreign key(produktID) references produkt (produktID)
)
--10 bodova



----------------------------------------------------------------------------------------------------------------------------
/*
2. Import podataka
a) Iz tabela Categories, Product i Suppliers baze Northwind u tabelu produkt importovati podatke prema pravilu:
	- ProductID -> produktID
	- QuantityPerUnit -> mj_jedinica
	- UnitPrice -> jed_cijena
	- CategoryName -> kateg_naziv
	- CompanyName -> dobavljac_naziv
	- PostalCode -> dobavljac_post_br
*/
insert into produkt
select P.ProductID,P.UnitPrice,C.CategoryName,P.QuantityPerUnit,S.CompanyName,S.PostalCode
from NORTHWND.dbo.Categories as C inner join NORTHWND.dbo.Products as P 
on C.CategoryID=P.CategoryID
inner join NORTHWND.dbo.Suppliers as S 
on S.SupplierID=P.SupplierID

/*
a) Iz tabela Customers, Orders i Shipers baze Northwind u tabelu narudzba importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- OrderDate -> dtm_narudzbe
	- ShippedDate -> dtm_isporuke
	- ShipCity -> grad_isporuke
	- CustomerID -> klijentID
	- CompanyName -> klijent_naziv
	- CompanyName -> prevoznik_naziv
*/
insert into narudzba
select O.OrderID,O.OrderDate,O.ShippedDate,O.ShipCity,C.CustomerID,C.CompanyName,S.CompanyName
from NORTHWND.dbo.Orders as O
inner join NORTHWND.dbo.Customers as C  on O.CustomerID=C.CustomerID
inner join NORTHWND.dbo.Shippers as S
on O.ShipVia=S.ShipperID

/*
c) Iz tabele Order Details baze Northwind u tabelu narudzba_produkt importovati podatke prema pravilu:
	- OrderID -> narudzbaID
	- ProductID -> produktID
	- uk_cijena <- produkt jedinične cijene i količine
uz uslov da je odobren popust 5% na produkt.
*/
insert into narudzba_produkt
select OD.OrderID,OD.ProductID,OD.UnitPrice*OD.Quantity
from NORTHWND.dbo.[Order Details] as OD
where Discount=0.05
--10 bodova


----------------------------------------------------------------------------------------------------------------------------
/*
3. 
a) Koristeći tabele narudzba i narudzba_produkt kreirati pogled view_uk_cijena koji će imati strukturu:
	- narudzbaID
	- klijentID
	- uk_cijena_cijeli_dio
	- uk_cijena_feninzi - prikazati kao cijeli broj  
Obavezno pregledati sadržaj pogleda.
b) Koristeći pogled view_uk_cijena kreirati tabelu nova_uk_cijena uz uslov da se preuzmu samo oni zapisi u kojima su feninzi veći od 49. U tabeli trebaju biti sve kolone iz pogleda, te nakon njih kolona uk_cijena_nova u kojoj će ukupna cijena biti zaokružena na veću vrijednost. Npr. uk_cijena = 10, feninzi = 90 -> uk_cijena_nova = 11
*/

create view view_uk_cijena
as
select n.narudzbaID,n.klijentID,floor (np.uk_cijena) as uk_cijena_cijeli_dio,right (np.uk_cijena,2) as uk_cijena_feninzi
from narudzba as n
inner join narudzba_produkt as np on n.narudzbaID=np.narudzbaID

select *from view_uk_cijena

select narudzbaID, klijentID, uk_cijena_cijeli_dio, uk_cijena_feninzi, uk_cijena_cijeli_dio + 1 as uk_cijena_nova into nova_uk_cijena
from view_uk_cijena
where uk_cijena_feninzi > 49

select * from nova_uk_cijena

----------------------------------------------------------------------------------------------------------------------------
/*
4. 
Koristeći tabelu uk_cijena_nova kreiranu u 3. zadatku kreirati proceduru tako da je prilikom izvršavanja moguće unijeti bilo koji broj parametara (možemo ostaviti bilo koji parametar bez unijete vrijednosti). Proceduru pokrenuti za sljedeće vrijednosti varijabli:
1. narudzbaID - 10730
2. klijentID  - ERNSH
*/

create procedure proc_uk_cijena
(
@narudzbaID int = NULL,
	@klijentID nvarchar (5) = NULL,
	@uk_cijena_cijeli_dio decimal (5,2) = null,
	@uk_cijena_feninzi decimal (5,2) = null,
	@uk_cijena_nova decimal (5,2) = null
)
as
begin
	select narudzbaID, klijentID, uk_cijena_cijeli_dio, uk_cijena_feninzi,uk_cijena_nova  
	from nova_uk_cijena
	where narudzbaID=@narudzbaID or
	klijentID=@klijentID or
		  uk_cijena_cijeli_dio=@uk_cijena_cijeli_dio or
		  uk_cijena_feninzi=@uk_cijena_feninzi or
		  uk_cijena_nova=@uk_cijena_nova
end

exec proc_uk_cijena @narudzbaID=10730
/*
narudzbaID  klijentID uk_cijena_cijeli_dio  uk_cijena_feninzi     uk_cijena_nova
----------- --------- --------------------- --------------------- ---------------------
10730       BONAP     261.00                75.00                 262.00
10730       BONAP     37.00                 50.00                 38.00
10730       BONAP     210.00                50.00                 211.00
*/

exec proc_uk_cijena @klijentID=ERNSH
--2
/*
narudzbaID  klijentID uk_cijena_cijeli_dio  uk_cijena_feninzi     uk_cijena_nova
----------- --------- --------------------- --------------------- ---------------------
10351       ERNSH     1193.00               50.00                 1194.00
10776       ERNSH     256.00                50.00                 257.00
*/
--10 bodova




----------------------------------------------------------------------------------------------------------------------------
/*
5.
Koristeći tabelu produkt kreirati proceduru proc_post_br koja će prebrojati zapise u kojima poštanski broj dobavljača počinje cifrom. 
Potrebno je dati prikaz poštanskog broja i ukupnog broja zapisa po poštanskom broju. Nakon kreiranja pokrenuti proceduru.
*/

create procedure proc_post_br
as
begin
	select dobavljac_post_br,count(dobavljac_post_br) as ukupno
	from produkt
	where left (dobavljac_post_br,1) like '[0-9]'
	group by dobavljac_post_br
end
exec proc_post_br
/*
dobavljac_post_br broj_po_post_br
----------------- ---------------
02134             2
0512              3
100               3
10785             3
1320              3
2042              3
27478             1
2800              2
3058              5
33007             2
48100             3
48104             3
53120             3
5442              1
545               3
60439             5
70117             4
71300             1
74000             2
75004             2
84100             2
97101             3
9999 ZZ           2
*/
--5 bodova


-------------------------------------------------------------------
/*
6.
a) Iz tabele narudzba kreirati pogled view_prebrojano sljedeće strukture:
	- klijent_naziv
	- prebrojano - ukupan broj narudžbi po nazivu klijent
Obavezno napisati naredbu za pregled sadržaja pogleda.
b) Napisati naredbu kojom će se prikazati maksimalna vrijednost kolone prebrojano.
c) Iz pogleda kreiranog pod a) dati pregled zapisa u kojem će osim kolona iz pogleda prikazati razlika maksimalne vrijednosti i kolone prebrojano uz uslov da se ne prikazuje zapis u kojem se nalazi maksimlana vrijednost.
*/
create view view_prebrojano
as
	select klijent_naziv, count(narudzbaID) as prebrojano
	from narudzba
	group by klijent_naziv

	select *from view_prebrojano

	select max(prebrojano)
	from view_prebrojano

	select klijent_naziv,prebrojano,(select max(prebrojano)from view_prebrojano)-prebrojano as razlika
	from view_prebrojano
	where prebrojano <>(select max(prebrojano) from view_prebrojano)
	order by 2

-------------------------------------------------------------------
/*
7.
a) U tabeli produkt dodati kolonu lozinka, 20 unicode karaktera 
b) Kreirati proceduru kojom će se izvršiti punjenje kolone lozinka na sljedeći način:
	- ako je u dobavljac_post_br podatak sačinjen samo od cifara, lozinka se kreira obrtanjem niza znakova koji se dobiju spajanjem zadnja četiri znaka kolone mj_jedinica i kolone dobavljac_post_br
	- ako podatak u dobavljac_post_br podatak sadrži jedno ili više slova na bilo kojem mjestu, lozinka se kreira obrtanjem slučajno generisanog niza znakova
Nakon kreiranja pokrenuti proceduru.
Obavezno provjeriti sadržaj tabele narudžba.
*/

alter table produkt
add lozinka nvarchar(20)

create procedure proc_lozinka
as
begin
	update produkt
	set lozinka= REVERSE(right(mj_jedinica,4)+ dobavljac_post_br)
	where dobavljac_post_br not like '[A-Z]%' and dobavljac_post_br not like '%[A-Z]%' and dobavljac_post_br not like '%[A-Z]'
	update produkt
	set lozinka=REVERSE(left(newid(),20))
	where  dobavljac_post_br like '[A-Z]%' or dobavljac_post_br like '%[A-Z]%' or dobavljac_post_br  like '%[A-Z]'
end

exec proc_lozinka

select *from produkt
-------------------------------------------------------------------
/*
8. 
a) Kreirati pogled kojim sljedeće strukture:
	- produktID,
	- dobavljac_naziv,
	- grad_isporuke
	- period_do_isporuke koji predstavlja vremenski period od datuma narudžbe do datuma isporuke
Uslov je da se dohvate samo oni zapisi u kojima je narudzba realizirana u okviru 4 sedmice.
Obavezno pregledati sadržaj pogleda.

b) Koristeći pogled view_isporuka kreirati tabelu isporuka u koju će biti smještene sve kolone iz pogleda. 
*/

create view view_isporuka
as
	select produkt.produktID,produkt.dobavljac_naziv,narudzba.grad_isporuke,DATEDIFF(day,narudzba.dtm_narudzbe,dtm_isporuke) as period_do_isporuke
	from produkt inner join narudzba_produkt on produkt.produktID=narudzba_produkt.produktID
	inner join narudzba on narudzba.narudzbaID=narudzba_produkt.narudzbaID
	where DATEDIFF(day,narudzba.dtm_narudzbe,dtm_isporuke)<=28

	select *from view_isporuka

	select *into isporuka
	from view_isporuka
-------------------------------------------------------------------
/*
9.
a) U tabeli isporuka dodati kolonu red_br_sedmice, 10 unicode karaktera.
b) U tabeli isporuka izvršiti update kolone red_br_sedmice ( prva, druga, treca, cetvrta) u zavisnosti od vrijednosti u koloni period_do_isporuke. Pokrenuti proceduru
c) Kreirati pregled kojim će se prebrojati broj zapisa po rednom broju sedmice. Pregled treba da sadrži redni broj sedmice i ukupan broj zapisa po rednom broju.
*/

alter table isporuka
add red_br_sedmice nvarchar(10)

create procedure proc_red_br_sedmice
as
begin
	update isporuka
	set red_br_sedmice='prva'
	where period_do_isporuke<=7
	update isporuka
	set red_br_sedmice='druga'
	where period_do_isporuke between 8 and 14
	update isporuka
	set red_br_sedmice='treca'
	where period_do_isporuke between 15 and 21
	update isporuka
	set red_br_sedmice='cetvrta'
	where period_do_isporuke between 22 and 28
end

exec proc_red_br_sedmice

create view view_pregled
as
select red_br_sedmice,count(red_br_sedmice) as ukupno
from isporuka
group by red_br_sedmice

select *from view_pregled
--4
/*
red_br_sedmice 
-------------- -----------
cetvrta        8
druga          53
prva           108
treca          1
*/

--15 bodova

-------------------------------------------------------------------
/*
10.
a) Kreirati backup baze na default lokaciju.
b) Kreirati proceduru kojom će se u jednom izvršavanju obrisati svi pogledi i procedure u bazi. Pokrenuti proceduru.
*/

backup database 'grupaB'
to disk 'grupaB.bak'

create procedure proc_brisanje
as
begin
drop view view_pregled,view_uk_cijena,view_prebrojano
drop procedure proc_lozinka,proc_post_br,proc_red_br_sedmice,proc_uk_cijena
end
--5 BODOVA
