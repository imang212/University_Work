//using System;
//using System.Collections.Generic;
//class Originator{ //editor
//    public string _state; //content 
//    public string State{ get => State; set{ Console.WriteLine($"Content updated to: '{value}'");_state = value;}}
//    public Memento save(){ Console.WriteLine("Saving current state."); return new Memento(_state);}
//    void restore(Memento memento){ Console.WriteLine("Restoring state."); if(memento==null) throw new ArgumentNullException(nameof(memento));_state = memento.GetState();}
//    public class Memento{ //zbytková Memento třída
//        public string _state {get; private set;}
//        public Memento(string state){ this._state=state;}
//        public string GetState(){ return this._state; }
//    }
//}
//public class CareTaker{
//    public Stack<Originator.Memento> _history = new Stack<Originator.Memento>();
//    public void Save(Originator.Memento memento){ Console.WriteLine("Stav se uložil"); _history.Push(memento);}
//    public Originator.Memento undo(){ if(_history.Count == 0){Console.WriteLine("No states to restore.");return null;}
//        var m = _history.pop(); originator.restore(m); 
//    }
//}
//public class Program{
//    static void Main(string[] args){
//        var code_editor = new Originator(); var save_load_system = new CareTaker();
//        code_editor._state = "První kontent";
//        save_load_system.Save(code_editor.save());
//    }
//}
using System.Text; using System.Threading;
public class TextEditor{ //Originator::Save
    public string textovyObsah; public DateTime posledniUlozeni {get; private set;} string autor; //promenne (stav), muzu k nim pristupovat
    public TextEditor(string autor){ this.autor = autor; this.textovyObsah = ""; this.posledniUlozeni = DateTime.Now; } //konstruktor
    public Memento VratUktualniStav() { posledniUlozeni = DateTime.Now; return new Memento(autor, textovyObsah, posledniUlozeni); } //Originator::Save vrati novy Memento
    public void NactiStav(Memento predchoziStav){ autor = predchoziStav.autor; textovyObsah = predchoziStav.textovyObsah; posledniUlozeni = predchoziStav.posledniUlozeni;} //Originator::Restore
    public class Memento { //Nested Memento
        public string textovyObsah {get; private set;} public DateTime posledniUlozeni {get; private set;} public string autor {get; private set;} //promenne (stav)
        public Memento(string autor, string textovyObsah, DateTime posledniUlozeni){ this.autor = autor; this.textovyObsah = textovyObsah; this.posledniUlozeni = posledniUlozeni; } //kontruktor
    }
    }
public class SaveLoadSystem { //Caretaker
    TextEditor textEditor; Stack<TextEditor.Memento> historie; //promenne
    public SaveLoadSystem(TextEditor textEditor){ this.textEditor = textEditor; this.historie = new Stack<TextEditor.Memento>();} //konstruktor
    public void UlozStavEditor() { historie.Push(textEditor.VratUktualniStav());} //Caretaker::DoSomething sem ukládám stav
    public void VratPredchoziStavEditoru(){ textEditor.NactiStav(historie.Pop());} //Caretaker::Undo vyprdne posledni prvek
}
class Program{
    static void Main(string[] args){
        TextEditor codeEditor = new TextEditor("Pavel Beránek"); SaveLoadSystem saveLoadSystem = new SaveLoadSystem(codeEditor); //do caretaker vstupuje originator
        // První stav: prázdný text
        Console.WriteLine("Prvotní stav:");saveLoadSystem.UlozStavEditor(); Console.WriteLine($"Obsah editoru: {codeEditor.textovyObsah}"); Console.WriteLine($"Načteno: {codeEditor.posledniUlozeni}"); Thread.Sleep(2000);
        // Úprava obsahu editoru
        Console.WriteLine("\nÚprava obsahu:");
        codeEditor.textovyObsah = "print('Hello world)"; saveLoadSystem.UlozStavEditor(); Console.WriteLine($"Obsah editoru: {codeEditor.textovyObsah}"); Console.WriteLine($"Načteno: {codeEditor.posledniUlozeni}"); Thread.Sleep(2000);
        // Další úprava obsahu
        Console.WriteLine("\nÚprava obsahu:");
        codeEditor.textovyObsah = "input('Zadej dve cisla: ')"; Console.WriteLine($"Obsah editoru: {codeEditor.textovyObsah}"); Console.WriteLine($"Načteno: {codeEditor.posledniUlozeni}"); Thread.Sleep(2000);
        // Návrat k předchozímu stavu
        Console.WriteLine("\nNávrat k předchozímu stavu:");
        saveLoadSystem.VratPredchoziStavEditoru(); Console.WriteLine($"Obsah editoru: {codeEditor.textovyObsah}"); Console.WriteLine($"Načteno: {codeEditor.posledniUlozeni}"); Thread.Sleep(2000);
        // Návrat k předchozímu stavu
        Console.WriteLine("\nNávrat k původnímu stavu:");
        saveLoadSystem.VratPredchoziStavEditoru(); Console.WriteLine($"Obsah editoru: {codeEditor.textovyObsah}"); Console.WriteLine($"Načteno: {codeEditor.posledniUlozeni}"); Thread.Sleep(2000);
        /* Výstup v terminálu
        Prvotní stav:
        Obsah editoru: 
        Načteno: 13.12.2024 16:59:17
        Úprava obsahu:
        Obsah editoru: print('Hello world)
        Načteno: 13.12.2024 16:59:19
        Úprava obsahu:
        Obsah editoru: input('Zadej dve cisla: ')
        Načteno: 13.12.2024 16:59:19
        Návrat k předchozímu stavu:
        Obsah editoru: print('Hello world)
        Načteno: 13.12.2024 16:59:19
        Návrat k původnímu stavu:
        Obsah editoru: 
        Načteno: 13.12.2024 16:59:17
        */
    }
}