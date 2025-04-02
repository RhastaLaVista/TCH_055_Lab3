-- ===================================================================
-- Authors : El Hachemi Alikacem, Pamella Kissok, Inoussa Legrene, Amal Ben Abdallah
-- Date Création : 20 Mars 2023
-- Date Modification : 12 Mars 2025
-- Version 1.0
-- Cr�ation des Triggers 
--      TRG_verif_expir_CC
--
-- ====================================================================
/*
 DROP TRIGGER TRG_verif_expir_CC ; 
 DROP TRIGGER TRG_empeche_suppr_Produit ;
 DROP TRIGGER TRG_Paiement_Identite ; 
 DROP SEQUENCE Seq_ID_Paiement; 
*/

DROP SEQUENCE Seq_ID_Paiement ; 
-- ===================================================================
-- DECLENCHEUR: TRG_verif_expire_CC
-- TABLE: Paiement
-- TYPE: Avant Insertion ou modification 
-- DESCRIPTION:
--  On doit s'assurer que la date d'expiration de la carte de cr�dit d�passe de 30 jours 
--  la date de paiement. 
-- ====================================================================
CREATE OR REPLACE TRIGGER TRG_verif_expire_CC 
BEFORE INSERT OR UPDATE 
ON Paiement 
FOR EACH ROW 

BEGIN
    IF :NEW.date_expiration < :NEW.date_paiement + 30 THEN 
        RAISE_APPLICATION_ERROR( -20101 , 'Date Expiration doit d�passer de 30 jours la date de paiement') ; 
    END IF; 
END ; 
/

-- ===================================================================
-- DECLENCHEUR: TRG_empeche_suppr_Produit
-- TABLE: produit 
-- TYPE: Avant Suppression 
-- DESCRIPTION:
--  Emp�che la suppression d'un Produit
-- ====================================================================
/*
CREATE OR REPLACE TRIGGER TRG_empeche_suppr_Produit 
BEFORE DELETE 
ON Produit 
FOR EACH ROW
BEGIN 
   RAISE_APPLICATION_ERROR ( -20102 , 'Suppression d''un produit non autoris�e') ; 
END ;
/
*/
-- ===================================================================
-- S�quence : Seq_ID_Paiement
-- S�quence utilis�e pour l'initialisation automatique de id_paiement  
-- ====================================================================
CREATE SEQUENCE Seq_ID_Paiement START WITH 1000 INCREMENT BY 1;


-- ===================================================================
-- DECLENCHEUR: TRG_Paiement_Identite
-- TABLE: produit 
-- TYPE: Avant Suppression 
-- DESCRIPTION:
--  Emp�che la suppression d'un Produit
-- ====================================================================

CREATE OR REPLACE TRIGGER TRG_Paiement_Identite 
BEFORE INSERT ON Paiement
FOR EACH ROW
BEGIN
  SELECT Seq_ID_Paiement.nextval
  INTO   :NEW.id_paiement
  FROM   dual;
END;




