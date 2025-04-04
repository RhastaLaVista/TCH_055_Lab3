-- ===================================================================
-- Authors : M'hamed Battioui, Pablo Gomez Montero, Ekrem Yoruk, Marc Lampron
-- 
-- Description : Laboratoire 3
--
-- ====================================================================

-- -----------------------------------------------------------------------------
-- Question 1 

CREATE OR REPLACE TRIGGER TRG_update_stock
BEFORE UPDATE OF QUANTITE_STOCK ON PRODUIT
FOR EACH ROW
DECLARE
    v_ldp_livree Livraison_Commande_Produit.QUANTITE_LIVREE%TYPE;
    E_STOCK_INSUFFISANT EXCEPTION;
BEGIN

    SELECT SUM(QUANTITE_LIVREE) 
    INTO v_ldp_livree
    FROM Livraison_Commande_Produit
    WHERE Livraison_Commande_Produit.NO_PRODUIT = :NEW.REF_PRODUIT;



    IF v_ldp_livree > :NEW.QUANTITE_STOCK THEN
        RAISE E_STOCK_INSUFFISANT;
    END IF;

EXCEPTION
    WHEN E_STOCK_INSUFFISANT THEN
        RAISE_APPLICATION_ERROR(-20001, 'Pas assez de produit en stock pour livrer.');
END;
/
-- -----------------------------------------------------------------------------



-- -----------------------------------------------------------------------------
-- Question 2
-- -----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER TRG_command_stock
BEFORE UPDATE OF QUANTITE_STOCK ON PRODUIT
FOR EACH ROW
DECLARE
    v_app_prod APPROVISIONNEMENT.NO_PRODUIT%TYPE;
BEGIN

   BEGIN
        SELECT NO_PRODUIT 
        INTO v_app_prod
        FROM APPROVISIONNEMENT
        WHERE NO_PRODUIT = :NEW.REF_PRODUIT;

    EXCEPTION 
        WHEN NO_DATA_FOUND THEN 
            v_app_prod := NULL; -- Set to NULL if no record exists
    END;

    IF :NEW.QUANTITE_STOCK < :NEW.QUANTITE_SEUIL AND v_app_prod IS NULL THEN
        INSERT INTO APPROVISIONNEMENT(NO_PRODUIT, CODE_FOURNISSEUR, QUANTITE_APPROVIS, DATE_CMD_APPROVIS)
        VALUES(:NEW.REF_PRODUIT, :NEW.CODE_FOURNISSEUR_PRIORITAIRE, :NEW.QUANTITE_SEUIL*1.10, CURRENT_DATE);  
    ELSIF :NEW.QUANTITE_STOCK >= :NEW.QUANTITE_SEUIL AND v_app_prod IS NOT NULL THEN
        DELETE FROM APPROVISIONNEMENT WHERE NO_PRODUIT = v_app_prod;
    END IF;

END;
/

UPDATE PRODUIT
SET QUANTITE_STOCK = 1
WHERE REF_PRODUIT = 'PC2000';

SELECT * FROM APPROVISIONNEMENT;
SELECT * FROM PRODUIT;

-- -----------------------------------------------------------------------------
-- Question 3-A
-- -----------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER TRG_statistique_vente
AFTER INSERT ON Livraison_Commande_Produit
FOR EACH ROW
DECLARE
    v_code_mois NUMBER(2);
BEGIN
    SELECT TO_CHAR(SYSDATE, 'MM') INTO v_code_mois FROM DUAL;

    MERGE INTO Statistique_Vente sv
    USING (SELECT :NEW.no_produit AS ref_produit, v_code_mois AS code_mois FROM DUAL) src

    ON (sv.ref_produit = src.ref_produit AND sv.code_mois = src.code_mois)
    WHEN MATCHED THEN
        UPDATE SET sv.quantite_vendue = sv.quantite_vendue + :NEW.QUANTITE_LIVREE
    WHEN NOT MATCHED THEN
        INSERT (ref_produit, code_mois, quantite_vendue)
        VALUES (:NEW.no_produit, v_code_mois, :NEW.quantite_livree);
    
END;
      
-- -----------------------------------------------------------------------------
-- Question 3-B
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE creer_livraison_37 IS
    v_stock_disponible NUMBER;
    v_produit VARCHAR2(26);
    v_quantite_a_livrer NUMBER;
    erreur_stock EXCEPTION; 

    CURSOR cur_produits IS
        SELECT no_produit, quantite_cmd
        FROM Commande_Produit
        WHERE no_commande = 37;

BEGIN
    SAVEPOINT debut_livraison;
    INSERT INTO Livraison (no_livraison, date_livraison)
    VALUES (50037, SYSDATE);

    FOR rec IN cur_produits LOOP
        v_produit := rec.no_produit;
        v_quantite_a_livrer := rec.quantite_cmd;
        SELECT quantite_stock INTO v_stock_disponible
        FROM Produit
        WHERE ref_produit = v_produit;

        IF v_stock_disponible < v_quantite_a_livrer THEN
            RAISE erreur_stock;
        END IF;

        INSERT INTO Livraison_Commande_Produit (no_livraison, no_commande, no_produit, quantite_livree)
        VALUES (50037, 37, v_produit, v_quantite_a_livrer);
        UPDATE Produit
        SET quantite_stock = quantite_stock - v_quantite_a_livrer
        WHERE ref_produit = v_produit;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Livraison 50037 créée avec succès !');

EXCEPTION
    WHEN erreur_stock THEN
        ROLLBACK TO debut_livraison;
        DBMS_OUTPUT.PUT_LINE('Échec de la livraison : stock insuffisant pour le produit ' || v_produit);
    WHEN OTHERS THEN
        ROLLBACK TO debut_livraison;
        DBMS_OUTPUT.PUT_LINE('Une erreur inattendue est survenue : ' || SQLERRM);
END creer_livraison_37;

-- -----------------------------------------------------------------------------
-- Question 4
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION f_quantite_deja_livree(
    p_no_produit IN Livraison_Commande_Produit.no_produit%TYPE,
    p_no_commande IN Commande.no_commande%TYPE
) RETURN NUMBER IS
    v_quantite NUMBER := 0;
BEGIN
    SELECT NVL(SUM(quantite_livree), -1)
    INTO v_quantite
    FROM Livraison_Commande_Produit LCP
    JOIN Livraison L ON LCP.no_livraison = L.no_livraison
    JOIN Commande C ON C.no_commande = p_no_commande
    WHERE LCP.no_produit = p_no_produit
    AND C.no_commande = p_no_commande;

    RETURN v_quantite;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
    WHEN OTHERS THEN
        RETURN -1;
END f_quantite_deja_livree;



-- TESTS

BEGIN
    creer_livraison_37;
END;

SELECT * FROM Livraison WHERE no_livraison = 50037;

-- Deja livrée
SELECT f_quantite_deja_livree('PC2000', 37) FROM DUAL;

-- Produit existe pas
SELECT f_quantite_deja_livree('ABC123', 37) FROM DUAL;


-- -----------------------------------------------------------------------------
-- Question 5
-- -----------------------------------------------------------------------------

-- ============================================================

SET  SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE p_Etat_Stock
(produit Produit.code_produit%TYPE , seuil NUMBER) IS
--Déclarations de variables
qte_stock   NUMBER(10); -- la quantité en stocke de produit

BEGIN
    --Interrogation de la base de donn.es
        SELECT quantite
        INTO qte_stock
        FROM Produit
        WHERE code_produit = produit;
    --Affichage de l'état du stock
        IF qte_stock > seuil THEN
            DBMS_OUTPUT.PUT_LINE('L article ' || produit ||' est en stock');
        ELSIF  qte_stock >0 THEN
            DBMS_OUTPUT.PUT_LINE('L article ' || produit ||' est bient�t en rupture de stock');
        ELSE
            DBMS_OUTPUT.PUT_LINE('L article ' || produit ||' est en rupture de stock');
        END IF;
END;
/
-- Execution de la procédure
EXEC p_Etat_Stock ( '05W34', 100);

-- -----------------------------------------------------------------------------
-- Question 6
-- -----------------------------------------------------------------------------

SET  SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE p_preparer_livraison
(Livraison_Commande_Produit p_no_livraison NUMBER) IS

--Déclarations de variables
v_nom_client   VARCHAR2(30);
v_prenom_client VARCHAR2(30);
v_telephone_client VARCHAR2(15);
v_id_adresse NUMBER(5);
v_no_civique NUMBER(6);
v_nom_rue VARCHAR2(20);
v_ville VARCHAR2(20);
v_pays VARCHAR2(20);
v_code_postal VARCHAR2(8);
v_no_livraison NUMBER(5);
v_date_livraison DATE;

v_ref_produit VARCHAR2(6);
v_nom_produit VARCHAR2(30);
v_marque VARCHAR2(30);
v_quantite_livree NUMBER(6);
v_no_commande NUMBER(5);
v_date_commande DATE;

CURSOR c_livraison_items IS
    SELECT Produit.ref_produit,
           Produit.nom_produit,
           Produit.marque,
           Livraison_Commande_Produit.quantite_livree,
           Livraison_Commande_Produit.no_commande,
           Commande.date_commande
    FROM Livraison_Commande_Produit
    JOIN Commande_Produit ON Commande_Produit.no_produit = Livraison_Commande_Produit.no_produit
    JOIN Produit ON Produit.ref_produit = Commande_Produit.no_produit
    JOIN Commande ON Commande.no_commande = Livraison_Commande_Produit.no_commande
    WHERE Livraison_Commande_Produit.no_livraison = p_no_livraison;

BEGIN
    --Interrogation de la base de donn.es
        SELECT Client.nom, Client.prenom, Client.telephone, Adresse.id_adresse, Adresse.no_civique, Adresse.nom_rue, Adresse.ville,
        Adresse.pays, Adresse.code_postal, Livraison.no_livraison, Livraison.date_livraison, Produit.ref_produit,
        Produit.nom_produit, Produit.marque, Livraison_Commande_Produit.quantite_livree, Livraison_Commande_Produit.no_commande,
        Commande.date_commande
        INTO v_nom_client, v_prenom_client, v_telephone_client, v_id_adresse, v_no_civique, v_nom_rue, v_ville, v_pays,
        v_code_postal, v_no_livraison, v_date_livraison, v_ref_produit, v_nom_produit, v_marque, v_quantite_livree,
        v_no_commande, v_date_commande
        FROM Client
        JOIN Adresse ON Client.id_adresse = Adresse.id_adresse
        JOIN Commande ON Client.no_client = Commande.no_client
        JOIN Commande_Produit ON Commande.no_commande = Commande_Produit.no_commande
        JOIN Livraison_Commande_Produit ON Commande.no_commande = Livraison_Commande_Produit.no_commande
        JOIN Livraison ON Livraison_Commande_Produit.no_livraison = Livraison.no_livraison
        JOIN Produit ON Commande_Produit.no_produit = Produit.ref_produit
        WHERE Livraison.no_livraison = p_no_livraison;
    --Exception
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('La livraison nexiste pas pour le numéro ' || p_no_livraison);
      RETURN;
END;
/

DBMS_OUTPUT.PUT_LINE('No Client: ' || RPAD(v_no_client, 20));
DBMS_OUTPUT.PUT_LINE('Nom: ' || RPAD(v_nom_client, 20));
DBMS_OUTPUT.PUT_LINE('Prenom: ' || RPAD(v_prenom_client, 20));
DBMS_OUTPUT.PUT_LINE('Telephone: ' || RPAD(v_telephone_client, 20));
DBMS_OUTPUT.PUT_LINE('Adresse: ' || v_id_adresse || ' ' || v_no_civique || ' ' || v_nom_rue || ' ' || v_ville || ' ' || v_pays || ' ' || v_code_postal);
DBMS_OUTPUT.PUT_LINE('No Livraison: ' || RPAD(v_no_livraison, 20));
DBMS_OUTPUT.PUT_LINE('Date Livraison: ' || RPAD(TO_CHAR(v_date_livraison, 'DD/MM/YYYY'), 20));
DBMS_OUTPUT.PUT_LINE('-------------------------------');
DBMS_OUTPUT.PUT_LINE('No produit      Nom Produit       Marque       Q. Livree      No CMD.     Date CMD.');
DBMS_OUTPUT.PUT_LINE('-------------------------------');
FOR rec IN c_livraison_items LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(rec.ref_produit, 15) || RPAD(rec.nom_produit, 20) || RPAD(rec.marque, 15) || 
                RPAD(rec.quantite_livree, 12) || RPAD(rec.no_commande, 12) || TO_CHAR(rec.date_commande, 'DD/MM/YYYY'));
END LOOP;
DBMS_OUTPUT.PUT_LINE('----------------------');
DBMS_OUTPUT.PUT_LINE('----------------------');

-- Execution de la procédure
EXEC p_preparer_livraison (50037);
EXEC p_preparer_livraison (99999);

-- -----------------------------------------------------------------------------
-- Question 7  
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE P_produire_facture
(p_livraison_no Livraison_Commande_Produit.no_livraison%TYPE) IS
-- Déclarations de variables

v_No_client VARCHAR2(5); -- informations du client dans le recu
v_Nom_client VARCHAR2(30);
v_Prenom_client VARCHAR2(30);
v_Telephone VARCHAR2(15);

v_Add_nocivique NUMBER(6);--les parties de l'addresse.
v_Add_nom_rue VARCHAR2(20);
v_Add_ville VARCHAR2(20);
v_Add_pays VARCHAR2(20);
v_Add_code_postal VARCHAR2(8);

v_Comm_No_Prod VARCHAR2(6);--Informations de la livraison.
v_Comm_Marque VARCHAR2(20);
v_Comm_Prix NUMBER(8,2);
v_Comm_Qte_liv NUMBER(6);
v_Comm_Totalpartiel NUMBER(6);

v_FACT_Montant NUMBER(8,2);--Information de la facture et les paiements
v_FACT_Remise NUMBER(8,2);
v_FACT_Montant_Reduit NUMBER(8,2);
v_FACT_Taxe NUMBER(8,2);
v_FACT_TOTAL_Restant NUMBER(8,2);

CURSOR c_items_livrees IS
    SELECT Produit.ref_produit,
           Produit.nom_produit,
           Produit.marque,
           Produit.PRIX_UNITAIRE,
           Livraison_Commande_Produit.quantite_livree
    FROM Livraison_Commande_Produit LCP
    INNER JOIN Commande_Produit CP ON LCP.no_commande = CP.no_commande
    INNER JOIN Produit Prod ON CP.no_produit = prod.REF_PRODUIT
    WHERE LCP.no_Livraison = p_livraison_no;

BEGIN
--Interrogation de la base de données

    SELECT CLIENT.no_client,
           Client.NOM,
           CLIENT.PRENOM,
           CLIENT.TELEPHONE,
           ADDRESSE.Adresse.NO_CIVIQUE

        --Interrogation de la base de donn.es
        SELECT Client.nom, Client.prenom, Client.telephone, Adresse.id_adresse, Adresse.no_civique, Adresse.nom_rue, Adresse.ville,
        Adresse.pays, Adresse.code_postal, Livraison.no_livraison, Livraison.date_livraison, Produit.ref_produit,
        Produit.nom_produit, Produit.marque, Livraison_Commande_Produit.quantite_livree, Livraison_Commande_Produit.no_commande,
        Commande.date_commande
        INTO v_nom_client, v_prenom_client, v_telephone_client, v_id_adresse, v_no_civique, v_nom_rue, v_ville, v_pays,
        v_code_postal, v_no_livraison, v_date_livraison, v_ref_produit, v_nom_produit, v_marque, v_quantite_livree,
        v_no_commande, v_date_commande
        FROM Client
        JOIN Adresse ON Client.id_adresse = Adresse.id_adresse
        JOIN Commande ON Client.no_client = Commande.no_client
        JOIN Commande_Produit ON Commande.no_commande = Commande_Produit.no_commande
        JOIN Livraison_Commande_Produit ON Commande.no_commande = Livraison_Commande_Produit.no_commande
        JOIN Livraison ON Livraison_Commande_Produit.no_livraison = Livraison.no_livraison
        JOIN Produit ON Commande_Produit.no_produit = Produit.ref_produit
        WHERE Livraison.no_livraison = p_no_livraison;
    --Exception
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('La livraison nexiste pas pour le numéro ' || p_no_livraison);
      RETURN;


SELECT *  
INTO 
FROM 
WHERE code_produit = produit ;
--Affichage de l'état du stock
IF qte_stock>seuil THEN
DBMS_OUTPUT.PUT_LINE('L''article ' || produit ||' est en
stock');

END IF;


END;


-- -----------------------------------------------------------------------------
-- Question 8
-- -----------------------------------------------------------------------------


