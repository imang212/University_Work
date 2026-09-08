# Ukázková úloha V.1. Návrh rezervačního systému pro malé hotely a penziony

**Popis úlohy:** Navrhněte aplikaci pro rezervaci pokojů v malých hotelech a penzionech. Aplikace bude zahrnovat funkce pro vyhledávání pokojů, rezervaci, správu profilu uživatele a možnost poskytování zpětné vazby na ubytování.

**Požadavky na odevzdání:** Řešitel odevzdá softwarovou dokumentaci, která bude obsahovat systémový návrh ve formátu UML diagramů a snímky grafického prototypu ze softwaru Figma nebo drátěný model z libovolné grafické aplikace.

**Povinné UML diagramy:** Diagram případů užití, Sekvenční diagram, Diagram Tříd.
Návrh uživatelského rozhraní musí obsahovat alespoň: hlavní stránku, stránku rezervace, profil uživatele a formulář pro zpětnou vazbu. Návrh grafického rozhraní můžete realizovat ve formě webové, stolní nebo mobilní aplikace.

**Uživatelské požadavky:**

**Vyhledávání a rezervace pokojů:**
- Umožnit uživatelům vyhledávat pokoje podle data, počtu osob, ceny a dalších specifikací (např. wi-fi, snídaně).
- Poskytnout detailní informace o pokoji, včetně fotografií, popisu vybavení a recenzí od předešlých hostů.
- Umožnit uživatelům provést rezervaci pokoje, vyplnit potřebné údaje (jako jméno, kontakt, případné požadavky) a potvrdit rezervaci.\

**Správa profilu uživatele:**
- Umožnit uživatelům vytvořit a spravovat svůj uživatelský profil, včetně osobních informací.
- Nabídnout možnost změny hesla a osobních údajů.
- Poskytnout přehled předchozích a naplánovaných rezervací s možností zrušení nebo úpravy rezervace.

**Zpětná vazba a hodnocení:**
- Umožnit uživatelům hodnotit a psát recenze na ubytování.
- Zobrazit hodnocení a recenze hotelu/penzionu.
- Poskytnout hotelu/penzionu nástroj pro reagování na recenze a zpětnou vazbu.\

**Integrace platebního systému:**
- Nabídnout různé platební možnosti, jako jsou kreditní karty, bankovní převody a online platební platformy.\

**Uživatelské rozhraní a navigace:**
- Vytvořit intuitivní a přívětivé uživatelské rozhraní pro snadnou navigaci a používání aplikace.

# UML diagramy — Rezervační systém pro malé hotely a penziony
Tři povinné diagramy dle zadání úlohy V.1: **diagram případů užití**, **sekvenční diagram** a **diagram tříd**.

Kód je v jazyce PlantUML. Vykreslíte ho zdarma na https://www.plantuml.com/plantuml/uml/, nebo pomocí rozšíření "PlantUML" ve VS Code / IntelliJ.

---

## 1. Diagram případů užití (Use Case Diagram)

Aktéři: **Host** (nepřihlášený návštěvník), **Registrovaný uživatel**, **Provozovatel ubytování**, externí **Platební systém**.

```plantuml
@startuml UseCase
left to right direction

actor "Host" as Guest
actor "Registrovaný uživatel" as User
actor "Provozovatel ubytování" as Admin
actor "Platební systém" as Payment

Guest --> (Registrace)
Guest --> (Přihlášení)

User --> (Vyhledat pokoj)
User --> (Zobrazit detail pokoje)
User --> (Vytvořit rezervaci)
User --> (Upravit rezervaci)
User --> (Zrušit rezervaci)
User --> (Spravovat profil)
User --> (Napsat recenzi)
User --> (Zobrazit recenze)

(Vytvořit rezervaci) ..> (Provést platbu) : <<include>>
(Provést platbu) --> Payment

Admin --> (Reagovat na recenzi)
Admin --> (Spravovat nabídku pokojů)

@enduml
```

**Poznámka k obsahu:** Vazba `<<include>>` mezi *Vytvořit rezervaci* a *Provést platbu* vyjadřuje, že platba je nedílnou součástí dokončení rezervace (bod 4 zadání – integrace platebního systému). Můžete přidat i `<<extend>>` vazbu mezi *Vytvořit rezervaci* a *Napsat recenzi* pouze pokud chcete zdůraznit, že recenzi lze psát jen po dokončeném pobytu.

---

## 2. Sekvenční diagram (Sequence Diagram)
Scénář: **vytvoření rezervace pokoje včetně platby.**
```plantuml
@startuml Sequence
actor Uživatel
participant "UI (Frontend)" as UI
participant "RezervačníController" as Controller
participant "PokojService" as RoomService
participant "RezervaceService" as ResService
participant "PlatebníSlužba" as Payment
database "Databáze" as DB

Uživatel -> UI: Vyhledá pokoj (datum, počet osob)
UI -> Controller: searchRooms(criteria)
Controller -> RoomService: findAvailableRooms(criteria)
RoomService -> DB: SELECT dostupné pokoje
DB --> RoomService: seznam pokojů
RoomService --> Controller: dostupné pokoje
Controller --> UI: zobrazit výsledky
Uživatel -> UI: Vybere pokoj a potvrdí rezervaci

UI -> Controller: createReservation(userId, roomId, dates)
Controller -> ResService: createReservation(...)
ResService -> DB: INSERT rezervace (status = čeká_na_platbu)

Controller -> Payment: processPayment(amount, method)
Payment --> Controller: potvrzení platby

Controller -> ResService: confirmReservation(reservationId)
ResService -> DB: UPDATE status = potvrzeno
Controller --> UI: rezervace potvrzena
UI --> Uživatel: Zobrazit potvrzení rezervace

@enduml
```

**Poznámka k obsahu:** Diagram odpovídá bodu 1 (rezervace pokoje) a bodu 4 (platební systém) zadání. Pokud chcete diagram rozšířit, můžete přidat alternativní větev (`alt`/`else` blok v PlantUML) pro případ neúspěšné platby.

---

## 3. Diagram tříd (Class Diagram)

```plantuml
@startuml Class

class Uzivatel {
  -id: int
  -jmeno: string
  -email: string
  -heslo: string
  -telefon: string
  +registrovat()
  +prihlasit()
  +upravitProfil()
}

class Ubytovani {
  -id: int
  -nazev: string
  -adresa: string
  -popis: string
  +pridatPokoj(pokoj)
}

class Pokoj {
  -id: int
  -cislo: string
  -typ: string
  -cena: decimal
  -kapacita: int
  -vybaveni: string[]
  +jeDostupny(datumOd, datumDo): bool
}

class Rezervace {
  -id: int
  -datumOd: date
  -datumDo: date
  -pocetOsob: int
  -stav: StavRezervace
  +vytvorit()
  +zrusit()
  +upravit()
}

class Platba {
  -id: int
  -castka: decimal
  -metoda: string
  -stav: StavPlatby
  +zpracovat()
}

class Recenze {
  -id: int
  -hodnoceni: int
  -text: string
  -datum: date
  +vytvorit()
}

class Odpoved {
  -id: int
  -text: string
  -datum: date
}

enum StavRezervace {
  CEKA_NA_PLATBU
  POTVRZENA
  ZRUSENA
  DOKONCENA
}

enum StavPlatby {
  CEKA
  USPESNA
  NEUSPESNA
}

Uzivatel "1" -- "0..*" Rezervace : vytváří
Rezervace "1" -- "1" Pokoj : týká se
Pokoj "0..*" -- "1" Ubytovani : patří do
Uzivatel "1" -- "0..*" Recenze : píše
Recenze "1" -- "0..1" Odpoved : má
Ubytovani "1" -- "0..*" Recenze : je hodnoceno
Rezervace "1" -- "1" Platba : generuje
Rezervace -- StavRezervace
Platba -- StavPlatby

@enduml
```

**Poznámka k obsahu:** Třídy pokrývají všechny funkční oblasti zadání — uživatele a profil (bod 2), pokoje a ubytování (bod 1), rezervaci a platbu (bod 1, 4) a recenze s možností odpovědi provozovatele (bod 3). Enum `StavRezervace` a `StavPlatby` odpovídají stavovým přechodům, které byste jinak museli řešit samostatným stavovým diagramem (ten ale zadání pro tuto úlohu nevyžaduje — je povinný jen u úlohy V.2).

---

### Tip k odevzdání
Do dokumentace vložte u každého diagramu:
1. Vyrenderovaný obrázek (PNG/SVG export z PlantUML).
2. Krátký textový popis (2–3 věty), co diagram znázorňuje a proč jste zvolili dané třídy/aktéry/kroky.