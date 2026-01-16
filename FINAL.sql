-- ==========================================
-- 3. DEFINICJA TYPÓW (TYPES)
-- ==========================================

CREATE OR REPLACE TYPE T_Employee;

-- 1. SERVICE
CREATE OR REPLACE TYPE T_Service AS OBJECT (
    service_id INTEGER,
    name VARCHAR2(100),
    price NUMBER(6,2),
    duration_min NUMBER(6)
);
/
CREATE OR REPLACE TYPE T_Service_List AS TABLE OF T_Service;
/

-- 2. EQUIPMENT
CREATE OR REPLACE TYPE T_Equipment AS OBJECT (
    equipment_id INTEGER,
    name VARCHAR2(100),
    quantity INTEGER,
    price_per_unit NUMBER(7,2),
    MEMBER FUNCTION get_total_value RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY T_Equipment AS
    MEMBER FUNCTION get_total_value RETURN NUMBER IS
    BEGIN
        RETURN self.quantity * self.price_per_unit;
    END;
END;
/
CREATE OR REPLACE TYPE T_Equipment_List AS TABLE OF T_Equipment;
/

-- 3. CUSTOMER
CREATE OR REPLACE TYPE T_Customer AS OBJECT (
    customer_id INTEGER,
    first_name VARCHAR2(30),
    last_name VARCHAR2(30),
    phone_number VARCHAR2(9),
    email VARCHAR2(200),
    gender VARCHAR2(1)
);
/

-- 4. SCHEDULE
CREATE OR REPLACE TYPE T_Schedule AS OBJECT (
    schedule_id INTEGER,
    work_date DATE,
    start_time DATE,
    end_time DATE
);
/
CREATE OR REPLACE TYPE T_Schedule_List AS TABLE OF T_Schedule;
/

-- 5. EMPLOYEE
CREATE OR REPLACE TYPE T_Employee AS OBJECT (
    employee_id INTEGER,
    first_name VARCHAR2(30),
    last_name VARCHAR2(30),
    hire_date DATE,
    qualification_level VARCHAR2(30),
    pesel VARCHAR2(11),
    base_salary NUMBER(6,2),
    bonus NUMBER(6,2),
    work_schedules T_Schedule_List,
    MEMBER FUNCTION get_total_salary RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY T_Employee AS
    MEMBER FUNCTION get_total_salary RETURN NUMBER IS
    BEGIN
        RETURN self.base_salary + NVL(self.bonus, 0);
    END;
END;
/
CREATE OR REPLACE TYPE T_Employee_List AS TABLE OF REF T_Employee;
/

-- 6. ORDER
CREATE OR REPLACE TYPE T_Order AS OBJECT (
    order_id INTEGER,
    order_time DATE,
    status VARCHAR2(30),
    total_cost NUMBER(6,2),
    customer_ref REF T_Customer,
    employee_ref REF T_Employee, -- NOWE POLE: Referencja do pracownika
    services_rendered T_Service_List,
    MEMBER FUNCTION count_services RETURN INTEGER
);
/

CREATE OR REPLACE TYPE BODY T_Order AS
    MEMBER FUNCTION count_services RETURN INTEGER IS
    BEGIN
        RETURN self.services_rendered.COUNT;
    END;
END;
/

CREATE OR REPLACE TYPE T_Order_List AS TABLE OF REF T_Order;
/

-- 7. BRANCH
CREATE OR REPLACE TYPE T_Branch AS OBJECT (
    branch_id INTEGER,
    address VARCHAR2(200),
    phone_number VARCHAR2(9),
    inventory T_Equipment_List,
    employees T_Employee_List
);
/
CREATE OR REPLACE TYPE T_Branch_List AS TABLE OF REF T_Branch;
/

-- 8. HAIR SALON
CREATE OR REPLACE TYPE T_Hair_Salon AS OBJECT (
    name VARCHAR2(30),
    ceo VARCHAR2(100),
    branches T_Branch_List
);
/

-- ==========================================
-- 3. TWORZENIE TABEL (TABLES)
-- ==========================================

-- 1. Tabele niezależne (Słowniki)
CREATE TABLE Services_Tab OF T_Service (service_id PRIMARY KEY);
/
CREATE TABLE Equipment_Tab OF T_Equipment (equipment_id PRIMARY KEY);
/
CREATE TABLE Customers_Tab OF T_Customer (
    customer_id PRIMARY KEY,
    gender CHECK (gender IN ('M', 'F'))
);
/

-- 2. Tabela Pracowników (Musi być przed Orders_Tab ze względu na SCOPE)
CREATE TABLE Employees_Tab OF T_Employee (
    employee_id PRIMARY KEY,
    pesel UNIQUE NOT NULL
) 
NESTED TABLE work_schedules STORE AS Schedules_NT;
/

-- 3. Tabela Zleceń (Z referencjami do Klienta i Pracownika)
CREATE TABLE Orders_Tab OF T_Order (
    order_id PRIMARY KEY,
    customer_ref NOT NULL,
    employee_ref NOT NULL,
    SCOPE FOR (customer_ref) IS Customers_Tab,
    SCOPE FOR (employee_ref) IS Employees_Tab
) 
NESTED TABLE services_rendered STORE AS Rendered_Services_NT;
/

-- 4. Tabela Placówek (Zagnieżdżony sprzęt i lista REFs do pracowników)
CREATE TABLE Branches_Tab OF T_Branch (
    branch_id PRIMARY KEY
) 
NESTED TABLE inventory STORE AS Branch_Inventory_NT,
NESTED TABLE employees STORE AS Branch_Employees_Refs_NT;
/

-- 5. Tabela Salonu (Główny byt - lista REFs do placówek)
CREATE TABLE Salons_Tab OF T_Hair_Salon (
    name PRIMARY KEY
) 
NESTED TABLE branches STORE AS Salon_Branches_Refs_NT;
/
--sekwencje które są wykorzystywane do tworzenia nr id dla wszystkich objektów
CREATE SEQUENCE seq_service_id   START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_equipment_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_customer_id  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_employee_id  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_order_id     START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_branch_id    START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_schedule_id  START WITH 1 INCREMENT BY 1 NOCACHE;

--trigger który dodaje id do tworzonego obiektu Customers
CREATE OR REPLACE TRIGGER trg_auto_customer_id
BEFORE INSERT ON Customers_Tab
FOR EACH ROW
WHEN (NEW.customer_id IS NULL) -- Działa tylko gdy nie podano ID ręcznie
BEGIN
  :NEW.customer_id := seq_customer_id.NEXTVAL;
END;

--trigger który dodaje id do tworzonego obiektu Services
CREATE OR REPLACE TRIGGER trg_auto_service_id
BEFORE INSERT ON Services_Tab
FOR EACH ROW
WHEN (NEW.service_id IS NULL) -- Działa tylko gdy nie podano ID ręcznie
BEGIN
  :NEW.service_id := seq_service_id.NEXTVAL;
END;

--trigger który dodaje id do tworzonego obiektu Equipment
CREATE OR REPLACE TRIGGER trg_auto_equipment_id
BEFORE INSERT ON Equipment_Tab
FOR EACH ROW
WHEN (NEW.equipment_id IS NULL) -- Działa tylko gdy nie podano ID ręcznie
BEGIN
  :NEW.equipment_id := seq_equipment_id.NEXTVAL;
END;

--trigger który dodaje id do tworzonego obiektu Employees
CREATE OR REPLACE TRIGGER trg_auto_employees_id
BEFORE INSERT ON Employees_Tab
FOR EACH ROW
WHEN (NEW.employee_id IS NULL) -- Działa tylko gdy nie podano ID ręcznie
BEGIN
  :NEW.employee_id := seq_employee_id.NEXTVAL;
END;

--trigger który dodaje id do tworzonego obiektu Orders
CREATE OR REPLACE TRIGGER trg_auto_orders_id
BEFORE INSERT ON Orders_Tab
FOR EACH ROW
WHEN (NEW.order_id IS NULL) -- Działa tylko gdy nie podano ID ręcznie
BEGIN
  :NEW.order_id := seq_order_id.NEXTVAL;
END;

--trigger który dodaje id do tworzonego obiektu Branches
CREATE OR REPLACE TRIGGER trg_auto_branches_id
BEFORE INSERT ON Branches_Tab
FOR EACH ROW
WHEN (NEW.branch_id IS NULL) -- Działa tylko gdy nie podano ID ręcznie
BEGIN
  :NEW.branch_id := seq_branch_id.NEXTVAL;
END;

--procedura dodawania solonu 
CREATE OR REPLACE PROCEDURE Add_Hair_Salon (
    p_name IN VARCHAR2,
    p_ceo  IN VARCHAR2
) IS
BEGIN
    -- Wstawiamy nowy obiekt salonu. 
    -- Jako trzeci parametr podajemy pustą kolekcję T_Branch_List(), 
    -- którą później będziemy uzupełniać referencjami do placówek.
    
    INSERT INTO Salons_Tab VALUES (
        T_Hair_Salon(p_name, p_ceo, T_Branch_List())
    );

    DBMS_OUTPUT.PUT_LINE('SUKCES: Utworzono salon: ' || p_name || '. CEO: ' || p_ceo);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Salon o nazwie ' || p_name || ' już istnieje.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('WYSTĄPIŁ BŁĄD: ' || SQLERRM);
END;

--przypisanie brancha do salonu
CREATE OR REPLACE PROCEDURE Link_Branch_To_Salon (
    p_salon_name IN VARCHAR2, -- Nazwa salonu (Klucz główny)
    p_branch_id  IN INTEGER   -- ID placówki, którą chcemy przypisać
) IS
    v_salon_exists  INTEGER;
    v_branch_exists INTEGER;
BEGIN
    -- 1. Sprawdzenie czy salon istnieje
    SELECT COUNT(*) INTO v_salon_exists FROM Salons_Tab WHERE name = p_salon_name;
    -- 2. Sprawdzenie czy placówka istnieje
    SELECT COUNT(*) INTO v_branch_exists FROM Branches_Tab WHERE branch_id = p_branch_id;

    IF v_salon_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Salon o nazwie ' || p_salon_name || ' nie istnieje.');
        RETURN;
    END IF;

    IF v_branch_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Placówka o ID ' || p_branch_id || ' nie istnieje.');
        RETURN;
    END IF;

    -- 3. Dodanie referencji do kolekcji wewnątrz salonu
    INSERT INTO TABLE (
        SELECT s.branches 
        FROM Salons_Tab s 
        WHERE s.name = p_salon_name
    )
    SELECT REF(b) 
    FROM Branches_Tab b 
    WHERE b.branch_id = p_branch_id;

    DBMS_OUTPUT.PUT_LINE('SUKCES: Placówka ID ' || p_branch_id || ' została przypisana do salonu: ' || p_salon_name);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('WYSTĄPIŁ BŁĄD: ' || SQLERRM);
END;
/

--procedura dodawania Branch 
CREATE OR REPLACE PROCEDURE Add_Branch (
    p_address      IN VARCHAR2,
    p_phone_number IN VARCHAR2
) IS
BEGIN
    -- Używamy sekwencji seq_branch_id do nadania unikalnego numeru
    INSERT INTO Branches_Tab VALUES (
        T_Branch(
            null, 
            p_address, 
            p_phone_number, 
            T_Equipment_List(), -- Inicjalizacja pustej listy sprzętu
            T_Employee_List()   -- Inicjalizacja pustej listy referencji do pracowników
        )
    );

    DBMS_OUTPUT.PUT_LINE('SUKCES: Utworzono nową placówkę pod adresem: ' || p_address);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD przy tworzeniu placówki: ' || SQLERRM);
END;
/
--procedura przypisywania pracownika do Branch 
CREATE OR REPLACE PROCEDURE Assign_Employee_To_Branch (
    p_branch_id   IN INTEGER,
    p_employee_id IN INTEGER
) IS
BEGIN
    INSERT INTO TABLE (
        SELECT b.employees FROM Branches_Tab b WHERE b.branch_id = p_branch_id
    )
    SELECT REF(e) FROM Employees_Tab e WHERE e.employee_id = p_employee_id;

    DBMS_OUTPUT.PUT_LINE('Pracownik ID ' || p_employee_id || ' został przypisany do oddziału ' || p_branch_id);
END;

--procedura przypisywania wyposażenia do Branch 
CREATE OR REPLACE PROCEDURE Add_Equipment_To_Branch (
    p_branch_id    IN INTEGER,
    p_equipment_id IN INTEGER
) IS
    v_equipment_obj T_Equipment;
BEGIN
    -- 1. Pobieramy cały obiekt wyposażenia z tabeli słownikowej do zmiennej
    SELECT VALUE(e) INTO v_equipment_obj
    FROM Equipment_Tab e
    WHERE e.equipment_id = p_equipment_id;

    -- 2. Wstawiamy pobrany obiekt do tabeli zagnieżdżonej wybranego oddziału
    INSERT INTO TABLE (
        SELECT b.inventory 
        FROM Branches_Tab b 
        WHERE b.branch_id = p_branch_id
    )
    VALUES (v_equipment_obj);

    DBMS_OUTPUT.PUT_LINE('SUKCES: Sprzęt "' || v_equipment_obj.name || '" został przypisany do oddziału o ID ' || p_branch_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Nie znaleziono oddziału o ID ' || p_branch_id || ' lub sprzętu o ID ' || p_equipment_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('WYSTĄPIŁ BŁĄD: ' || SQLERRM);
END;
--procedura tworząca usługę 
CREATE OR REPLACE PROCEDURE Add_Service (
    p_name         IN VARCHAR2,
    p_price        IN NUMBER,
    p_duration_min IN NUMBER
) IS
BEGIN
    INSERT INTO Services_Tab VALUES (
        T_Service(null, p_name, p_price, p_duration_min)
    );
    DBMS_OUTPUT.PUT_LINE('Dodano usługę: ' || p_name);
END;
--procedura tworząca wyposażenie 
CREATE OR REPLACE PROCEDURE Add_Equipment (
    p_name           IN VARCHAR2,
    p_quantity       IN INTEGER,
    p_price_per_unit IN NUMBER
) IS
BEGIN
    INSERT INTO Equipment_Tab VALUES (
        T_Equipment(null, p_name, p_quantity, p_price_per_unit)
    );
    DBMS_OUTPUT.PUT_LINE('Dodano sprzęt: ' || p_name);
END;
--procedura tworząca pracownika
CREATE OR REPLACE PROCEDURE Add_Employee (
    p_first_name     IN VARCHAR2,
    p_last_name      IN VARCHAR2,
    p_hire_date      IN DATE,
    p_qualification  IN VARCHAR2,
    p_pesel          IN VARCHAR2,
    p_base_salary    IN NUMBER,
    p_bonus          IN NUMBER
) IS
BEGIN
    -- Sprawdzamy PESEL naszą funkcją przed wstawieniem
    IF Is_Valid_Pesel(p_pesel) != 'PRAWIDŁOWY' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Błędny PESEL!');
    END IF;

    INSERT INTO Employees_Tab VALUES (
        T_Employee(null, p_first_name, p_last_name, 
                   p_hire_date, p_qualification, p_pesel, 
                   p_base_salary, p_bonus, T_Schedule_List())
    );
    DBMS_OUTPUT.PUT_LINE('Dodano pracownika: ' || p_first_name || ' ' || p_last_name);
END;
-- funkcja dodaje pracownikowi dzień pracujący
CREATE OR REPLACE PROCEDURE Add_Work_Schedule (
    p_employee_id   IN INTEGER,  -- ID pracownika, któremu dodajemy grafik
    p_work_date     IN DATE,     -- Dzień pracy
    p_start_time    IN DATE,     -- Godzina rozpoczęcia (musi zawierać datę)
    p_end_time      IN DATE      -- Godzina zakończenia (musi zawierać datę)
) IS
BEGIN
    -- Używamy polecenia INSERT INTO TABLE(...) 
    -- Pozwala to na dodanie elementu do tabeli zagnieżdżonej bez nadpisywania całej listy
    
    INSERT INTO TABLE (
        SELECT e.work_schedules 
        FROM Employees_Tab e 
        WHERE e.employee_id = p_employee_id
    )
    VALUES (
        T_Schedule(
            null, 
            TRUNC(p_work_date), 
            p_start_time, 
            p_end_time
        )
    );

    DBMS_OUTPUT.PUT_LINE('SUKCES: Dodano nowy termin do grafiku pracownika o ID: ' || p_employee_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Nie znaleziono pracownika o ID ' || p_employee_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('WYSTĄPIŁ BŁĄD: ' || SQLERRM);
END;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNKCJA SPRAWDZAJĄCA POPRAWNOŚĆ PESELU
CREATE OR REPLACE FUNCTION Is_Valid_Pesel(p_pesel IN VARCHAR2) 
RETURN VARCHAR2 IS
    v_sum NUMBER := 0;
    v_weight NUMBER;
    v_digit NUMBER;
    TYPE t_weights IS TABLE OF NUMBER;
    v_weights t_weights := t_weights(1, 3, 7, 9, 1, 3, 7, 9, 1, 3);
BEGIN
    -- 1. Sprawdzenie długości i czy są same cyfry
    IF p_pesel IS NULL OR NOT REGEXP_LIKE(p_pesel, '^[0-9]{11}$') THEN
        RETURN 'NIEPRAWIDŁOWY (format)';
    END IF;

    -- 2. Obliczanie sumy kontrolnej
    FOR i IN 1..10 LOOP
        v_digit := TO_NUMBER(SUBSTR(p_pesel, i, 1));
        v_sum := v_sum + (v_digit * v_weights(i));
    END LOOP;

    v_sum := MOD(10 - MOD(v_sum, 10), 10);

    -- 3. Porównanie z ostatnią cyfrą PESEL
    IF v_sum = TO_NUMBER(SUBSTR(p_pesel, 11, 1)) THEN
        RETURN 'PRAWIDŁOWY';
    ELSE
        RETURN 'NIEPRAWIDŁOWY (suma kontrolna)';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'BŁĄD PRZETWARZANIA';
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TRIGGER DLA TABLI Employee_Tab PODCZAS DODAWANIA PRACOWNIKA

CREATE OR REPLACE TRIGGER trg_check_pesel_before_ins
BEFORE INSERT OR UPDATE ON Employees_Tab
FOR EACH ROW
BEGIN
    IF Is_Valid_Pesel(:NEW.pesel) != 'PRAWIDŁOWY' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Próba wprowadzenia błędnego numeru PESEL: ' || :NEW.pesel);
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--FUNKCJA SPRAWDZAJĄCA POPRAWNOŚĆ EMAIL

CREATE OR REPLACE FUNCTION Is_Valid_Email(p_email IN VARCHAR2) 
RETURN VARCHAR2 IS
BEGIN
    IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') THEN
        RETURN 'PRAWIDŁOWY';
    ELSE
        RETURN 'NIEPRAWIDŁOWY';
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TRIGGER DLA TABLI Customers_Tab PODCZAS DODAWANIA KLIENTA

CREATE OR REPLACE TRIGGER trg_check_customer_before_ins
BEFORE INSERT OR UPDATE ON Customers_Tab
FOR EACH ROW
BEGIN
    IF is_valid_email(:NEW.email) != 'PRAWIDŁOWY' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Próba wprowadzenia błędnego adres email: ' || :NEW.email);
    END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--PROCEDURA KTÓRA SPRAWDZA CZY W BAZIE NIE ISTNIEJE JUŻ KLIENT KTÓRY MA TAKI SAM EMAIL I NR TELEFONU JEŻELI TAK TO NIE DODAJE NOWEGO KLIENTA. 

CREATE OR REPLACE PROCEDURE Add_New_Customer (
    p_first_name   IN VARCHAR2,
    p_last_name    IN VARCHAR2,
    p_phone        IN VARCHAR2,
    p_email        IN VARCHAR2,
    p_gender       IN VARCHAR2
) IS
    v_count_email  INTEGER;
    v_count_phone  INTEGER;
    e_validation_error EXCEPTION;
BEGIN
    -- 1. Walidacja formatu emaila (używając stworzonej wcześniej funkcji)
    IF Is_Valid_Email(p_email) = 'NIEPRAWIDŁOWY' THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Adres email ' || p_email || ' ma niepoprawny format.');
        RAISE e_validation_error;
    END IF;

    -- 2. Sprawdzenie unikalności adresu Email
    SELECT COUNT(*) INTO v_count_email 
    FROM Customers_Tab 
    WHERE email = p_email;

    IF v_count_email > 0 THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Klient z adresem email ' || p_email || ' już istnieje w bazie.');
        RAISE e_validation_error;
    END IF;

    -- 3. Sprawdzenie unikalności numeru telefonu
    SELECT COUNT(*) INTO v_count_phone 
    FROM Customers_Tab 
    WHERE phone_number = p_phone;

    IF v_count_phone > 0 THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Klient z numerem telefonu ' || p_phone || ' już istnieje w bazie.');
        RAISE e_validation_error;
    END IF;

    -- 4. Wstawienie nowego obiektu do tabeli
    INSERT INTO Customers_Tab VALUES (
        T_Customer(null, p_first_name, p_last_name, p_phone, p_email, p_gender)
    );

    DBMS_OUTPUT.PUT_LINE('SUKCES: Dodano nowego klienta: ' || p_first_name || ' ' || p_last_name);

EXCEPTION
    WHEN e_validation_error THEN
        -- Logika w przypadku błędów walidacji (nie robimy nic, błąd został wypisany)
        NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('WYSTĄPIŁ NIEOCZEKIWANY BŁĄD: ' || SQLERRM);
END;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--funkcja która przyjmóje datę oraz godzinę zlecenia oraz id pracownika i wymagany czas na wykonanie zlecenia. 
--Zadanie tej funkcji jest sprawdzenie czy pracownik w tym terminie i o tej godzinie ma wolne to zwraca true lub jest zajęty to wtedy false. 
--Jeżeli pracownik nie ma danego terminu w work_schedules to zwraca false. Funkcja powinna też uwzględnić to że każde zlecenie trwa order_time i po każdym zleceniu pracownik ma 10 min wolnego.


CREATE OR REPLACE FUNCTION Is_Employee_Free(
    p_employee_id   IN INTEGER,
    p_start_time    IN DATE,
    p_duration_min  IN INTEGER
) RETURN VARCHAR2 IS
    v_end_time       DATE;
    v_in_schedule    INTEGER;
    v_conflicts      INTEGER;
    v_buffer_min     CONSTANT INTEGER := 10;
BEGIN
    -- 1. Czas końca planowanej usługi (usługa + 10 min przerwy)
    v_end_time := p_start_time + (p_duration_min + v_buffer_min) / 1440;

    -- 2. Czy pracownik ma wtedy grafik?
    SELECT COUNT(*) INTO v_in_schedule
    FROM Employees_Tab e, TABLE(e.work_schedules) s
    WHERE e.employee_id = p_employee_id
      AND p_start_time >= s.start_time
      AND v_end_time <= s.end_time;

    IF v_in_schedule = 0 THEN RETURN 'FALSE'; END IF;

    -- 3. Sprawdzenie konfliktów z sumowaniem czasu usług z kolekcji
    SELECT COUNT(*) INTO v_conflicts
    FROM Orders_Tab o
    WHERE o.employee_ref.employee_id = p_employee_id
      AND (
          -- Pobieramy czas trwania zlecenia sumując czas jego usług
          p_start_time < (o.order_time + ((SELECT SUM(s.duration_min) FROM TABLE(o.services_rendered) s) + v_buffer_min) / 1440)
          AND v_end_time > o.order_time
      );

    IF v_conflicts > 0 THEN RETURN 'FALSE'; ELSE RETURN 'TRUE'; END IF;
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Procedura która będzie maiła za zadanie towrzyć nową wizytę. Przyjmuje ona datę z godziną, usługi jakie będą wykonane, id pracownika którego chcemy przypisać i czas trwania. 
--Procedura ta ma sprawdzić czy dany pracownik może wykonać dane zlecenie. Jeżeli pracownik nie może wykonać danego zlecenie to nie dodaje go a jeżeli może to dodaje. 
--Wyświetla komunikat o tym czy zlecenie zostało zapisane czy nie.

CREATE OR REPLACE PROCEDURE Create_Appointment (
    p_order_time    IN DATE,         -- Data i godzina startu
    p_employee_id   IN INTEGER,      -- ID fryzjera
    p_customer_id   IN INTEGER,      -- ID klienta
    p_services      IN T_Service_List, -- Lista obiektów T_Service
    p_duration_min  IN INTEGER       -- Całkowity czas trwania
) IS
    v_is_free       VARCHAR2(10);
    v_new_order_id  INTEGER;
    v_total_price   NUMBER(6,2) := 0;
    v_emp_ref       REF T_Employee;
    v_cust_ref      REF T_Customer;
BEGIN
    -- 1. Sprawdzenie dostępności pracownika (uwzględnia grafik, zajętość i 10 min przerwy)
    v_is_free := Is_Employee_Free(p_employee_id, p_order_time, p_duration_min);

    IF v_is_free = 'FALSE' THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Pracownik o ID ' || p_employee_id || ' jest zajęty lub nie pracuje w tym terminie.');
        RETURN; -- Przerywamy działanie procedury
    END IF;

    -- 2. Pobranie referencji do pracownika i klienta
    SELECT REF(e) INTO v_emp_ref FROM Employees_Tab e WHERE e.employee_id = p_employee_id;
    SELECT REF(c) INTO v_cust_ref FROM Customers_Tab c WHERE c.customer_id = p_customer_id;

    -- 3. Obliczenie sumarycznej ceny usług z przekazanej listy
    FOR i IN 1..p_services.COUNT LOOP
        v_total_price := v_total_price + p_services(i).price;
    END LOOP;

    -- 4. Wygenerowanie nowego ID zlecenia
    SELECT NVL(MAX(order_id), 0) + 1 INTO v_new_order_id FROM Orders_Tab;

    -- 5. Wstawienie zlecenia
    INSERT INTO Orders_Tab VALUES (
        T_Order(
            v_new_order_id,
            p_order_time,
            'Zaplanowane',
            v_total_price,
            v_cust_ref,
            v_emp_ref,
            p_services
        )
    );

    DBMS_OUTPUT.PUT_LINE('SUKCES: Wizyta została zapisana. Numer zlecenia: ' || v_new_order_id || '. Koszt: ' || v_total_price || ' zł.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Nie znaleziono pracownika lub klienta o podanych ID.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('WYSTĄPIŁ BŁĄD: ' || SQLERRM);
END;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Procedura która ma za zadanie zmeniać status zamówienia z Zaplanowane na wykonane. Oraz zwiększa pracownikowi bonus i 1% wykonanego zlecenia
CREATE OR REPLACE PROCEDURE Complete_Order (
    p_order_id IN INTEGER
) IS
    v_current_status VARCHAR2(30);
    v_order_price    NUMBER(6,2);
    v_emp_ref        REF T_Employee;
    v_bonus_amount   NUMBER(6,2);
BEGIN
    -- 1. Pobranie statusu, ceny zlecenia oraz referencji do pracownika
    SELECT status, total_cost, employee_ref 
    INTO v_current_status, v_order_price, v_emp_ref
    FROM Orders_Tab 
    WHERE order_id = p_order_id;

    -- 2. Logika zmiany statusu i naliczania bonusu
    IF v_current_status = 'Zaplanowane' THEN
        -- A. Aktualizacja statusu zlecenia
        UPDATE Orders_Tab
        SET status = 'Wykonane'
        WHERE order_id = p_order_id;

        -- B. Obliczenie kwoty bonusu (1% ceny zlecenia)
        v_bonus_amount := v_order_price * 0.01;

        -- C. Aktualizacja bonusu bezpośrednio u pracownika przypisanego do zlecenia
        -- Używamy DEREF lub po prostu UPDATE na tabeli Employees_Tab używając REF
        UPDATE Employees_Tab e
        SET e.bonus = NVL(e.bonus, 0) + v_bonus_amount
        WHERE REF(e) = v_emp_ref;
        
        DBMS_OUTPUT.PUT_LINE('SUKCES: Zlecenie nr ' || p_order_id || ' wykonane.');
        DBMS_OUTPUT.PUT_LINE('Pracownikowi naliczono bonus: ' || v_bonus_amount || ' zł.');

    ELSIF v_current_status = 'Wykonane' THEN
        DBMS_OUTPUT.PUT_LINE('INFORMACJA: Zlecenie jest już wykonane. Bonus został naliczony wcześniej.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Nie można zmienić statusu z: ' || v_current_status);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD: Nie znaleziono zlecenia o ID: ' || p_order_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('WYSTĄPIŁ BŁĄD: ' || SQLERRM);
END;

--funkcje która liczy dla każdego pracownika sumę pieniędzy jaką zarobił dla solonu w danym miesiącu. 
--Funkcja ma przyjmować jako parametry id pracownika oraz miesiąc w który ma być policzony. Liczone są tylko zlecenia które zostały wykonane
CREATE OR REPLACE FUNCTION Get_Employee_Monthly_Revenue (
    p_employee_id IN INTEGER,
    p_month_year  IN VARCHAR2  -- Format 'MM-YYYY', np. '01-2026'
) RETURN NUMBER IS
    v_total_revenue NUMBER(10,2) := 0;
BEGIN
    -- Sumujemy total_cost dla zleceń konkretnego pracownika
    -- Filtrujemy po statusie 'Wykonane' i dacie pasującej do podanego miesiąca i roku
    SELECT NVL(SUM(o.total_cost), 0)
    INTO v_total_revenue
    FROM Orders_Tab o
    WHERE o.employee_ref.employee_id = p_employee_id
      AND o.status = 'Wykonane'
      AND TO_CHAR(o.order_time, 'MM-YYYY') = p_month_year;

    RETURN v_total_revenue;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--funkcja która zlicza zarobki całego bruncha w danym miesiącu. Funkcja ma przyjmowac id bruncha i miesiąc i następnie przy pomocy funkcji Get_Employee_Monthly_Revenue obliczać przychód.
CREATE OR REPLACE FUNCTION Get_Branch_Monthly_Revenue (
    p_branch_id   IN INTEGER,
    p_month_year  IN VARCHAR2  -- Format 'MM-YYYY', np. '01-2026'
) RETURN NUMBER IS
    v_total_branch_revenue NUMBER(10,2) := 0;
    v_emp_revenue          NUMBER(10,2) := 0;
    
    -- Kursor pobierający ID wszystkich pracowników przypisanych do danego oddziału
    CURSOR c_employees IS
        SELECT DEREF(e.column_value).employee_id as emp_id
        FROM Branches_Tab b, TABLE(b.employees) e
        WHERE b.branch_id = p_branch_id;
BEGIN
    -- Iterujemy po wszystkich pracownikach oddziału
    FOR r_emp IN c_employees LOOP
        -- Wykorzystujemy istniejącą funkcję dla każdego pracownika
        v_emp_revenue := Get_Employee_Monthly_Revenue(r_emp.emp_id, p_month_year);
        
        -- Dodajemy do sumy oddziału
        v_total_branch_revenue := v_total_branch_revenue + v_emp_revenue;
    END LOOP;

    RETURN v_total_branch_revenue;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('BŁĄD w Get_Branch_Monthly_Revenue: ' || SQLERRM);
        RETURN 0;
END;
