--1. Wyświetlić nazwiska pracowników oraz ich zawód:
    
select EMP.ENAME, JOB from EMP 

--
--2. Wyświetlić pierwsze 3 rekordy z tabeli emp;

select * from EMP FETCH FIRST 3 rows only

--
--3.  Wyświetlić pierwsze uporządkowane po nazwisku 3 rekordy z tabeli emp;
--
select * from emp order by ename fetch first 3 rows only

--4.  Wybierz z tabeli emp wszystkie wzajemnie różne kombinacje numeru departamentu i stanowiska pracy:
--

select * from emp

select deptno, job, count(ename) from emp group by deptno, job 

--5.  Wybierz nazwiska i pensje wszystkich pracowników których nazwiska zaczynają się na literę S i s oraz trzecią literę i
--
select ename, sal from emp WHERE (ename LIKE 'S_I%' OR ename LIKE 's_i%');

--6.  Wybierz nazwiska i wartości zarobków wszystkich pracowników łącznie z obliczeniem prowizji od początku roku (POLE COMM)
--

select * from emp

select extract(month from sysdate)*sal+comm, ename from emp where comm is not null
union all
select extract(month from sysdate)*sal, ename from emp where comm is null

--7. Podaj datę zegara systemowego
--
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') AS data_i_godzina
FROM dual;

--8. Do daty zegara systemowego dodaj 3 dni
SELECT TO_CHAR(SYSDATE + 3, 'DD-MON-YYYY HH24:MI:SS') AS data_i_godzina
FROM dual;

--9. Do daty zegara systemowego dodaj 3 godziny
--
SELECT TO_CHAR(SYSDATE + (3/24), 'DD-MON-YYYY HH24:MI:SS') AS data_i_godzina
FROM dual;

--10. Ile dni upłynęło od Twoich narodzin?
--

SELECT TRUNC(SYSDATE - DATE '2004-04-17') AS dni_od_urodzin
FROM dual;

--11. Ile dni pozostało do Twoich urodzin?