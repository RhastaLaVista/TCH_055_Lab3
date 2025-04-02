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


