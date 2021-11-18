--CREATE DATABASE magasin_stock;

USE magasin_stock;

DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS achat;
DROP TABLE IF EXISTS produit;
DROP TABLE IF EXISTS categorie;

CREATE TABLE categorie(
	categorie_id INT PRIMARY KEY IDENTITY(1,1),
	nom VARCHAR(50) NOT NULL
);

CREATE TABLE produit(
	produit_id INT PRIMARY KEY IDENTITY(1,1),
	nom VARCHAR(50) NOT NULL,
	prix DECIMAL(6,2) NOT NULL,
	FK_categorie_id INT NOT NULL,
	FOREIGN KEY(FK_categorie_id) REFERENCES categorie(categorie_id)
);

CREATE TABLE achat(
	achat_id INT PRIMARY KEY IDENTITY(1,1),
	date_achat DATE NOT NULL,
	FK_produit_id INT NOT NULL,
	FOREIGN KEY(FK_produit_id) REFERENCES produit(produit_id)
);

CREATE TABLE stock(
	stock_id INT PRIMARY KEY IDENTITY(1,1),
	quantity INT,
	FK_produit_id INT NOT NULL,
	FOREIGN KEY(FK_produit_id) REFERENCES produit(produit_id)
);

INSERT INTO categorie(nom) VALUES
	('informatique'),
	('smartphone'),
	('jeux video');

SELECT * FROM categorie;

INSERT INTO produit(nom, prix, FK_categorie_id)VALUES
	('ordinateur fixe', 1519.99, 1),
	('ordinateur protable', 857.95, 1),
	('disque dur', 99.99, 1),
	('iphone', 990.90, 2),
	('samsung', 850.99, 2),
	('xiaomi', 580, 2),
	('zelda BOTW', 60, 3),
	('the last of us', 69.99, 3),
	('god of war', 40, 3);

SELECT * FROM produit;

-----Remplissage table Stock-----

DECLARE @produit_id INT;
DECLARE produit_cursor SCROLL CURSOR FOR SELECT produit_id FROM produit;

OPEN produit_cursor;
FETCH FIRST FROM produit_cursor INTO @produit_id;

DECLARE @i INT = 0;
WHILE(@i < (SELECT COUNT(*) FROM produit))
BEGIN
	INSERT INTO stock(FK_produit_id, quantity)
	VALUES(@produit_id, 25);
	SET @i = @i + 1;
	FETCH NEXT FROM produit_cursor INTO @produit_id;
END
GO

CLOSE produit_cursor;
DEALLOCATE produit_cursor;

SELECT * FROM stock;

-----Remplissage table Achat-----

INSERT INTO achat(date_achat, FK_produit_id)VALUES
	('2018-01-10', 9),
	('2018-01-24', 8),
	('2019-01-01', 9),
	('2020-03-16', 5),
	('2019-05-02', 4),
	('2019-06-15', 4),
	('2020-06-20', 6),
	('2019-07-05', 7),
	('2019-07-12', 2),
	('2020-07-15', 3),
	('2019-09-20', 8),
	('2019-09-25', 1),
	('2019-11-08', 3),
	('2020-11-14', 1),
	('2019-11-16', 6),
	('2019-12-31', 2),
	('2021-12-06', 7),
	('2021-12-15', 5);

SELECT * FROM achat;

-----Mise à jour table Stock-----

DECLARE @FK_produit_id INT;
DECLARE achat_cursor SCROLL CURSOR FOR SELECT [FK_produit_id] FROM [achat];

OPEN achat_cursor;
FETCH FIRST FROM achat_cursor INTO @FK_produit_id;

BEGIN
	DECLARE @i INT = 0;
	WHILE (@i < (SELECT COUNT(*) FROM achat))
	BEGIN
		UPDATE Stock
			SET quantity = quantity - 1 WHERE FK_produit_id = @FK_produit_id;
		SET @i = @i + 1;
		FETCH NEXT FROM achat_cursor INTO @FK_produit_id;
	END
END
GO

CLOSE achat_cursor;
DEALLOCATE achat_cursor;

-----Requete stocks produits pour une categorie -----

DROP PROCEDURE IF EXISTS sp_StockProduit
GO

CREATE PROCEDURE sp_StockProduit
@categorie_id INT
AS
BEGIN
	SELECT stock.quantity, categorie.nom, produit.nom FROM stock
	INNER JOIN produit ON stock.FK_produit_id = produit_id
	INNER JOIN categorie on categorie_id = produit.FK_categorie_id
	WHERE FK_categorie_id = @categorie_id;
END;
GO

EXECUTE sp_StockProduit 2;
GO