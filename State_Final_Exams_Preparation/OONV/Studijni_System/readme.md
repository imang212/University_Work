# Studijní systém (Konzolová aplikace)
Aplikace simuluje základní funkce studijního systému: registraci uživatelů, správu kurzů, přihlašování studentů a výpočet studijních výsledků. Aplikace byla vytvořena jako řešení ukázkové úlohy I.2 pro SZZ.

## Uživatelská příručka
Aplikace funguje jako textová konzolová ukázka. Po spuštění programu dojde k interaktivní ukázce hlavních funkcionalit:
1. Systém vytvoří uživatelské účty studentů a učitelů.
2. Vytvoří se kurz, na který je student následně přihlášen.
3. Simuluje se změna v rozvrhu kurzu – učitel vyvolá upozornění a systém automaticky informuje všechny přihlášené studenty.
4. Studentovi jsou zapsány známky s různou váhou a systém zobrazí studijní výsledky vypočtené různými metodami (aritmetický a vážený průměr).

## Dokumentace architektury a návrhových vzorů
Aplikace striktně odděluje modely a byznys logiku. Byly implementovány následující návrhové vzory:

* **Factory Method (Tovární metoda):** 
  * *Implementace:* Třída `UserFactory` s metodou `CreateUser`.
  * *Účel:* Zajišťuje bezpečné a centralizované vytváření různých typů uživatelských účtů (Student, Učitel) implementujících rozhraní `IUser`, aniž by klientský kód musel přímo volat jejich konstruktory.
* **Observer (Pozorovatel):** 
  * *Implementace:* Rozhraní `ISubject` (třída `Course`) a `IObserver` (třída `Student`).
  * *Účel:* Definuje závislost 1:N mezi kurzem a studenty. Pokud se v kurzu změní stav (např. změna rozvrhu), kurz zavolá metodu `Notify()`, která iteruje přes registrované pozorovatele (studenty) a zavolá jejich metodu `Update()`.
* **Strategy (Strategie):** 
  * *Implementace:* Rozhraní `IGradingStrategy` s třídami `ArithmeticAverageStrategy` a `WeightedAverageStrategy`.
  * *Účel:* Zapouzdřuje rodinu algoritmů pro výpočet studijních výsledků. Umožňuje aplikaci dynamicky (za běhu) měnit způsob hodnocení studenta (z klasického průměru na vážený) bez nutnosti zasahovat do logiky třídy `Student`.