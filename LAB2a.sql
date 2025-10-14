--1
select  ename,
    case 
        when sal < 1000 then 'Niska pensja'  
        when sal >= 1000 and sal <= 2000 then 'Średnia pensja'  
        when sal > 2000 then 'Wysoka pensja'  
        when sal is null then 'brak wartości'
    end 
from emp
--2
select ename, nvl(comm,0)  from emp
--3
select * from emp order by comm nulls first
--4
select user, uid from dual
select to_char(sysdate, 'dd-mm-yyyy HH24-MI-SS') from dual
--5
select to_date('01-30-2017', 'MM-DD-YYYY') from dual
--6
select hiredate from emp order by hiredate fetch first 1 rows only;
select hiredate from emp order by hiredate desc fetch first 1 rows only;

select MONTHS_BETWEEN((select hiredate from emp order by hiredate desc fetch first 1 rows only) , 
(select hiredate from emp order by hiredate fetch first 1 rows only)) as Months from dual
--7
SELECT LAST_DAY(SYSDATE) AS last_day_of_month
FROM dual;
--8
SELECT LAST_DAY(TO_DATE('2020-02-01', 'YYYY-MM-DD')) - TO_DATE('2020-02-01', 'YYYY-MM-DD') + 1 AS dni_w_miesiacu
FROM dual;
--9 
select ROUND(ADD_MONTHS(sysdate, 50),'year') from dual    
--10
ALTER SESSION SET NLS_LANGUAGE = 'POLISH';
SELECT TO_CHAR(TO_DATE('31-12-2025', 'DD-MM-YYYY'), 'DAY', 'NLS_DATE_LANGUAGE=POLISH') AS dzien_tygodnia
FROM dual;
--11
select add_months(sysdate,3) from dual
--12
SELECT SYSDATE + 3 - (1/24) AS now_plus_3_days_minus_1_hour
FROM dual;
--13
select to_char(round(avg(sal),2),'0000.00') from emp
--14 
select min(sal) from emp where job = 'MANAGER'
--15
select count(empno) from emp left join dept on dept.deptno = emp.deptno where dept.dname = 'ACCOUNTING' 
--16
select EMPNO as ID, Hiredate from emp;

select extract(Year from hiredate) as rok, extract(month from hiredate) as miesiac, count(*) liczba_pracownikow from emp
group by extract(Year from hiredate), extract(month from hiredate)
order by rok, miesiac;

select extract(Year from hiredate) as rok, extract(month from hiredate) as miesiac, count(*) liczba_pracownikow from emp
group by rollup(extract(Year from hiredate), extract(month from hiredate))
order by rok, miesiac;

select extract(Year from hiredate) as rok, extract(month from hiredate) as miesiac, count(*) liczba_pracownikow from emp
group by cube(extract(Year from hiredate), extract(month from hiredate))
order by rok, miesiac;
--17
select 
    extract(year from hiredate) as rok,
    count(decode(extract(month from hiredate), 1, 1))  as styczen,
    count(decode(extract(month from hiredate), 2, 1))  as luty,
    count(decode(extract(month from hiredate), 3, 1))  as marzec,
    count(decode(extract(month from hiredate), 4, 1))  as kwiecien,
    count(decode(extract(month from hiredate), 5, 1))  as maj,
    count(decode(extract(month from hiredate), 6, 1))  as czerwiec,
    count(decode(extract(month from hiredate), 7, 1))  as lipiec,
    count(decode(extract(month from hiredate), 8, 1))  as sierpien,
    count(decode(extract(month from hiredate), 9, 1))  as wrzesien,
    count(decode(extract(month from hiredate), 10, 1)) as pazdziernik,
    count(decode(extract(month from hiredate), 11, 1)) as listopad,
    count(decode(extract(month from hiredate), 12, 1)) as grudzien
from emp
group by extract(year from hiredate)
order by rok;
--18
select t.nazwa, avg(t.sallary) from (
select dept.dname as nazwa, emp.sal as sallary from emp natural join dept 
) t group by t.nazwa
--19
select job, sal from emp where sal = (select max(emp.sal) as max_sal from emp where job != 'CLERK')
--20 
select job, deptno, min(sal) from emp group by job, deptno
--21
select  deptno,avg(sal) from emp group by deptno
--22
select job, avg(sal) from emp group by job having avg(sal)> 2000
--23
select deptno,max(sal) - min(sal) from emp group by deptno
--24
select ename, t.empno, t.sal from emp join (select empno, sal from emp where job = 'MANAGER') t on t.empno = emp.mgr
where emp.sal > t.sal
--25
select t.nazwa, avg(t.sallary) from (
select dept.dname as nazwa, emp.sal as sallary from emp natural join dept 
) t group by t.nazwa
--26
select ename, sal, (select max(sal) from emp) as Salary_max from emp;
--27
select ename from emp where sal > (select avg(sal) from emp)
--28
select * from emp where ename like 'SMITH'
--29
SELECT ename FROM emp ORDER BY NLSSORT(imie, 'NLS_SORT=POLISH') DESC; 
ALTER SESSION SET NLS_SORT = Polish;
--30 
INSERT INTO emp (empno, ename, deptno, sal, hiredate) VALUES (101,'Lukasinski',10, 2850, to_date('01-30-
2014','mm-dd-yy')); COMMIT; 
select emp.ename,t.max_sal from emp join 
(
select max(sal) max_sal, deptno from emp group by deptno 
) t on emp.deptno = t.deptno where emp.sal = t.max_sal
--31
select * from emp where sal > any (select sal from emp where deptno = 10) and deptno != 10
--32 
select * from emp where sal > all (select sal from emp where deptno = 30) and deptno != 30
--33
select job from emp group by job having avg(sal) > (
select avg(sal) from emp where job = 'MANAGER'
)
--34 
select job,avg(sal) avg_sal from emp group by job order by avg(sal) fetch first 1 rows only 
--35
select * from emp join (
select job, avg(sal) avg_sal from emp group by job
) t on t.job = emp.job where emp.sal < t.avg_sal
--36
select * from emp e where exists(select 1 from emp m where e.empno = m.mgr)
--37
select * from dept d where not exists(select 1 from emp e where d.deptno = e.deptno) 



