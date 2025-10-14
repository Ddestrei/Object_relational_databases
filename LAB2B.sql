create table Province(
    ProvinceID int not null primary key,
    Name_p varchar2(30) not null,
    Active_p number(1) default 1 not null 
)
--drop table City

create table City(
    CityID int not null primary key,
    Name_c varchar2(30) not null,
    ProvinceID int,
    constraint key_province foreign key (ProvinceID) references Province(ProvinceID)
        on delete set NULL
)

--drop table Clients
drop table Clients
create table Clients(
    ClientID int not null primary key,
    Second_name varchar2(30) not null,
    First_name varchar2(20) not null,
    PESEL varchar2(11) UNIQUE,
    Birthdate date null,
    Hire_date date default sysdate,
    Salary decimal default 0 CHECK(Salary>=0) not null,
    Year_salary generated always as (Salary*12) virtual,
    Street varchar2(20) null,
    Phone_number varchar2(20) null,
    Apartment_number integer null,
    CityID int,
    constraint key_city foreign key (CityID) references City(CityID)
        on delete set NULL,
    Age number,
    constraint check_date check(Birthdate < Hire_date),
    constraint check_age check(Age >= 18)
)



create or replace trigger count_client_age 
before insert or update on Clients
for each row
begin
    if :new.Birthdate is not null then
        :new.Age := FLOOR(MONTHS_BETWEEN(SYSDATE, :NEW.birthdate) / 12);
    else 
        :new.Age := null;
    end if;
end;
/

insert into Province(ProvinceID, Name_p, Active_p) values(1,'Mazowsze',1);
insert into Province(ProvinceID, Name_p, Active_p) values(2,'Łódzkie',1);
insert into Province(ProvinceID, Name_p, Active_p) values(3,'Wielkopolska',1);


insert into City(CityID, Name_c, ProvinceID) values(1,'Warszawa','1');
insert into City(CityID, Name_c, ProvinceID) values(2,'Łódź','2');
insert into City(CityID, Name_c, ProvinceID) values(3,'Poznań','3');
commit;
select * from City

select * from Province

insert into Clients(ClientID, Second_name, First_name, PESEL, Birthdate, 
    Hire_date, Salary, Street, Phone_number, Apartment_number, CityID) values
    (1, 'Kowalski', 'Andrzej', '12345678904', to_date('1990-06-14','yyyy-mm-dd'),
    to_date('2005-06-14','yyyy-mm-dd'), 5000,'Owocowa','123456789',20,1);

insert into Clients(ClientID, Second_name, First_name, PESEL, Birthdate, 
    Hire_date, Salary, Street, Phone_number, Apartment_number, CityID) values
    (2, 'Filipiak', 'Piotrek', '09876543216', to_date('1992-06-14','yyyy-mm-dd'),
    to_date('2003-06-14','yyyy-mm-dd'), 6000,'Bananowa','987654321',34,2);

insert into Clients(ClientID, Second_name, First_name, PESEL, Birthdate, 
    Hire_date, Salary, Street, Phone_number, Apartment_number, CityID) values
    (3, 'Ziera', 'Mirosław', '12365478900', to_date('1999-06-14','yyyy-mm-dd'),
    to_date('2010-06-14','yyyy-mm-dd'), 4500,'Truskawkowa','987456321',65,3)




select * from Clients

commit;

--1
alter table Province add Country varchar2(20) null
select * from Province
--2
update Province set Country = 'Polska' where Country is Null
alter table Province modify Country varchar(20) default 'Polska' not null 
--3
update Province set Country = substr(Country, 1,5) where length(Country) > 5
alter table Province modify Country varchar2(6) 
--4
alter table Province modify Country varchar2(35) 
--5
alter table Province rename column Active_p to Active_p_new
--6
alter table Clients disable constraint check_date
alter table Clients enable constraint check_date
--7
comment on table City is 'Przechowuje miasta z których pochodzą klięci'
select * from City
comment on column City.CityID is 'Przechowuje id miasta z których pochodzą klięci'
comment on column City.Name_c is 'Przechowuje nazwę miasta z których pochodzą klięci'
comment on column City.ProvinceID is 'Przechowuje id województwa w którym jest miasto'
--8
alter table City drop constraint key_province 
alter table City add constraint key_province foreign key (ProvinceID) references Province(ProvinceID)
        on delete cascade
alter table Clients drop constraints key_city
alter table Clients add constraints key_city foreign key (CityID) references City(CityID)
        on delete cascade
delete from Province where ProvinceID = 1
select * from City
select * from Clients
commit;
--9
create view view_clients as select Clients.Second_name, Clients.age, 
Clients.Year_salary, City.name_c, Province.name_p from Clients 
join City on Clients.CityID = City.CityId join Province on 
City.ProvinceId = Province.ProvinceID 
--10
SELECT table_name FROM user_tables ORDER BY table_name;
SELECT view_name FROM user_views ORDER BY view_name;
SELECT column_name, data_type, data_length, nullable FROM user_tab_columns
WHERE table_name = 'CLIENTS'
ORDER BY column_id;

SELECT constraint_name, constraint_type, search_condition, r_constraint_name
FROM user_constraints
WHERE table_name = 'CLIENTS'
ORDER BY constraint_name;
--11
alter table Clients rename to Clients1
--12
drop table Province1
create table Province1(
    ProvinceID int not null primary key,
    Active_p_new number(1) default 1 not null, 
    Name_p varchar2(30) not null
)
insert into Province1(ProvinceID, Active_p_new, Name_p)
select ProvinceID, Active_p_new, Name_p from Province
--13
--Kod znajdował by się w tablei Clients