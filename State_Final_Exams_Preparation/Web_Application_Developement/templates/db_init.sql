CREATE TABLE Kategorie (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nazev VARCHAR(100) NOT NULL
);

CREATE TABLE Produkty (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nazev VARCHAR(255) NOT NULL,
    mnozstvi_skladem INT NOT NULL DEFAULT 0,
    cena DECIMAL(10,2) NOT NULL,
    kategorie_id INT,
    FOREIGN KEY (kategorie_id) REFERENCES Kategorie(id) ON DELETE SET NULL
);

CREATE TABLE Objednavky (
    id INT AUTO_INCREMENT PRIMARY KEY,
    datum_vytvoreni DATETIME DEFAULT CURRENT_TIMESTAMP,
    zakaznik_email VARCHAR(255) NOT NULL
);
-- položky objednávky (tzv. spojovací tabulka pro vztah M:N)
CREATE TABLE Polozky_Objednavky (
    id INT AUTO_INCREMENT PRIMARY KEY,
    objednavka_id INT NOT NULL,
    produkt_id INT NOT NULL,
    kusy INT NOT NULL,
    cena_za_kus DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (objednavka_id) REFERENCES Objednavky(id) ON DELETE CASCADE,
    FOREIGN KEY (produkt_id) REFERENCES Produkty(id) ON DELETE RESTRICT
);