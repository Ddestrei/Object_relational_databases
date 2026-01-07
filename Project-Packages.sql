CREATE OR REPLACE PACKAGE KLIENT_PKG AS
    FUNCTION czy_email_poprawny(p_email VARCHAR2) RETURN BOOLEAN;
    FUNCTION czy_klient_istnieje(p_imie VARCHAR2, p_nazwisko VARCHAR2, p_tel VARCHAR2) RETURN BOOLEAN;
    PROCEDURE dodaj_klienta(p_imie VARCHAR2, p_nazwisko VARCHAR2, p_tel VARCHAR2, p_email VARCHAR2, p_plec VARCHAR2);
END KLIENT_PKG;
/
CREATE OR REPLACE PACKAGE BODY KLIENT_PKG AS
    FUNCTION czy_email_poprawny(p_email VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$');
    END;

    FUNCTION czy_klient_istnieje(p_imie VARCHAR2, p_nazwisko VARCHAR2, p_tel VARCHAR2) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT count(*) INTO v_count FROM CLIENT_tab 
        WHERE (NAME = p_imie AND SECOND_NAME = p_nazwisko) OR PHONE = p_tel;
        RETURN v_count > 0;
    END;

    PROCEDURE dodaj_klienta(p_imie VARCHAR2, p_nazwisko VARCHAR2, p_tel VARCHAR2, p_email VARCHAR2, p_plec VARCHAR2) IS
    BEGIN
        IF NOT czy_email_poprawny(p_email) THEN
            RAISE_APPLICATION_ERROR(-20001, 'Błędny format email!');
        ELSIF czy_klient_istnieje(p_imie, p_nazwisko, p_tel) THEN
            RAISE_APPLICATION_ERROR(-20002, 'Klient o takich danych już istnieje!');
        ELSE
            -- Używamy sekwencji dla ID i poprawnej nazwy typu kolekcji REF
            INSERT INTO CLIENT_tab (ID, NAME, SECOND_NAME, PHONE, EMAIL, GENDER, COMMISIONS)
            VALUES (seq_client.NEXTVAL, p_imie, p_nazwisko, p_tel, p_email, p_plec, CLIENT_COMMISION_NTAB_REF());
        END IF;
    END;
END KLIENT_PKG;
/

CREATE OR REPLACE PACKAGE PRACOWNIK_PKG AS
    FUNCTION czy_pesel_poprawny(p_pesel VARCHAR2) RETURN BOOLEAN;
    FUNCTION oblicz_zarobki_brutto(p_emp_id INTEGER) RETURN NUMBER;
    FUNCTION sprawdz_grafik(p_emp_id INTEGER, p_termin DATE, p_czas_minuty NUMBER) RETURN BOOLEAN;
END PRACOWNIK_PKG;
/

CREATE OR REPLACE PACKAGE BODY PRACOWNIK_PKG AS
    FUNCTION czy_pesel_poprawny(p_pesel VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        -- Standardowa walidacja: 11 cyfr
        RETURN LENGTH(p_pesel) = 11 AND REGEXP_LIKE(p_pesel, '^[0-9]+$');
    END;

    FUNCTION sprawdz_grafik(p_emp_id INTEGER, p_termin DATE, p_czas_minuty NUMBER) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        -- Musimy użyć DEREF, ponieważ COLUMN_VALUE to REF GRAPHIC_t
        SELECT count(*) INTO v_count 
        FROM TABLE(SELECT GRAPHICS FROM EMPLOYEE_tab WHERE ID = p_emp_id) g
        WHERE p_termin BETWEEN DEREF(g.COLUMN_VALUE).START_HOURS 
                          AND DEREF(g.COLUMN_VALUE).END_HOURS;
        
        RETURN v_count > 0;
    END;

    FUNCTION oblicz_zarobki_brutto(p_emp_id INTEGER) RETURN NUMBER IS
        v_pensja NUMBER;
        v_premia NUMBER;
    BEGIN
        SELECT SALARY, NVL(BONUS, 0) INTO v_pensja, v_premia 
        FROM EMPLOYEE_tab 
        WHERE ID = p_emp_id;
        
        RETURN v_pensja + v_premia;
    END;
END PRACOWNIK_PKG;
/

DROP PACKAGE KLIENT_PKG;
DROP PACKAGE PRACOWNIK_PKG;

