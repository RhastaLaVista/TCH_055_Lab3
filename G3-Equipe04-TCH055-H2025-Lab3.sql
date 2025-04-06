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
    SELECT NVL(SUM(quantite_livree), 0)
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

SET  SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE p_afficher_livraisons_clients IS
    CURSOR c_commandes IS
        SELECT Commande.no_commande, Commande.no_client
        FROM Commande;

    v_quantite_livree NUMBER;
    

BEGIN

    FOR commande_rec IN c_commandes LOOP

        FOR produit_rec IN 
        
        (SELECT p.ref_produit, Commande_Produit.quantite_cmd
            FROM Commande_Produit Commande_Produit
            JOIN Produit p ON Commande_Produit.no_produit = p.ref_produit
            WHERE Commande_Produit.no_commande = commande_rec.no_commande)
            
        LOOP
            v_quantite_livree := f_quantite_deja_livree(produit_rec.ref_produit, commande_rec.no_commande);
            
            DBMS_OUTPUT.PUT_LINE('Client: ' || commande_rec.no_client || 
                                 ', Commande N°: ' || commande_rec.no_commande || 
                                 ', Produit: ' || produit_rec.ref_produit || 
                                 ', Quantité Commandée: ' || produit_rec.quantite_cmd ||
                                 ', Quantité Livrée: ' || v_quantite_livree);
        END LOOP;
    END LOOP;
END p_afficher_livraisons_clients;
/

EXEC p_afficher_livraisons_clients;

-- -----------------------------------------------------------------------------
-- Question 6
-- -----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE p_preparer_livraison (
    p_no_livraison IN NUMBER
) IS
    -- Déclarations de variables
    v_no_client NUMBER(5);
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

    -- Curseur pour les articles de la livraison
    CURSOR c_livraison_items IS
        SELECT p.ref_produit,
               p.nom_produit,
               p.marque,
               lcp.quantite_livree,
               lcp.no_commande,
               c.date_commande
        FROM Livraison_Commande_Produit lcp
        JOIN Commande_Produit cp ON cp.no_produit = lcp.no_produit
        JOIN Produit p ON p.ref_produit = cp.no_produit
        JOIN Commande c ON c.no_commande = lcp.no_commande
        WHERE lcp.no_livraison = p_no_livraison;

BEGIN
    -- Interrogation de la base de données pour récupérer les informations
        SELECT cl.nom, cl.prenom, cl.telephone, a.id_adresse, a.no_civique, a.nom_rue, a.ville,
               a.pays, a.code_postal, l.no_livraison, l.date_livraison, p.ref_produit,
               p.nom_produit, p.marque, lcp.quantite_livree, lcp.no_commande, c.date_commande
        INTO v_nom_client, v_prenom_client, v_telephone_client, v_id_adresse, v_no_civique, v_nom_rue, 
             v_ville, v_pays, v_code_postal, v_no_livraison, v_date_livraison, v_ref_produit, 
             v_nom_produit, v_marque, v_quantite_livree, v_no_commande, v_date_commande
        FROM Client cl
        JOIN Adresse a ON cl.id_adresse = a.id_adresse
        JOIN Commande c ON cl.no_client = c.no_client
        JOIN Commande_Produit cp ON c.no_commande = cp.no_commande
        JOIN Livraison_Commande_Produit lcp ON c.no_commande = lcp.no_commande
        JOIN Livraison l ON lcp.no_livraison = l.no_livraison
        JOIN Produit p ON cp.no_produit = p.ref_produit
        WHERE l.no_livraison = p_no_livraison;

        -- Affichage des informations
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

        -- Parcours du curseur pour afficher les produits livrés
        FOR rec IN c_livraison_items LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD(rec.ref_produit, 15) || RPAD(rec.nom_produit, 20) || RPAD(rec.marque, 15) || 
                                 RPAD(rec.quantite_livree, 12) || RPAD(rec.no_commande, 12) || TO_CHAR(rec.date_commande, 'DD/MM/YYYY'));
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('----------------------');
        DBMS_OUTPUT.PUT_LINE('----------------------');
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('La livraison nexiste pas pour le numéro ' || p_no_livraison);
            RETURN;
END p_preparer_livraison;
/


-- Execution de la procédure
EXEC p_preparer_livraison (50037);
EXEC p_preparer_livraison (99999);

-- -----------------------------------------------------------------------------
-- Question 7
-- -----------------------------------------------------------------------------
SET SERVEROUTPUT ON;

CREATE SEQUENCE dept_seq
INCREMENT BY 1
START WITH 1
MAXVALUE 99999
NOCYCLE
CACHE 10;

CREATE OR REPLACE TRIGGER dep_ins_trig 
BEFORE INSERT ON FACTURE 
FOR EACH ROW

BEGIN
  SELECT dept_seq.NEXTVAL
  INTO   :new.id_facture
  FROM   dual;
END;
/

CREATE OR REPLACE PROCEDURE P_produire_facture
(p_livraison_no in NUMBER, montant_remise in NUMBER) IS
-- gestion parametre
remise_trop_haut EXCEPTION;


-- Déclarations de variables

v_No_client VARCHAR2(5); -- informations du client dans le recu
v_Nom_client VARCHAR2(30);
v_Prenom_client VARCHAR2(30);
v_Telephone VARCHAR2(15);

v_Add_nocivique NUMBER(6) := 0;--les parties de l'addresse.
v_Add_nom_rue VARCHAR2(20);
v_Add_ville VARCHAR2(20);
v_Add_pays VARCHAR2(20);
v_Add_code_postal VARCHAR2(8);

v_Comm_No_Prod VARCHAR2(6);--Informations de la livraison.
v_Comm_Marque VARCHAR2(20);
v_Comm_Prix NUMBER(8,2) := 0 ;
v_Comm_qte NUMBER(6) := 0 ;
v_Comm_Totalpartiel NUMBER(6):= 0 ;
v_Comm_Remise NUMBER(10) := 0;

v_FACT_Montant NUMBER(8,2):=0;--Information de la facture et les paiements
v_FACT_Remise NUMBER(8,2):=0;
v_FACT_Montant_Reduit NUMBER(8,2) :=0 ;
v_FACT_Taxe NUMBER(8,2):=0;
v_FACT_TOTAL_Restant NUMBER(8,2):=0;
v_FACT_DATE_LIV DATE;
v_FACT_DATE_fact DATE;
v_FACT_DATE_lim DATE;


CURSOR c_items_livrees IS
    SELECT Prod.ref_produit,
           Prod.nom_produit,
           Prod.marque,
           Prod.PRIX_UNITAIRE,
           LCP.quantite_livree,
           CP.quantite_cmd
           --Promotion.reduction
    FROM Livraison_Commande_Produit LCP
    INNER JOIN Commande_Produit CP ON LCP.no_commande = CP.no_commande
    INNER JOIN Produit Prod ON CP.no_produit = prod.REF_PRODUIT
    INNER JOIN Commande C ON CP.no_commande = C.no_commande
    WHERE LCP.no_Livraison = p_livraison_no;

BEGIN
    
--Interrogation de la base de données
IF montant_remise < 0 OR montant_remise > 20 THEN
    RAISE remise_trop_haut;
END IF;

    SELECT cli.no_client,
           cli.NOM,
           cli.PRENOM,
           cli.TELEPHONE,
           addr.NO_CIVIQUE,
           addr.NOM_RUE,
           addr.VILLE,
           addr.PAYS,
           addr.CODE_POSTAL,
           l.DATE_LIVRAISON
           INTO v_No_client,
                v_Nom_client,
                v_Prenom_client,
                v_Telephone,
                v_Add_nocivique,
                v_Add_nom_rue,
                v_Add_ville,
                v_Add_pays,
                v_Add_code_postal,
                V_FACT_DATE_LIV
           FROM livraison l
           INNER JOIN LIVRAISON_COMMANDE_PRODUIT LCP ON LCP.NO_LIVRAISON = L.NO_LIVRAISON
           INNER JOIN Commande_Produit CP ON LCP.no_commande = CP.no_commande
           INNER JOIN Commande C ON CP.no_commande = C.no_commande
           INNER JOIN CLIENT cli ON C.no_client = cli.no_client
           INNER JOIN ADRESSE addr ON cli.id_adresse = addr.id_adresse
           WHERE l.no_livraison = p_livraison_no;
           

           v_FACT_DATE_fact := SYSDATE;
           v_FACT_DATE_lim := v_FACT_DATE_fact + 30 ; --Définition de la variable pour la date limite de Paiement.

        -- Affichage des informations
        DBMS_OUTPUT.PUT_LINE('No Client: ' || RPAD(v_No_client, 20));
        DBMS_OUTPUT.PUT_LINE('Nom      : ' || RPAD(v_Nom_client, 20));
        DBMS_OUTPUT.PUT_LINE('Prenom   : ' || RPAD(v_Prenom_client, 20));
        DBMS_OUTPUT.PUT_LINE('Telephone: ' || RPAD(v_Telephone, 20));
        DBMS_OUTPUT.PUT_LINE('Adresse  : ' || v_Add_nocivique || ' ' || v_Add_nom_rue || ' ' || v_Add_ville || ' ' || v_Add_pays || ' ' || v_Add_code_postal);
        DBMS_OUTPUT.PUT_LINE('No Livraison  : ' || RPAD(p_livraison_no, 20));
        DBMS_OUTPUT.PUT_LINE('Date Livraison: ' || RPAD(TO_CHAR(v_FACT_DATE_LIV, 'DD/MM/YYYY'), 20));
        DBMS_OUTPUT.PUT_LINE('Date Limite Paiement: ' || RPAD(TO_CHAR(v_FACT_DATE_lim), 20));
        DBMS_OUTPUT.PUT_LINE('-------------------------------');
        DBMS_OUTPUT.PUT_LINE('No produit      Nom Produit       Marque       Quantité      Total Partiel');
        DBMS_OUTPUT.PUT_LINE('-------------------------------');

        -- Parcours du curseur pour afficher les produits livrés et la logique de la facture.
        FOR rec IN c_items_livrees LOOP

            v_Comm_Totalpartiel := rec.prix_unitaire * rec.quantite_cmd;-- calcul du montant partiel

            --v_Comm_Remise := v_Comm_Remise + (v_Comm_Totalpartiel*montant_remise); --calcul du rabais total(selon promotion)

            v_FACT_Montant := v_FACT_Montant + v_Comm_Totalpartiel;-- accumulation du montant

            DBMS_OUTPUT.PUT_LINE(RPAD(rec.ref_produit, 15) || RPAD(rec.nom_produit, 20) || RPAD(rec.marque, 20) || 
                                 RPAD(rec.quantite_cmd, 12) || RPAD(V_Comm_Totalpartiel, 20));
        END LOOP;
           
           --Affectation du rabais total:
           v_FACT_Remise := v_FACT_Montant*(montant_remise/100);
           --Affectation du montant réduit:
           v_FACT_Montant_Reduit := v_FACT_Montant - v_FACT_Remise;
           --Affectation du montant du taxe du montant réduit: 
           v_FACT_Taxe := v_FACT_Montant_Reduit * 0.15;
           --Affectation du montant total final après remise
           v_FACT_TOTAL_Restant := v_FACT_Montant_Reduit + v_FACT_Taxe;

           --avant je croyais que la remise était déterminé par les rabais dans promotion donc il se peut que sa trace reste.

        DBMS_OUTPUT.PUT_LINE('Montant        : ' || v_FACT_Montant);--la portion facture.
        DBMS_OUTPUT.PUT_LINE('Remise         : ' || v_FACT_Remise);
        DBMS_OUTPUT.PUT_LINE('Montant Reduit : ' || v_FACT_Montant_Reduit);
        DBMS_OUTPUT.PUT_LINE('Taxe           : ' || v_FACT_Taxe);
        DBMS_OUTPUT.PUT_LINE('Total à payer  : ' || v_FACT_TOTAL_Restant);

        INSERT INTO Facture(remise,date_facture,montant,taxe)
        VALUES (v_Comm_Remise,v_FACT_DATE_fact,v_FACT_Montant,v_FACT_Taxe);

        --Exception
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('La livraison nexiste pas pour le numéro.' || p_livraison_no);
            RETURN;

            WHEN remise_trop_haut THEN
                DBMS_OUTPUT.PUT_LINE('le montant remise doit etre entre 0 et 20.');
            RETURN;

END P_produire_facture;
/


EXEC P_produire_facture(50023,10);
SELECT * FROM LIVRAISON;
-- -----------------------------------------------------------------------------
-- Question 8 *IMCOMPLET* * TO BE TESTED
-- -----------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE P_Afficher_facture
(p_id_facture IN NUMBER) IS

v_Montant_Apayer number(8,2) := 0 ;
v_Montant_dejapaye number(8,2) := 0 ;
v_Montant_restant number(8,2) := 0 ;
v_Paiement_Dlim DATE;-- := datefacturation + 30

v_Montant_Facture number(8,2) :=0 ;
v_remise_Facture number(8,2) :=0 ;
v_taxe_Facture number(8,2) :=0 ;
v_Date_Facture DATE;

v_Montant_Reduit_Facture NUMBER(8,2) :=0;

CURSOR c_items_livrees IS
    SELECT pay.montant
    FROM Paiement pay
    INNER JOIN Facture fac ON pay.id_facture = fac.id_facture
    WHERE Fac.id_Facture = p_id_facture;

BEGIN
        -- Interrogation de la base de donnée
        SELECT Facture.date_facture,
               Facture.MONTANT,
               Facture.TAXE,
               Facture.remise
               INTO v_Date_Facture,
                    v_Montant_Facture,
                    v_taxe_Facture,
                    v_remise_Facture
        FROM Facture
        WHERE id_facture = p_id_facture;
           
           --Affectation du montant réduit:
           v_Montant_Reduit_Facture := v_Montant_Facture - v_remise_Facture;
           --Affectation du montant du taxe du montant réduit: 
           v_taxe_Facture := v_Montant_Reduit_Facture * 0.15;
           --Affectation du montant total final après remise
           v_Montant_Apayer := v_Montant_Reduit_Facture + v_taxe_Facture;

        --affectation du montant à payer (montant total - totalremise) + ((montant total - totalremise)*taxe)
        v_Montant_Apayer := v_Montant_Facture + v_taxe_Facture;

        FOR rec IN c_items_livrees LOOP
        v_Montant_dejapaye := v_Montant_dejapaye + rec.montant; --affectation du montant déjapayée (somme du montant des paiements sur la même facture
        END LOOP;
        
        --affectation du montant restant à payer
        v_Montant_restant := v_Montant_Apayer - v_Montant_dejapaye;

        v_Paiement_Dlim := v_Date_Facture + 30;

        -- Parcours du curseur pour afficher les produits livrés *A modifier*
        DBMS_OUTPUT.PUT_LINE('Montant à payer    : ' || v_Montant_Apayer || ' $');
        DBMS_OUTPUT.PUT_LINE('Montant déja payé  : ' || v_Montant_dejapaye || ' $');
        DBMS_OUTPUT.PUT_LINE('Montant restant à payer: ' || v_Montant_restant || ' $');

        IF v_Montant_restant = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Paiement completée');--La partie d`évaluation du paiement
        ELSE 
        DBMS_OUTPUT.PUT_LINE('Paiement non completé-Solde en souffrance : Date limite de paiement: '|| TO_CHAR(v_Paiement_Dlim,'DD-MM-YYYY'));
        END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('La facture n`existe pas' || p_id_facture);
            RETURN;

    
END P_Afficher_facture;
/

EXEC P_Afficher_facture(60021);
EXEC P_Afficher_facture(60023);