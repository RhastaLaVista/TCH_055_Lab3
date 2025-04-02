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
BEFORE UPDATE ON PRODUIT
FOR EACH ROW
DECLARE
    CURSOR livree_stock IS 
        SELECT * FROM Livraison_Commande_Produit
        INNER JOIN PRODUIT ON Livraison_Commande_Produit.NO_PRODUIT = PRODUIT.REF_PRODUIT;
    
    v_ldp_livree Livraison_Commande_Produit.QUANTITE_LIVREE%TYPE;
    v_p_stock Produit.QUANTITE_STOCK%TYPE;
    v_p_ref Produit.REF_PRODUIT%TYPE;
BEGIN
   OPEN livree_stock;
   LOOP
        FETCH livree_stock INTO v_ldp_livree, v_p_stock, v_p_ref;

        IF v_ldp_livree <= v_p_stock THEN 
         UPDATE PRODUIT
         SET QUANTITE_SEUIL = v_p_stock - v_ldp_livree
         WHERE REF_PRODUIT = v_p_ref; 

        EXIT WHEN livree_stock%NOTFOUND; 
   
   ELSE RAISE E_STOCK_INSUFFISANT;
   END IF;

   END LOOP

   CLOSE livree_stock;

EXCEPTION
   WHEN E_STOCK_INSUFFISANT THEN
         RETURN 1; -- Idk what to do with error
END;

-- -----------------------------------------------------------------------------



-- -----------------------------------------------------------------------------
-- Question 2
-- -----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_command_stock
AFTER UPDATE OF QUANTITE_STOCK ON Produit
FOR EACH ROW

BEGIN

   SELECT * FROM Produit
   
   IF :OLD.Produit.QUANTITE_STOCK < :OLD.Produit.QUANTITE_SEUIL THEN
   :NEW.Approvisionnement.QUANTITE_APPROVIS := OLD.Produit.QUANTITE_SEUIL * 1.1;
   :NEW.Approvisionnement.DATE_CMD_APPROVIS := *--DATE_AUJOURDHUI--*;  -- IL faut mettre la date d'aujourd'huis
   :NEW.Approvisionnement.STATUS := 'EN_COURS';
   :NEW.Approvisionnement.NO_PRODUIT := OLD.Produit.REF_PRODUIT;
   :NEW.Approvisionnement.CODE_FOURNISSEUR := OLD.Produit.CODE_FOURNISSEUR_PRIORITAIRE;
   
   END IF;
   RETURN
END;


-- Il faut aussi Implémenter la requête mettant en action le déclencheur. Pour cela, réduisez la quantité en stock du
-- produit pour qu’elle soit plus basse que le seuil. Mettez également la requête montrant le tuple ajouté dans la
-- table Approvisionnement.

-- verifier qu'il n'y a pas deja de requete d'approvisionnemnt
-- quand la commande est approvisionne, il faut enlever la ligne de requete d'approvisionne

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



-- -----------------------------------------------------------------------------
-- Question 6
-- -----------------------------------------------------------------------------



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


