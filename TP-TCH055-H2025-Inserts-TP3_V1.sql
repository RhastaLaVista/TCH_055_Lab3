-- ===================================================================
-- Authors : El Hachemi Alikacem, Pamella Kissok, Inoussa Legrene, Amal Ben Abdallah
-- Date Création : 20 Mars 2023
-- Date Modification : 12 Mars 2025
-- Version 1.0
-- Insertions dans : 
--      Mois 
--      Produit
--      Client 
--      Adresse
--      Fournisseur
--      Categorie 
--      Produit_Fournisseur 
--      Produit_Fournisseur
--      Commande 
--      Livraison_Commande_Produit
--      Paiement 
--      Facture
-- Satisfaction
-- ====================================================================
-- Initialisation de la table MOIS (comme une enum�ration) 
-- ------------------------------------------------------
INSERT INTO MOIS VALUES( 1, 'janvier' ) ; 
INSERT INTO MOIS VALUES( 2, 'f�vrier' ) ; 
INSERT INTO MOIS VALUES( 3, 'mars' ) ; 
INSERT INTO MOIS VALUES( 4, 'avril' ) ; 
INSERT INTO MOIS VALUES( 5, 'mai' ) ; 
INSERT INTO MOIS VALUES( 6, 'juin' ) ; 
INSERT INTO MOIS VALUES( 7, 'juillet' ) ; 
INSERT INTO MOIS VALUES( 8, 'aout' ) ; 
INSERT INTO MOIS VALUES( 9, 'septembre' ) ; 
INSERT INTO MOIS VALUES( 10, 'octobre' ) ; 
INSERT INTO MOIS VALUES( 11, 'novembre' ) ; 
INSERT INTO MOIS VALUES( 12, 'd�cembre' ) ; 


-- --------------------------------------------------------------------
INSERT INTO Adresse VALUES (1 , 123 , 'rue principale' , 'Montreal' , 'CANADA' , 'H1H 2H2' ) ; 
INSERT INTO Adresse VALUES (2 , 345 , '2eme avenue' , 'Montreal' , 'CANADA' , 'H2H 2H2' ) ; 
INSERT INTO Adresse VALUES (3 , 567 , 'rue du Temple' , 'Quebec' , 'CANADA' , 'Q3H 2H2' ) ; 
INSERT INTO Adresse VALUES (4 , 789 , 'rue des tulipes' , 'Trois-Rivi�res' , 'CANADA' , 'T4H 2H2' ) ; 
INSERT INTO Adresse VALUES (5 , 12 , 'rue Peel' , 'Montreal' , 'CANADA' , 'H5H 2H2' ) ; 
INSERT INTO Adresse VALUES (6 , 13 , 'rue Caron' , 'Montreal' , 'CANADA' , 'H6H 2H2' ) ; 
INSERT INTO Adresse VALUES (7 , 14 , 'rue Peel' , 'Montreal' , 'CANADA' , 'H7H 2H2' ) ; 
INSERT INTO Adresse VALUES (8 , 124 , 'rue Mozart' , 'Sherbrook' , 'CANADA' , 'SH2 7S2' ) ; 
INSERT INTO Adresse VALUES (9 , 125 , 'rue notre-dame' , 'Montreal' , 'CANADA' , 'H9H 2H2' ) ; 
INSERT INTO Adresse VALUES (10 , 126 , 'rue McGill' , 'Montreal' , 'CANADA' , 'H1G 2H2' ) ; 

-- INSETION SANS PAYS (valeur par d�faut) 
INSERT INTO Adresse (id_adresse , no_civique ,  nom_rue 	,  ville , code_postal) 
VALUES (11 , 127 , 'rue Mozart' , 'Montreal'  , 'H3G 2H2' ) ; 
-- SELECT * FROM Adresse ; 

-- -----------------------------------------------------------------------------
-- Insertion des clients 
--
-- DELETE FROM Client ; 

INSERT INTO Client (no_client, nom , prenom , telephone , id_adresse ) 
    VALUES (100 , 'tremblay' , 'michel'	, '514 123 4578' , 1) ;
INSERT INTO Client (no_client, nom , prenom , telephone , id_adresse )
    VALUES (101 , 'kacem'    , 'ali'       , '514 321 2323' , 2) ;
INSERT INTO Client (no_client, nom , prenom , telephone , id_adresse )
    VALUES (102 , 'Polo'     , 'marco'     , '514 321 6565' , 3) ;
INSERT INTO Client (no_client, nom , prenom , telephone , id_adresse )
    VALUES (103 , 'Jean'     , 'jardin'    , '514 987 1234' , 4) ;
INSERT INTO Client (no_client, nom , prenom , telephone , id_adresse )
    VALUES (104 , 'Dupond'   , 'Paul'      , '514 121 4545'  , 1) ;
INSERT INTO Client (no_client, nom , prenom , telephone , id_adresse )
    VALUES (105 , 'Kim'      , 'marta'     , '514 111 6556' , 6) ;

-- SELECT * FROM Client ;


-- -----------------------------------------------------------------------------
-- Insertion des Founisseurs 
-- DELETE FROM Founisseur ; 
INSERT INTO  Fournisseur VALUES (50 , 'TOUT-INFORMATIQUE' , '514 871 7701' , 7) ; 
INSERT INTO  Fournisseur VALUES (51 , 'MEGA TECH'         , '514 872 7702' , 8) ; 
INSERT INTO  Fournisseur VALUES (52 , 'Infosys'           , '514 873 7703' , 9) ; 
INSERT INTO  Fournisseur VALUES (53 , 'Hardware Solution' , '514 874 7704' , 10) ; 
INSERT INTO  Fournisseur VALUES (54 , 'ONIX'              , '514 875 7705' , 11) ; 
 
-- SELECT * FROM Fournisseur ; 


-- -----------------------------------------------------------------------------
-- Insertion Cat�gorie 
-- 

INSERT INTO Categorie VALUES ('ORDINATEUR' , NULL ) ; 
INSERT INTO Categorie VALUES ('PC-BUREAU' , 'ORDINATEUR' ) ; 
INSERT INTO Categorie VALUES ('LAPTOP' , 'ORDINATEUR' ) ; 
INSERT INTO Categorie VALUES ('PERIPHERIQUE' , 'ORDINATEUR' ) ; 
INSERT INTO Categorie VALUES ('ECRAN' , 'PERIPHERIQUE' ) ; 
INSERT INTO Categorie VALUES ('STOCKAGE' , 'PERIPHERIQUE' ) ; 
INSERT INTO Categorie VALUES ('LOGICIEL' , NULL ) ; 
INSERT INTO Categorie VALUES ('OS' , 'LOGICIEL' ) ; 



-- -----------------------------------------------------------------------------
-- Insertion des promotions 
-- 
-- -----------------------------------------------------------------------------
INSERT INTO Promotion (id_promotion , nom_evenement    , reduction  , date_debut_promo  , date_fin_promo)
VALUES (90 , 'Boxing_day' , 45 , to_date('2022-12-26' , 'YYYY-MM-DD' ) , to_date('2022-12-31' , 'YYYY-MM-DD')) ; 

INSERT INTO Promotion (id_promotion , nom_evenement    , reduction  , date_debut_promo  , date_fin_promo)
VALUES (91 , 'Boxing_day' , 55 , to_date('2022-12-26' , 'YYYY-MM-DD' ) , to_date('2022-12-31' , 'YYYY-MM-DD')) ; 

INSERT INTO Promotion (id_promotion , nom_evenement    , reduction  , date_debut_promo  , date_fin_promo)
VALUES (92 , 'Reduction du Directeur' , 10 , to_date('2022-12-01' , 'YYYY-MM-DD' ) , to_date('2022-12-31' , 'YYYY-MM-DD')) ; 

INSERT INTO Promotion (id_promotion , nom_evenement    , reduction  , date_debut_promo  , date_fin_promo)
VALUES (93 , 'Vendredi noir' , 30 , to_date('2022-11-28' , 'YYYY-MM-DD' ) , to_date('2022-11-30' , 'YYYY-MM-DD' )) ; 

INSERT INTO Promotion (id_promotion , nom_evenement    , reduction  , date_debut_promo  , date_fin_promo)
VALUES (94 , 'Vendredi noir' , 40 , to_date('2022-11-28' , 'YYYY-MM-DD' ) , to_date('2022-11-30' , 'YYYY-MM-DD')) ; 



-- -----------------------------------------------------------------------------
/*
(ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
statut_produit, nom_categorie, id_promotion, code_fournisseur_prioritaire) 
*/ 
-- -----------------------------------------------------------------------------
INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion) 
VALUES ('PC2000' , 'Inspiron-5' , 'DELL' , 1320, 34 , 20 , 'PC-BUREAU' , 50 , NULL ) ;

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion)
VALUES ('PC2001' ,'Elite-X32' , 'HP' , 1430 , 23 , 5 , 'PC-BUREAU' , 51 , 90);

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion)
VALUES ('LT2010' ,'Ace Next' , 'ACER' , 999 , 16 , 6 , 'LAPTOP' , 51 , 91);

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire ,id_promotion)
VALUES ('LT2011' ,'Prolite' , 'HP' , 2100 , 20 , 8 , 'LAPTOP' , 53 , NULL);


INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire, id_promotion)
VALUES ('SC2001' ,'VS-5433' , 'viewsonic' , 475 , 35 , 15 , 'ECRAN' , 50 , 92);

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire, id_promotion)
VALUES ('SC2002' ,'Wide 390' , 'DELL' , 675 , 8 , 8 , 'ECRAN' , 52 , 92);


INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion)
VALUES ('DD2001' ,'IO-IDE' , 'IOMEGA' , 399 , 23 , 12 , 'STOCKAGE' , 52 , NULL);

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion)
VALUES ('DD2002' ,'IO-SSD' , 'IOMEGA' , 890 , 23 , 10 , 'STOCKAGE' , 53 , 94);

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion)
VALUES ('DD2003' ,'IO-SSD-S2' , 'IOMEGA' , 1100 , 5 , 5 , 'STOCKAGE' , 54 , NULL);

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion)
VALUES ('SF3001' ,'Windows 11' , 'Microsoft' , 110 , 200 , 20 , 'OS' , 52 , NULL);

INSERT INTO Produit (ref_produit, nom_produit, marque, prix_unitaire, quantite_stock, quantite_seuil, 
nom_categorie, code_fournisseur_prioritaire , id_promotion)
VALUES ('SF3002' ,'Windows 10' , 'Microsoft' , 110 , 200 , 20 , 'OS' , 52 , NULL);

-- -----------------------------------------------------------------------
-- Insertion des fournisseurs r�guliers 

INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('PC2000' , 54); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('PC2000' , 53); 

INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('PC2001' , 54); 

INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('LT2010' , 53); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('LT2010' , 50); 

INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('LT2011' , 53); 

INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('SC2001' , 52); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('SC2001' , 50); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('SC2001' , 54); 

INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('SC2002' , 51); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('DD2001' , 50); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('DD2001' , 53); 

INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('DD2002' , 50); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('DD2002' , 52); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('DD2002' , 53); 
INSERT INTO Produit_Fournisseur (no_produit , code_fournisseur) VALUES ('DD2002' , 54); 


-- -----------------------------------------------------------------------------
-- INSETION DE 6 COMMANDES 

-- Commande pour : 100 - 'tremblay' , 'michel'
INSERT INTO Commande VALUES (30 , TO_DATE ('2023-01-26' , 'YYYY-MM-DD') , 'ENCOURS' , 100 ); 

-- Commande pour : 102 - 'Polo'     , 'marco'
INSERT INTO Commande VALUES (31 , TO_DATE ('2023-01-31' , 'YYYY-MM-DD') , 'ENCOURS' , 102);  

-- Commande pour : 100 - 'tremblay' , 'michel'
INSERT INTO Commande VALUES (32 , TO_DATE ('2023-02-04' , 'YYYY-MM-DD') , 'ENCOURS' , 100);  

-- Commande pour : 103 - 'Jean'     , 'jardin'
INSERT INTO Commande VALUES (33 , TO_DATE ('2023-02-06' , 'YYYY-MM-DD') , 'ENCOURS' , 103);  

-- Commande pour : 100 - 'tremblay' , 'michel'
INSERT INTO Commande VALUES (34 , TO_DATE ('2023-02-01' , 'YYYY-MM-DD') , 'ANNULEE' , 100);  

-- Commande pour : 104 - 'Dupond'   , 'Paul'  
INSERT INTO Commande VALUES (35 , TO_DATE ('2023-02-01' , 'YYYY-MM-DD') , 'ANNULEE' , 104);  

-- Commande pour : 105 - 'Kim'      , 'marta'
INSERT INTO Commande VALUES (36 , TO_DATE ('2023-01-01' , 'YYYY-MM-DD') , 'FERMEE'  , 105);  

-- -----------------------------------------------------------------------------
-- Insertion des Items de commande
-- no_commande ,  no_produit , quantite 
-- -----------------------------------------------------------------------------
-- Commande 30 - pour 100 - 'tremblay' , 'michel'
INSERT INTO Commande_Produit VALUES (30 ,  'PC2000' , 4 ) ;  
INSERT INTO Commande_Produit VALUES (30 ,  'SC2001' , 3 ) ;  
INSERT INTO Commande_Produit VALUES (30 ,  'DD2002' , 8 ) ;  

-- Commande 31 Commande pour : 102 - 'Polo'     , 'marco'
INSERT INTO Commande_Produit VALUES (31 , 'PC2000'  , 2 ) ;
INSERT INTO Commande_Produit VALUES (31 , 'LT2011'  , 4 ) ;  

-- Commande 32 pour : 100 - 'tremblay' , 'michel'
INSERT INTO Commande_Produit VALUES (32 , 'LT2011'  , 2 ) ;  
INSERT INTO Commande_Produit VALUES (32 , 'SC2002'  , 5 ) ;  

-- Commande 33 pour 103 - 'Jean'     , 'jardin'
INSERT INTO Commande_Produit VALUES (33 , 'DD2001'  , 3 ) ;  



-- Commande 34  pour 100 - 'tremblay' , 'michel' (ANNUL�E)
INSERT INTO Commande_Produit VALUES (34 ,  'SC2002' , 4 ) ;  

-- Commande 35 pour : 104 - 'Dupond'   , 'Paul'   (ANNUL�E)
INSERT INTO Commande_Produit VALUES (35 , 'DD2001'  , 8 ) ;  
INSERT INTO Commande_Produit VALUES (35 , 'SC2002'  , 2 ) ;  

-- Commande 36 pour : 105 - 'Kim'      , 'marta' (Ferm�e)
INSERT INTO Commande_Produit VALUES (36 , 'LT2011'  , 1 ) ;  
INSERT INTO Commande_Produit VALUES (36 , 'DD2001'  , 4 ) ;  

-- -----------------------------------------------------------------------------
-- Insetion de livraison 
-- no_livraison, date_livraison 
-- -----------------------------------------------------------------------------
-- Livraison des commandes : 30 et 32 
INSERT INTO Livraison VALUES (50021 , TO_DATE('2023-02-15' , 'YYYY-MM-DD')) ; 

-- Livraison de la commande 31 (livraison de toute la commande) 
INSERT INTO Livraison VALUES (50022 , TO_DATE('2023-02-18' , 'YYYY-MM-DD')) ;  

-- Livraison de la commande 33 (li9vraison d'une partie de la commande) 
INSERT INTO Livraison VALUES (50023 , TO_DATE('2023-02-16' , 'YYYY-MM-DD')) ;  

-- -----------------------------------------------------------------------------
-- Livraison_Commande_Produit : items de la livraison 
-- no Livraison, no commande, no produit et quantite 
-- -----------------------------------------------------------------------------

-- Livraison 50021 - 2 commandes 30 et 32. 30 est partie, 32 enti�rement 
INSERT INTO Livraison_Commande_Produit VALUES(50021 , 30 , 'PC2000' , 4) ;  -- PRIX 1320 
INSERT INTO Livraison_Commande_Produit VALUES(50021 , 30 , 'DD2002' , 2) ;  -- PRIX 890
INSERT INTO Livraison_Commande_Produit VALUES(50021 , 32 , 'LT2011' , 2) ;  -- PRIX 2100
INSERT INTO Livraison_Commande_Produit VALUES(50021 , 32 , 'SC2002' , 5) ;  -- PRIX 675

-- Livraison 50022 - Livraison de la commande 31. Livr�e totalement 
INSERT INTO Livraison_Commande_Produit VALUES(50022 , 31 , 'PC2000', 2) ;  -- PRIX 1320
INSERT INTO Livraison_Commande_Produit VALUES(50022 , 31 , 'LT2011', 4) ;  -- PRIX 2100

-- Livraison 50023 - commande 33. Livr�e en partie
INSERT INTO Livraison_Commande_Produit VALUES(50023 , 33 , 'DD2001', 2) ;  -- PRIX 399


-- -----------------------------------------------------------------------------
-- Insertion des Factures 
-- -----------------------------------------------------------------------------

  
INSERT INTO Facture (id_facture, remise, date_facture, montant, taxe, no_livraison) 
VALUES(60021 , 10 , to_DATE('2023-02-17' , 'YYYY-MM-DD' ), 14635 , 2195.25 , 50021); 

INSERT INTO Facture (id_facture, remise, date_facture, montant, taxe, no_livraison) 
VALUES(60022 , 0 , to_DATE('2023-02-20' , 'YYYY-MM-DD' ), 11040 , 1656  , 50022); 

INSERT INTO Facture (id_facture, remise, date_facture, montant, taxe, no_livraison) 
VALUES(60023 , 0 , to_DATE('2023-02-25' , 'YYYY-MM-DD' ), 798 , 119.7   , 50023); 


-- -----------------------------------------------------------------------------
-- Insertion des Paiements
-- -----------------------------------------------------------------------------
-- INSERT INTO Paiement (date_paiement , montant , type_paiement , no_cheque ,  nom_banque, no_carte_credit, date_expiration  , type_carte_credit , id_facture) 

-- SELECT * FROM Produit WHERE prix BETWEEN 500 AND 1000;
-- 4 paiment de la facture 60021 - Carte Visa - cash et CHEQUE. Paiements incomplet 
INSERT INTO Paiement (date_paiement , montant , type_paiement ,  no_carte_credit, date_expiration  , type_carte_credit , id_facture)  
VALUES(to_DATE('2023-02-20' , 'YYYY-MM-DD') , 3500 , 'CREDIT' , '4224565699991234' , to_DATE('2023-10-28' , 'YYYY-MM-DD') , 'VISA' , 60021) ; 

INSERT INTO Paiement (date_paiement , montant , type_paiement , id_facture) 
VALUES(to_DATE('2023-02-25' , 'YYYY-MM-DD' ) ,  1750 , 'CASH' , 60021 ) ; 

INSERT INTO Paiement (date_paiement , montant , type_paiement ,   no_cheque ,  nom_banque, id_facture) 
VALUES(to_DATE('2023-03-05' , 'YYYY-MM-DD') , 7150 , 'CHEQUE' , 10025, 'Banque du sud', 60021) ; 

INSERT INTO Paiement (date_paiement , montant , type_paiement , id_facture) 
VALUES(to_DATE('2023-02-28' , 'YYYY-MM-DD' ) ,  250 , 'CASH' , 60021 ) ; 


-- 2 paiements pour la facture 60022
INSERT INTO Paiement (date_paiement , montant , type_paiement , no_carte_credit, date_expiration  , type_carte_credit , id_facture) 
VALUES(to_DATE('2023-02-28' , 'YYYY-MM-DD' ) , 3800 , 'CREDIT' , '6565121277883311' , to_DATE('2024-12-10' , 'YYYY-MM-DD') , 'MASTERCARD' , 60022) ; 

INSERT INTO Paiement (date_paiement , montant , type_paiement ,   no_cheque ,  nom_banque, id_facture) 
VALUES(to_DATE('2023-03-08' , 'YYYY-MM-DD') , 7000 , 'CHEQUE' , 10007, 'Banque du nord', 60022) ; 


-- 1 paiement pour la facture 60023. Paiment complet en esp�ce 
INSERT INTO Paiement (date_paiement , montant , type_paiement , id_facture) 
VALUES(to_DATE('2023-03-10' , 'YYYY-MM-DD' ) , 917.70 , 'CASH' , 60023 ) ; 


-- -----------------------------------------------------------------------------
-- Insertion Satisfaction Client 
--  no_client  ref_produit  note  commentaire 
-- -----------------------------------------------------------------------------

-- Evaluation par le client 100 ('tremblay' , 'michel')
INSERT INTO Satisfaction VALUES( 100 , 'PC2000' , 5 , 'Tr�s satisfait de mon achat.' ) ; 
INSERT INTO Satisfaction VALUES( 100 , 'LT2011' , 4 , 'Op�rationnel selon mes attentes- Fait un peu de bruit' ) ; 

-- Evaluation par le client 102 ('Polo'     , 'marco') 
INSERT INTO Satisfaction VALUES(102 , 'PC2000' , 1 , 'Achat d�cevant, design limite. Probl�me lors de la livraison' ) ; 
INSERT INTO Satisfaction VALUES(102 , 'LT2011' , 3 , 'Ordinateur de bonne qualit�, probl�me avec la livraison' ) ; 

-- Evaluation par le client 103 ('Jean' , 'jardin')
INSERT INTO Satisfaction VALUES(103 , 'DD2001' , 3 , 'Produit globalement bon. Performance moyenne' ) ; 


-- =============================================================================
-- INSERTION D'une nouvelle (no 37) commande pour le client 100 (Michel Tremblay)
-- 
INSERT INTO Commande VALUES (37 , TO_DATE ('2023-02-27' , 'YYYY-MM-DD') , 'ENCOURS' , 100 ); 


INSERT INTO Commande_Produit VALUES (37 , 'DD2001' , 2) ;  
INSERT INTO Commande_Produit VALUES (37 , 'LT2011' , 1) ;  
INSERT INTO Commande_Produit VALUES (37 , 'PC2000' , 4) ;
INSERT INTO Commande_Produit VALUES (37 , 'DD2002' , 2) ;  
INSERT INTO Commande_Produit VALUES (37 , 'SC2001' , 3) ;  


COMMIT; 
