set serveroutput on
BEGIN
    -- Dodajemy usługi
    Add_Service('Strzyżenie brody', 50, 20);
    Add_Service('Combo (Włosy + Broda)', 120, 60);

    -- Dodajemy pracownika (ID nada się samo, PESEL zostanie sprawdzony)
END;

BEGIN
    -- Dodajemy pracownika (ID nada się samo, PESEL zostanie sprawdzony)
    Add_Employee('Robert', 'Barber', SYSDATE, 'Master', '91010245833', 4500, 500);
    Add_Employee('Andrzej', 'Adud', SYSDATE, 'Barber', '04302257391', 4900, 0);
END;

select * from employees_tab;
select * from services_tab;

BEGIN
    -- Ustawiamy pracę dla Roberta (ID 1) na jutro
    Add_Work_Schedule(4, 
        TO_DATE('2026-01-20', 'YYYY-MM-DD'),
        TO_DATE('2026-01-20 08:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-01-20 16:00', 'YYYY-MM-DD HH24:MI')
    );
    Add_Work_Schedule(4, 
        TO_DATE('2026-01-21', 'YYYY-MM-DD'),
        TO_DATE('2026-01-21 08:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-01-21 16:00', 'YYYY-MM-DD HH24:MI')
    );
    Add_Work_Schedule(4, 
        TO_DATE('2026-01-22', 'YYYY-MM-DD'),
        TO_DATE('2026-01-22 08:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-01-22 16:00', 'YYYY-MM-DD HH24:MI')
    );
    Add_Work_Schedule(4, 
        TO_DATE('2026-01-23', 'YYYY-MM-DD'),
        TO_DATE('2026-01-23 08:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-01-23 16:00', 'YYYY-MM-DD HH24:MI')
    );
    Add_Work_Schedule(5, 
        TO_DATE('2026-01-21', 'YYYY-MM-DD'),
        TO_DATE('2026-01-21 08:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-01-21 16:00', 'YYYY-MM-DD HH24:MI')
    );
    Add_Work_Schedule(5, 
        TO_DATE('2026-01-22', 'YYYY-MM-DD'),
        TO_DATE('2026-01-22 08:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-01-22 16:00', 'YYYY-MM-DD HH24:MI')
    );
    Add_Work_Schedule(5, 
        TO_DATE('2026-01-23', 'YYYY-MM-DD'),
        TO_DATE('2026-01-23 08:00', 'YYYY-MM-DD HH24:MI'),
        TO_DATE('2026-01-23 16:00', 'YYYY-MM-DD HH24:MI')
    );
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Rozpoczęto dodawanie klientów ---');

    -- Klient 1: Poprawny
    Add_New_Customer('Marek', 'Kowalski', '601202303', 'm.kowalski@gmail.com', 'M');

    -- Klient 2: Poprawny
    Add_New_Customer('Katarzyna', 'Nowak', '505404303', 'kasia.nowak@poczta.pl', 'F');

    -- Klient 3: Poprawny
    Add_New_Customer('Piotr', 'Wisniewski', '707808909', 'p.wisnia@firmowy.pl', 'M');

    -- Klient 4: Poprawny
    Add_New_Customer('Magdalena', 'Wójcik', '888777666', 'magda.wojcik@wp.pl', 'F');

    -- Klient 5: Poprawny
    Add_New_Customer('Tomasz', 'Zajac', '515215315', 'tomek.zajac@interia.pl', 'M');

    -- TESTY WALIDACJI (zostaną wyłapane przez Twoją procedurę/triggery):
    
    DBMS_OUTPUT.PUT_LINE('--- Testy walidacji (spodziewane komunikaty o błędach) ---');

    -- Test: Powtórzony e-mail (Marek Kowalski już jest)
    Add_New_Customer('Jan', 'Testowy', '111222333', 'm.kowalski@gmail.com', 'M');

    -- Test: Błędny format e-maila (zablokuje trigger lub funkcja)
    Add_New_Customer('Błędny', 'Email', '000000000', 'zly_adres_at_domena.pl', 'M');

    -- Test: Powtórzony numer telefonu
    Add_New_Customer('Anna', 'Duplikat', '601202303', 'a.duplikat@o2.pl', 'F');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('--- Zakończono dodawanie klientów ---');
END;

DECLARE
    v_uslugi T_Service_List := T_Service_List(T_Service(1, 'Combo', 120, 60));
    v_uslugi1 T_Service_List := T_Service_List(T_Service(1, 'Combo', 120, 60));
    v_uslugi2 T_Service_List := T_Service_List(T_Service(1, 'Combo', 70, 60));
BEGIN
    -- Próba zapisu klienta na 09:00
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-20 09:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 4,
        p_customer_id  => 1,
        p_services     => v_uslugi,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-20 12:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 4,
        p_customer_id  => 1,
        p_services     => v_uslugi,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-20 15:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 4,
        p_customer_id  => 1,
        p_services     => v_uslugi1,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-21 8:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 4,
        p_customer_id  => 1,
        p_services     => v_uslugi1,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-21 11:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 4,
        p_customer_id  => 1,
        p_services     => v_uslugi1,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-21 14:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 4,
        p_customer_id  => 1,
        p_services     => v_uslugi1,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-20 15:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 5,
        p_customer_id  => 1,
        p_services     => v_uslugi2,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-21 8:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 5,
        p_customer_id  => 1,
        p_services     => v_uslugi2,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-21 11:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 5,
        p_customer_id  => 1,
        p_services     => v_uslugi2,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-21 14:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 5,
        p_customer_id  => 1,
        p_services     => v_uslugi2,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-22 12:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 5,
        p_customer_id  => 1,
        p_services     => v_uslugi,
        p_duration_min => 60
    );
    Create_Appointment(
        p_order_time   => TO_DATE('2026-01-22 14:00', 'YYYY-MM-DD HH24:MI'),
        p_employee_id  => 5,
        p_customer_id  => 1,
        p_services     => v_uslugi,
        p_duration_min => 60
    );
END;

begin
    Complete_Order(p_order_id => 2);
    Complete_Order(p_order_id => 3);
    Complete_Order(p_order_id => 4);
    Complete_Order(p_order_id => 5);
    Complete_Order(p_order_id => 6);
    Complete_Order(p_order_id => 7);
    Complete_Order(p_order_id => 8);
    Complete_Order(p_order_id => 9);
    Complete_Order(p_order_id => 10);
end;

select * from Orders_tab;

BEGIN
    Add_Hair_Salon('Diamond Cut', 'Jan Kowalski');
END;

select * from Salons_tab;

BEGIN
    Add_Branch('ul. Marszałkowska 10, Warszawa', '221002030');
    Add_Branch('ul. Piotrkowska 50, Łódź', '426007080');
END;

select * from Branches_tab;

BEGIN
    Assign_Employee_To_Branch(p_branch_id => 1, p_employee_id => 5);
    COMMIT;
END;

BEGIN
    -- Zakładamy, że wywołałeś wcześniej Add_Hair_Salon('Diamond Cut', 'Jan Kowalski')
    -- oraz Add_Branch('ul. Marszałkowska 10, Warszawa', '221002030')
    
    Link_Branch_To_Salon('Diamond Cut', 1);
END;

SELECT 
    s.name AS nazwa_salonu,
    DEREF(b.column_value).branch_id AS id_oddzialu,
    DEREF(b.column_value).address AS adres_oddzialu
FROM Salons_Tab s, TABLE(s.branches) b
WHERE s.name = 'Diamond Cut';

BEGIN
    Add_Equipment('Nożyczki Jaguar Silver', 5, 320.00);
    Add_Equipment('Maszynka Wahl Senior', 3, 650.00);
    Add_Equipment('Zestaw grzebieni antystatycznych', 10, 85.50);
    Add_Equipment('Peleryna fryzjerska czarna', 15, 45.00);
    
    COMMIT; -- Zatwierdzenie zmian w bazie
END;

select * from branches_tab;
select * from Equipment_Tab;

BEGIN
    Add_Equipment_To_Branch(1, 2);
END;

SELECT 
    b.address, 
    inv.name AS nazwa_sprzetu, 
    inv.quantity AS ilosc, 
    inv.price_per_unit AS cena
FROM Branches_Tab b, 
     TABLE(b.inventory) inv
WHERE b.branch_id = 1;

DECLARE
    v_zarobek NUMBER;
    v_emp_id  INTEGER := 5;
    v_data    VARCHAR2(7) := '01-2026';
BEGIN
    v_zarobek := Get_Employee_Monthly_Revenue(v_emp_id, v_data);
    
    DBMS_OUTPUT.PUT_LINE('Pracownik ID ' || v_emp_id || 
                         ' wygenerował w miesiącu ' || v_data || 
                         ' przychód w wysokości: ' || v_zarobek || ' zł.');
END;

DECLARE
    v_branch_id INTEGER := 1;
    v_period    VARCHAR2(7) := '01-2026';
    v_result    NUMBER;
BEGIN
    v_result := Get_Branch_Monthly_Revenue(v_branch_id, v_period);
    
    DBMS_OUTPUT.PUT_LINE('--- RAPORT MIESIĘCZNY ODDZIAŁU ---');
    DBMS_OUTPUT.PUT_LINE('Oddział ID: ' || v_branch_id);
    DBMS_OUTPUT.PUT_LINE('Okres:      ' || v_period);
    DBMS_OUTPUT.PUT_LINE('Przychód:   ' || v_result || ' zł');
END;





