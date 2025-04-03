-- ===================================================================
-- Authors : M'hamed Battioui, Pablo Gomez Montero, Ekrem Yoruk, Marc Lampron
-- 
-- Description :
--
-- |  |  |  |  |  |
-- |  |  |  |  |  |
-- |  |  |  |  |  |
-- |  |  |  |  |  |

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

      
-- -----------------------------------------------------------------------------
-- Question 3-B
-- -----------------------------------------------------------------------------



-- -----------------------------------------------------------------------------
-- Question 4
-- -----------------------------------------------------------------------------



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
(Livraison_Commande_Produit p_no_livraison IN NUMBER) IS

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
(facture Produit.code_produit%TYPE,
seuil NUMBER) IS
-- Déclarations de variables
qte_stock NUMBER(10); --la quantité en stocke de produit
BEGIN
--Interrogation de la base de données
SELECT quantite
INTO qte_stock
FROM Produit
WHERE code_produit = produit ;
--Affichage de l'état du stock
IF qte_stock>seuil THEN
DBMS_OUTPUT.PUT_LINE('L''article ' || produit ||' est en
stock');
ELSIF qte_stock>0 THEN
DBMS_OUTPUT.PUT_LINE('L''article ' || produit ||' est
bientôt en rupture de stock');
ELSE
DBMS_OUTPUT.PUT_LINE('L''article ' || produit ||' est en
rupture de stock');
END IF;
END;


-- -----------------------------------------------------------------------------
-- Question 8
-- -----------------------------------------------------------------------------


