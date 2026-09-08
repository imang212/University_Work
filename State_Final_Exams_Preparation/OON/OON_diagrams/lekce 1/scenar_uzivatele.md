### 3. SCÉNÁŘ UŽIVATELE 
### Profil uživatele
#### Jméno: František, 78 let
#### Bydliště: Malá vesnice u řeky Labe, 50 obyvatel
#### Technologie: Starý tlačítkový telefon (Nokia), žádný internet, žádný smartphone.
#### Zdraví: Omezená pohyblivost, špatně slyší.
#### Situace: Žije sám, děti bydlí v Praze.

## Scénář: Povodeň  v noci na 15. června 2025.
### 22:00  - Začátek krize

#### **Co se děje:**
####  - Silné deště, voda v řece kriticky rychle stoupá.
####  - Krizový štáb vyhodnotil situaci takto: Je tu hrozba povodně a je nutná evakuace obyvatel do 2 hodin.
####  - Následuje aktivace národní krizové aplikace.

### 22:05  - První pokus o kontakt

#### **Jak systém reaguje:**
#### 1. SMS na všechna čísla v dané oblasti (Cell Broadcast)
####  - František dostane SMS VAROVÁNÍ: "Hrozba povodně. Evakuujte se do 23:30. Sraz u obecního úřadu."
####  - Přečte si ji, ale je zmatený.: "Kam mám jít? Jak se tam dostanu?(Neví, co má dělat.)"

#### 2. Push notifikace v národní krizové aplikaci
####  - František nemá smartphone  -> toto mu nefunguje

### 22:10  - Záložní systém aktivován

#### **Co pomůže Františkovi?:**
#### 3. Automatická aktivace místního rozhlasu
####  - Hlasová zpráva opakovaná každých 5 minut.: "Pozor! Pozor! Hrozba povodně. Všichni obyvatelé se co nejdříve dostavte k obecnímu úřadu. Evakuace. Opakuji..."
####  - František to slyší (I přes horší sluch, protože je to hodně hlasité.)

#### 4. Starosta dostane notifikaci na telefon
####  - Systém automaticky informoval starostu s adresami seniorů v obci.
####  - Starosta posílá místní hasiče ke každému seniorovi osobně.

### 22:25  - Evakuace

#### **Překážky:**
####  - František má problém s chůzí, nemůže rychle dojít k úřadu sám.
####  - Je tma, nemá baterku.
####  - Začíná panikařit.

#### **Řešení:**
####  - Místní hasič zaklepe na dveře: "Pane Františku, jdeme, pomohu vám do auta!"
####  - Hasič dostal z aplikace seznam všech seniorů v rizikové oblasti.
####  - František je bezpečně evakuován do místního kulturního domu na kopci.

### 22:45  - Potvrzení

#### **Zpětná vazba do systému:**
####  - Starosta potvrdí v aplikaci: "Všichni senioři evakuováni."
####  - Systém aktualizuje status a tím krizový štáb vidí, že vesnice je v bezpečí.
####  - Rodina v Praze dostane SMS.: "Váš kontakt František byl evakuován. Je v bezpečí v kulturním domě, Horní Beřkovice."

### Co fungovalo / nefungovalo

#### **Co Františka zachránilo:**
#### 1. SMS na starý telefon – Dostal základní informaci.
#### 2. Místní rozhlas – Slyšel varování i bez internetu.
#### 3. Osobní asistence – Hasič přišel osobně, protože systém identifikoval seniory v riziku.
#### 4. Redundance – Více kanálů najednou (SMS + rozhlas + osobní kontakt).

#### **Co by mohlo selhat:**
#### Kdyby byl blackout – Telefon by se nevybil a rozhlas by nefungoval.
####  - Záložní řešení: Satelitní komunikace + místní sirény na baterie
#### Kdyby systém napadli hackeři. (Vypadla by mobilní komunikace nebo krizová aplikace v mobilu.)
####  - Záložní řešení: Satelitní komunikace + osobní kontakt
#### Kdyby starosta nestihl reagovat – František by nevěděl kam má jít.
####  - Záložní řešení: Automatické volání na čísla seniorů s hlasovou zprávou.

#### Kdyby František telefon neslyšel (hluchý).
####  - Záložní řešení: Blikající světla na domech (vizuální varování).

### Klíčové poznatky pro design systému
#### 1. Více kanálů je nutnost – Nikdy nespoléhat jen na jednu technologii.
#### 2. Lidský faktor je klíčový – V krizích pomáhá osobní kontakt.
#### 3. Automatizace + lokalizace – Systém musí vědět, kdo potřebuje speciální pomoc.
#### 4. Jednoduchost zpráv – "CO dělat, KDY, KAM" – Bez složitých instrukcí.
#### 5. Zpětná vazba – Rodiny musí vědět, že jejich blízcí jsou v bezpečí.

### Doporučení pro zlepšení
####  - Blikající LED světla na domech seniorů – Automaticky blikají červeně při evakuaci.
####  - Předregistrace zranitelných osob – Databáze lidí, kteří potřebují pomoc.
####  - Satelitní telefony pro starosty. – Fungují i bez mobilní sítě.
####  - Předem připravené evakuační plány. – Každý senior dostane papírovou mapu.: "V případě povodně půjdu daný bod."