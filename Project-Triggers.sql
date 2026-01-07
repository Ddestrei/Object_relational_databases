CREATE OR REPLACE TRIGGER trg_bonus_after_commission
AFTER UPDATE OF STATUS ON COMMISION_tab
FOR EACH ROW
WHEN (NEW.STATUS = 'WYKONANA')
DECLARE
    v_curr_comm_ref REF COMMISION_t;
BEGIN
    -- Pobieramy referencję do właśnie zaktualizowanego zlecenia
    SELECT REF(c) INTO v_curr_comm_ref 
    FROM COMMISION_tab c 
    WHERE c.ID = :NEW.ID;

    -- Aktualizujemy bonus pracownika, który ma to zlecenie w swoim grafiku
    UPDATE EMPLOYEE_tab e
    SET e.BONUS = NVL(e.BONUS, 0) + (:NEW.PRICE * 0.05)
    WHERE EXISTS (
        SELECT 1 
        FROM TABLE(e.GRAPHICS) g_ref, -- Kolekcja referencji do grafików
             TABLE(DEREF(g_ref.COLUMN_VALUE).COMMISIONS) c_ref -- Kolekcja referencji do zleceń wewnątrz grafiku
        WHERE c_ref.COLUMN_VALUE = v_curr_comm_ref
    );
END;

CREATE OR REPLACE TRIGGER trg_employee_insert
BEFORE INSERT ON EMPLOYEE_tab
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_employee.NEXTVAL;
    END IF;
    :NEW.DATE_OF_EMPLOYMENT := SYSDATE;
END;

-- Przykład triggera dla Usługi (analogicznie dla innych tabel)
CREATE OR REPLACE TRIGGER trg_service_insert
BEFORE INSERT ON SERVICE_tab
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_service.NEXTVAL;
    END IF;
END;

CREATE OR REPLACE TRIGGER trg_assign_employee_to_commission
BEFORE INSERT ON COMMISION_tab
FOR EACH ROW
DECLARE
    v_emp_id       INTEGER;
    v_service_ids  ID_LISTA_t := ID_LISTA_t();
    v_total_time   NUMBER := 0;
    v_comm_ref     REF COMMISION_t;
    v_graphic_ref  REF GRAPHIC_t;
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_commision.NEXTVAL;
    END IF;
    SELECT CAST(COLLECT(DEREF(COLUMN_VALUE).ID) AS ID_LISTA_t),
           SUM(DEREF(COLUMN_VALUE).COMPLETION_TIME)
    INTO v_service_ids, v_total_time
    FROM TABLE(:NEW.SERVICES);
    v_emp_id := znajdz_wolnego_pracownika(:NEW.DATE_, v_service_ids, v_total_time);
    IF v_emp_id IS NOT NULL THEN
    BEGIN
            SELECT COLUMN_VALUE INTO v_graphic_ref
            FROM TABLE(SELECT GRAPHICS FROM EMPLOYEE_tab WHERE ID = v_emp_id) g
            WHERE TRUNC(DEREF(g.COLUMN_VALUE).DAY) = TRUNC(:NEW.DATE_)
            AND ROWNUM = 1;
            INSERT INTO TABLE(
                SELECT DEREF(v_graphic_ref).COMMISIONS FROM DUAL
            ) VALUES (REF_TO_COMMISION(:NEW.ID)); 
            DBMS_OUTPUT.PUT_LINE('Zlecenie ID ' || :NEW.ID || ' przypisano do pracownika ID: ' || v_emp_id);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20004, 'Pracownik jest dostępny, ale nie ma utworzonego grafiku na ten dzień!');
        END;
    ELSE
        RAISE_APPLICATION_ERROR(-20003, 'Brak wolnego pracownika z kwalifikacjami w tym terminie. Zlecenie odrzucone.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_client_insert
BEFORE INSERT ON CLIENT_tab
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_client.NEXTVAL;
    END IF;
END;

CREATE OR REPLACE TRIGGER trg_graphic_insert
BEFORE INSERT ON GRAPHIC_tab 
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_graphic.NEXTVAL;
    END IF;
END;

CREATE OR REPLACE TRIGGER trg_employee_insert
BEFORE INSERT ON EMPLOYEE_tab 
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_employee.NEXTVAL;
    END IF;
END;

CREATE OR REPLACE TRIGGER trg_equipment_insert
BEFORE INSERT ON EQUIPMENT_tab  
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_equipment.NEXTVAL;
    END IF;
END;

CREATE OR REPLACE TRIGGER trg_salon_insert
BEFORE INSERT ON SALON_tab  
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        :NEW.ID := seq_salon.NEXTVAL;
    END IF;
END;

DROP TRIGGER trg_bonus_after_commission;
DROP TRIGGER trg_employee_insert;
DROP TRIGGER trg_service_insert;
DROP TRIGGER trg_commision_insert;
DROP TRIGGER trg_client_insert;
DROP TRIGGER trg_graphic_insert;
DROP TRIGGER trg_employee_insert;
DROP TRIGGER trg_equipment_insert;
DROP TRIGGER trg_salon_insert;
