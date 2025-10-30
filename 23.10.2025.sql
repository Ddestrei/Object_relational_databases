set serveroutput ON

select (trunc(sysdate,'dd') - to_date('2003-01-01', 'yyyy-mm-dd'))*26.66 
    from dual;



declare 
    days_l number := trunc(sysdate,'dd') - to_date('2003-01-01', 'yyyy-mm-dd');
    money number(16,5);
    end_loop number;
begin
    money := 0;
    end_loop := days_l/365;
    for i in 1..end_loop loop
        money := money + 26.66666*365;
        money := money * 1.095;
    end loop;
    dbms_output.put_line('Money: ' || money);
end;

declare 
    days_l number := to_date('2068-01-01', 'yyyy-mm-dd') - to_date('2003-01-01', 'yyyy-mm-dd');
    money number(16,5);
    end_loop number;
begin
    money := 792452.54638;
    end_loop := days_l/365;
    for i in 1..end_loop loop
        money := money * 1.095;
    end loop;
    dbms_output.put_line('Money: ' || money);
end;
    






















