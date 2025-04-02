-- ===================================================================
-- Authors : El Hachemi Alikacem, Pamella Kissok, Inoussa Legrene, Amal Ben Abdallah
-- Date Création : 20 Mars 2023
-- Date Modification : 12 Mars 2025
-- Version 1.0
-- Cr�ation de la BD pour la gestion des ventes : Travail pratique I et II
-- Cr�ation des tables : 
--      Adresse 
--      Client  
--      Categorie 
--      Promotion 
--      Statistique_Vente 
--      Mois 
--      Produit 
--      Fournisseur 
--      Produit_Fournisseur 
--      Commande_Produit 
--      Commande 
--      Livraison_Commande_Produit 
--      Livraison 
--      Approvisionnement 
--      Paiement   
--      Satisfaction 
--      Facture 
--
-- ====================================================================

-- Suppression des tables 
DROP TABLE  Adresse CASCADE CONSTRAINTS ;
DROP TABLE  Client CASCADE CONSTRAINTS  ;
DROP TABLE Categorie CASCADE CONSTRAINTS;
DROP TABLE Promotion CASCADE CONSTRAINTS;
DROP TABLE Statistique_Vente CASCADE CONSTRAINTS;
DROP TABLE Mois CASCADE CONSTRAINTS;
DROP TABLE  Produit CASCADE CONSTRAINTS;
DROP TABLE  Fournisseur CASCADE CONSTRAINTS;
DROP TABLE  Produit_Fournisseur CASCADE CONSTRAINTS;
DROP TABLE  Commande_Produit CASCADE CONSTRAINTS;
DROP TABLE  Commande CASCADE CONSTRAINTS;
DROP TABLE  Livraison_Commande_Produit CASCADE CONSTRAINTS;
DROP TABLE  Livraison CASCADE CONSTRAINTS;
DROP TABLE  Approvisionnement CASCADE CONSTRAINTS;
DROP TABLE  Paiement CASCADE CONSTRAINTS;
DROP TABLE  Satisfaction CASCADE CONSTRAINTS;
DROP TABLE  Facture CASCADE CONSTRAINTS;

-- 
-- Table Adresse 
CREATE TABLE Adresse 
(
   id_adresse  	NUMBER(5) PRIMARY KEY,
   no_civique 	NUMBER(6)   NOT NULL,
   nom_rue 		VARCHAR2(20) NOT NULL,
   ville 		VARCHAR2(20) NOT NULL,   
   pays         VARCHAR2(20) DEFAULT 'CANADA' NOT NULL,   
   code_postal  VARCHAR2(8)  NOT NULL 
);

-- Table Client 
CREATE TABLE Client
(
   no_client  	NUMBER(5) PRIMARY KEY,
   nom  	    VARCHAR2(30) NOT NULL,
   prenom  		VARCHAR2(30) NOT NULL,
   telephone 	VARCHAR2(15) NOT NULL,   
   id_adresse   NUMBER(5) NOT NULL References Adresse(id_adresse)    
);

-- Cr�ation 
CREATE TABLE  Fournisseur 
(
   code_fournisseur NUMBER(5) PRIMARY KEY,
   nom_fournisseur  VARCHAR2(50) NOT NULL,
   telephone        VARCHAR2(15) NOT NULL,
   id_dresse        NUMBER(5) NOT NULL References Adresse(id_adresse)    
);

-- Table Categorie 
CREATE TABLE Categorie 
(
    nom_categorie VARCHAR2(20)PRIMARY KEY, 
    nom_categorie_mere VARCHAR2(20) REFERENCES Categorie(nom_categorie) 
);

-- Table Promotion 
CREATE TABLE Promotion
(
    id_promotion     NUMBER(5) PRIMARY KEY,
    nom_evenement    VARCHAR2(50) NOT NULL , 
    reduction        NUMBER(2) NOT NULL CHECK (reduction BETWEEN 0 AND 80), 
    date_debut_promo Date NOT NULL ,
    date_fin_promo   Date NOT NULL, 
    
    CHECK (date_debut_promo <= date_fin_promo) 
 );

-- Table Produit 
CREATE TABLE Produit 
(
   ref_produit 	      VARCHAR2(6) PRIMARY KEY 
   Constraint verif_rep_produit CHECK (LENGTH(ref_produit) = 6), 
   
   nom_produit        VARCHAR2(30) NOT NULL,
   marque             VARCHAR2(20) NOT NULL,
   prix_unitaire      NUMBER(8,2) CHECK (prix_unitaire >= 0), 
   
   quantite_stock     NUMBER(6)   DEFAULT 0 NOT NULL 
        CONSTRAINT verif_q_stock CHECK (quantite_stock >=0), 
        
   quantite_seuil     NUMBER(6) DEFAULT 0 NOT NULL 
        CONSTRAINT verif_q_seuil CHECK (quantite_seuil >=0),
        
   statut_produit     VARCHAR2(15) DEFAULT 'ENVENTE' 
         CONSTRAINT verif_statut CHECK (statut_produit IN ('ENVENTE' , 'DISCONTINUE' , 'HORSCATALOGUE')),
         
   nom_categorie      VARCHAR2(20) NOT NULL REFERENCES Categorie(nom_categorie),
   id_promotion       NUMBER(5) REFERENCES Promotion(id_promotion) , 
   code_fournisseur_prioritaire NUMBER(5) NOT NULL REFERENCES Fournisseur(code_fournisseur) 
);

-- Table Mois 
CREATE TABLE  Mois
(
    code_mois NUMBER(2) Primary Key, 
    label_mois VARCHAR2(20) NOT NULL  
) ; 

-- 
CREATE TABLE  Statistique_Vente
(
    ref_produit VARCHAR2(6) NOT NULL REFERENCES Produit(ref_produit), 
    code_mois NUMBER(2) NOT NULL REFERENCES Mois(code_mois), 
    quantite_vendue NUMBER(6) NOT NULL , 
    PRIMARY KEY(ref_produit , code_mois) 
);

CREATE TABLE Satisfaction 
(
   no_client NUMBER(5) NOT NULL REFERENCES Client(no_client) ON DELETE SET NULL, 
   ref_produit VARCHAR2(6) NOT NULL REFERENCES Produit(ref_produit), 
   note NUMBER(1) NOT NULL CHECK (note BETWEEN 1 AND 5), 
   commentaire VARCHAR2(255), 
   
   PRIMARY KEY(no_client , ref_produit) 
) ; 

CREATE TABLE  Produit_Fournisseur
(
   no_produit 	      VARCHAR2(6) NOT NULL REFERENCES Produit(ref_produit), 
   code_fournisseur   NUMBER(5) NOT NULL REFERENCES Fournisseur(code_fournisseur), 
   PRIMARY KEY(no_produit ,code_fournisseur ) 
) ;

-- 
CREATE TABLE  Commande
(
   no_commande NUMBER(5) PRIMARY KEY,
   date_commande DATE NOT NULL,
   statut VARCHAR2(10) DEFAULT 'ENCOURS' NOT NULL CHECK (statut IN('ENCOURS', 'ANNULEE' , 'FERMEE')),
   no_client  NUMBER(5) NOT NULL REFERENCES Client(no_client) ON DELETE SET NULL
);

--
CREATE TABLE Commande_Produit
(
   no_commande   NUMBER(5) NOT NULL REFERENCES Commande(no_commande),
   no_produit 	 VARCHAR2(6) NOT NULL REFERENCES Produit(ref_produit),
   quantite_cmd NUMBER(6) NOT NULL CHECK (quantite_cmd > 0),
   PRIMARY KEY(no_commande , no_produit)
) ;

-- 
CREATE TABLE  Livraison
(
   no_livraison   NUMBER(5) PRIMARY KEY,
   date_livraison DATE NOT NULL
);

-- 
CREATE TABLE Livraison_Commande_Produit
(
   no_livraison     NUMBER(5) NOT NULL REFERENCES Livraison,
   no_commande      NUMBER(5) NOT NULL REFERENCES Commande,
   no_produit       VARCHAR2(6) NOT NULL REFERENCES Produit,
   quantite_livree  NUMBER(6) NOT NULL CHECK (quantite_livree > 0),
   PRIMARY KEY(no_livraison , no_commande , no_produit)
) ;

CREATE TABLE Approvisionnement 
(
   no_produit         VARCHAR2(6) NOT NULL REFERENCES Produit,
   code_fournisseur   NUMBER(5) NOT NULL REFERENCES Fournisseur, 

   quantite_approvis  NUMBER(6) NOT NULL CHECK (quantite_approvis > 0),
   date_cmd_approvis  date NOT NULL , 
   statut VARCHAR2(10) DEFAULT 'ENCOURS' NOT NULL CHECK (statut IN ('ENCOURS' ,'ANNULEE' ,'LIVREE' ) ) ,
   PRIMARY KEY(no_produit , code_fournisseur)
) ;

-- 
CREATE TABLE Facture 
(
  id_facture    NUMBER(5) PRIMARY KEY, 
  remise        NUMBER(2) DEFAULT 0 CHECK (remise BETWEEN 0 AND 20) ,
  date_facture  DATE NOT NULL, 
  montant       NUMBER(8,2),
  taxe          NUMBER(6,2),
  no_livraison  NUMBER(5) REFERENCES Livraison(no_livraison)
) ; 

-- 
CREATE TABLE Paiement 
( 
   id_paiement       NUMBER(5) PRIMARY KEY, 
   date_paiement     DATE NOT NULL, 
   montant           NUMBER(8,2) NOT NULL CHECK (montant > 0), 
   type_paiement     VARCHAR2(20) NOT NULL CHECK (type_paiement IN ('CASH' , 'CHEQUE' , 'CREDIT')), 
   no_cheque         NUMBER(6),
   nom_banque        VARCHAR2(30), 
   no_carte_credit   VARCHAR2(16) CHECK (LENGTH(no_carte_credit)=16) , 
   date_expiration   Date NULL,
   type_carte_credit VARCHAR2(20) CHECK (type_carte_credit IN ('VISA', 'MASTERCARD' , 'AMEX')),
   id_facture        NUMBER(5) NOT NULL REFERENCES Facture(id_facture), 
   
   CONSTRAINT Verif_expriration_CC CHECK ( date_expiration >= date_paiement + 30) 
) ;
