-- Dodawanie Usług
INSERT INTO SERVICE_tab (NAME, PRICE, COMPLETION_TIME, QUALIFICATION_LEVEL) VALUES ('Strzyżenie Męskie', 60.00, 30, 'Junior');
INSERT INTO SERVICE_tab (NAME, PRICE, COMPLETION_TIME, QUALIFICATION_LEVEL) VALUES ('Koloryzacja Master', 300.00, 150, 'Master');

select * from SERVICE_tab;

-- Dodawanie Wyposażenia
INSERT INTO EQUIPMENT_tab (NAME, AMOUNT, PRICE) VALUES ( 'Fotel Fryzjerski Lux', 5, 2500.00);
INSERT INTO EQUIPMENT_tab (NAME, AMOUNT, PRICE) VALUES ( 'Suszarka Hejro', 10, 400.00);

INSERT INTO COMMISION_tab (DATE_, STATUS, PRICE, SERVICES) VALUES (
        TO_DATE('2026-01-10 10:00', 'YYYY-MM-DD HH24:MI'), 
        'ZAREZERWOWANE',    
        60.00, 
        SERVICE_NTAB_REF((SELECT REF(s) FROM SERVICE_tab s WHERE NAME = 'Koloryzacja Master'))
);

-- Najpierw tworzymy Grafik w osobnej tabeli
INSERT INTO GRAPHIC_tab VALUES (
    GRAPHIC_t(
        seq_graphic.NEXTVAL, 
        TRUNC(SYSDATE), 
        TO_DATE('2026-01-10 08:00', 'YYYY-MM-DD HH24:MI'), 
        TO_DATE('2026-01-10 16:00', 'YYYY-MM-DD HH24:MI'), 
        COMMISION_NTAB_REF((SELECT REF(c) FROM COMMISION_tab c WHERE ID = 1))
    )
);

-- Teraz dodajemy Pracownika i przypisujemy mu ten Grafik
INSERT INTO EMPLOYEE_tab VALUES (
    EMPLOYEE_t(
        seq_employee.NEXTVAL, 'Anna', 'Kowalska', SYSDATE, 'Master', 
        GRAPHIC_NTAB_REF((SELECT REF(g) FROM GRAPHIC_tab g WHERE ID = 1)),
        '90010112345', 5000.00, 0
    )
);

-- Dodanie Klienta (Przez procedurę z paczki dla walidacji)
EXEC KLIENT_PKG.dodaj_klienta('Piotr', 'Zieliński', '666777888', 'p.ziel@poczta.pl', 'M');

-- Przypisanie istniejącego zlecenia do klienta
UPDATE CLIENT_tab 
SET COMMISIONS = CLIENT_COMMISION_NTAB_REF((SELECT REF(c) FROM COMMISION_tab c WHERE ID = 1))
WHERE EMAIL = 'p.ziel@poczta.pl';

-- Dodanie Salonu (Placówki) z przypisaniem sprzętu i pracowników
INSERT INTO SALON_tab VALUES (
    seq_salon.NEXTVAL, 
    'ul. Piękna 12, Warszawa', 
    EQ_NTAB_REF((SELECT REF(eq) FROM EQUIPMENT_tab eq WHERE NAME = 'Fotel Fryzjerski Lux')), 
    EMP_NTAB_REF((SELECT REF(e) FROM EMPLOYEE_tab e WHERE SECOND_NAME = 'Kowalska')),
    '221234567'
);

SELECT 
    s.ADDRESS as Salon,
    DEREF(e.COLUMN_VALUE).NAME as Sprzet,
    DEREF(e.COLUMN_VALUE).AMOUNT as Ilosc
FROM SALON_tab s, TABLE(s.EQUIPMENTS) e;