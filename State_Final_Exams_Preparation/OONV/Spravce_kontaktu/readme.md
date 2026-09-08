# Správce kontaktů (Konzolová aplikace)

Tato aplikace slouží k ukládání, prohlížení, úpravě a mazání kontaktních informací. Projekt byl vytvořen jako součást přípravy na státní závěrečnou zkoušku.

## Uživatelská příručka
Aplikace se ovládá výhradně pomocí textové konzole prostřednictvím číselného menu. 
Při startu aplikace dojde k automatickému načtení existujících kontaktů ze souboru `contacts.json`.

**Základní funkce:**
* **Přidání kontaktu:** V menu zvolte možnost `1` a zadejte jméno, telefon a e-mail oddělené čárkou.
* **Vyhledávání:** V menu zvolte možnost `2` a zadejte libovolnou část jména nebo e-mailu.
* **Krok zpět (Undo):** Pokud omylem přidáte nebo smažete kontakt, volbou `3` se poslední akce okamžitě vrátí.
* **Ukončení:** Aplikace se bezpečně ukončí a uloží data na disk volbou `4`.

## Dokumentace architektury a návrhových vzorů
Aplikace je napsána v jazyce C# a je rozdělena do dvou projektů (`.App` pro hlavní logiku a `.Tests` pro jednotkové testy). Pro zajištění čisté architektury a rozšiřitelnosti byly implementovány tři návrhové vzory:

* **Prototype (Prototyp):** 
  * *Kde se nachází:* Třída `Contact` implementující rozhraní `ICloneable`.
  * *Účel:* Umožňuje efektivní klonování instancí kontaktů v paměti bez nutnosti vytvářet je přes konstruktor. Využívá se pro rychlé vytváření podobných záznamů.
* **Command (Příkaz):** 
  * *Kde se nachází:* Rozhraní `ICommand` a třídy jako `AddContactCommand`, `DeleteContactCommand`. Logiku řídí `CommandManager`.
  * *Účel:* Zapouzdřuje všechny modifikující akce do samostatných objektů. To aplikaci umožňuje udržovat historii operací a jednoduše provést návrat do předchozího stavu (funkce Undo).
* **Iterator (Iterátor):** 
  * *Kde se nachází:* Rozhraní `IContactIterator` a jeho implementace, například `SearchIterator` nebo `AlphabeticalIterator`.
  * *Účel:* Odděluje logiku procházení a filtrování kolekce od její vnitřní datové reprezentace. Klientský kód tak iteruje přes nalezené výsledky, aniž by musel znát strukturu ukládání dat.