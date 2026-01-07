CREATE OR REPLACE PROCEDURE zwieksz_wyposazenie(
    p_salon_id INTEGER, 
    p_eq_name VARCHAR2, 
    p_ile INTEGER
) IS
BEGIN
    UPDATE EQUIPMENT_tab e
    SET e.AMOUNT = e.AMOUNT + p_ile
    WHERE e.NAME = p_eq_name
    AND REF(e) IN (
        SELECT COLUMN_VALUE 
        FROM TABLE(SELECT EQUIPMENTS FROM SALON_tab WHERE ID = p_salon_id)
    );
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono wyposażenia o nazwie ' || p_eq_name || ' w salonie nr ' || p_salon_id);
    END IF;
END;

CREATE OR REPLACE TYPE ID_LISTA_t AS TABLE OF INTEGER;

CREATE OR REPLACE FUNCTION znajdz_wolnego_pracownika(
    p_data_godzina DATE, 
    p_uslugi_ids ID_LISTA_t,
    p_suma_minut NUMBER
) RETURN INTEGER IS
    -- Kursor przechodzący przez wszystkich pracowników
    CURSOR c_pracownicy IS
        SELECT ID, POSITION, NAME, SECOND_NAME FROM EMPLOYEE_tab;

    -- Kursor sprawdzający czy pracownik ma kwalifikacje do wszystkich usług
    CURSOR c_kwalifikacje(cp_emp_pos VARCHAR2) IS
        SELECT count(*) 
        FROM SERVICE_tab s
        WHERE s.ID IN (SELECT column_value FROM TABLE(p_uslugi_ids))
          AND s.QUALIFICATION_LEVEL != cp_emp_pos;

    v_niedopasowane_kwalifikacje NUMBER;
    v_planowany_koniec DATE := p_data_godzina + (p_suma_minut / 1440);
    v_kolizja NUMBER;
    v_w_grafiku NUMBER;
BEGIN
    -- Przechodzimy przez każdego pracownika (Kursor główny)
    FOR r_emp IN c_pracownicy LOOP
        
        -- 1. Sprawdzenie kwalifikacji (czy są jakieś usługi, do których NIE ma uprawnień)
        OPEN c_kwalifikacje(r_emp.POSITION);
        FETCH c_kwalifikacje INTO v_niedopasowane_kwalifikacje;
        CLOSE c_kwalifikacje;

        IF v_niedopasowane_kwalifikacje = 0 THEN
            
            -- 2. Sprawdzenie czy pracownik pracuje w tych godzinach (czy ma grafik na ten czas)
            SELECT count(*) INTO v_w_grafiku
            FROM TABLE(SELECT GRAPHICS FROM EMPLOYEE_tab WHERE ID = r_emp.ID) g_ref
            WHERE p_data_godzina >= DEREF(g_ref.COLUMN_VALUE).START_HOURS 
              AND v_planowany_koniec <= DEREF(g_ref.COLUMN_VALUE).END_HOURS;

            IF v_w_grafiku > 0 THEN
                
                -- 3. Sprawdzenie kolizji z istniejącymi zleceniami w grafikach tego pracownika
                SELECT count(*) INTO v_kolizja
                FROM TABLE(SELECT GRAPHICS FROM EMPLOYEE_tab WHERE ID = r_emp.ID) g_ref,
                     TABLE(DEREF(g_ref.COLUMN_VALUE).COMMISIONS) c_ref
                WHERE (p_data_godzina < DEREF(c_ref.COLUMN_VALUE).DATE_ + (30/1440) -- Zakładamy 30min na istniejące
                  AND v_planowany_koniec > DEREF(c_ref.COLUMN_VALUE).DATE_);

                -- Jeśli brak kolizji, zwracamy ID tego pracownika
                IF v_kolizja = 0 THEN
                    RETURN r_emp.ID;
                END IF;
                
            END IF;
        END IF;
    END LOOP;

    -- Jeśli pętla się skończy i nie znajdziemy nikogo
    RETURN NULL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;


DROP PROCEDURE zwieksz_wyposazenie;