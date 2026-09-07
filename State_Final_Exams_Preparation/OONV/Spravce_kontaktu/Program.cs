using System;
using System.Collections.Generic;
using System.Linq;
using System.IO;
using System.Text.Json;
// Ukol - Správce Kontaktů
// Prototype: Pro efektivní vytváření a kopírování kontaktních záznamů.
// Command: Pro zaznamenávání a možné vrácení změn v kontaktech.
// Iterator: Pro navigaci skrze kolekci kontaktů.
public class Contact : ICloneable { //prototype - vytvorim kontakt
    public string Name { get; set; }
    public string PhoneNumber { get; set; }
    public string Email { get; set; }
    public Contact(string name, string phoneNumber, string email) {
        Name = name;
        PhoneNumber = phoneNumber;
        Email = email;
    }
    public object Clone() => this.MemberwiseClone(); //public object Clone() { return this.MemberwiseClone(); }
}
// iterator
public interface IContactIterator {
    bool HasNext();
    Contact Next();
}
public class AlphabeticalIterator : IContactIterator {
    private readonly List<Contact> _contacts;
    private int _position = 0;
    public AlphabeticalIterator(List<Contact> contacts) {
        _contacts = contacts.OrderBy(c => c.Name).ToList();
    }
    public bool HasNext() => _position < _contacts.Count;
    public Contact Next() => _contacts[_position++];
}
public class SearchIterator : IContactIterator {
    private readonly List<Contact> _filteredContacts;
    private int _position = 0;
    public bool HasNext() => _position < _filteredContacts.Count;
    public Contact Next() => _filteredContacts[_position++];
    // filtrace kontaktů podle jmena nebo emailu
    public SearchIterator(List<Contact> contacts, string query) {
        _filteredContacts = contacts.Where(
            c => c.Name.Contains(query, StringComparison.OrdinalIgnoreCase) ||
            c.Email.Contains(query, StringComparison.OrdinalIgnoreCase))
            .ToList();
    }
}
public class ContactCollection { // jsem se bude pridavat
    public List<Contact> Contacts { get; } = new List<Contact>();
    public string query = "";
    public IContactIterator CreateAlphabeticalIterator() {
        return new AlphabeticalIterator(Contacts);
    }
    public IContactIterator CreateSearchIterator() => new SearchIterator(Contacts, query);
}
// command
public interface ICommand { void Execute(); void Undo(); }
public class AddContactCommand : ICommand { // budu volat pro pridani kontaktu do kolekce
    private readonly ContactCollection _collection;
    private readonly Contact _contact;
    public AddContactCommand(ContactCollection collection, Contact contact) {
        _collection = collection;
        _contact = contact;
    }
    public void Execute() => _collection.Contacts.Add(_contact);
    public void Undo() => _collection.Contacts.Remove(_contact);
}
public class DeleteContactCommand : ICommand {
    private readonly ContactCollection _collection;
    private readonly Contact _contact;
    public DeleteContactCommand(ContactCollection collection, Contact contact) {
        _collection = collection;
        _contact = contact;
    }
    public void Execute() => _collection.Contacts.Remove(_contact);
    public void Undo() => _collection.Contacts.Add(_contact);
}
//invoker - spravce prikazu
public class CommandManager { // zavolat pro vykonani prikazu pridani kontaktu + ulozeni do historie
    private readonly Stack<ICommand> _history = new Stack<ICommand>();
    public void ExecuteCommand(ICommand command) {
        command.Execute();
        _history.Push(command);
    }
    public void UndoLastCommand() {
        if (_history.Count > 0) {
            var command = _history.Pop();
            command.Undo();
        }
    }
}
//ukladani/nacitani z json souboru
public class ContactFileSystem {
    private const string FilePath = "contacts.json";
    // ulozeni do souboru
    public void SaveContacts(List<Contact> contacts) {
        string json = JsonSerializer.Serialize(contacts, new JsonSerializerOptions { WriteIndented = true});
        File.WriteAllText(FilePath, json);
    }
    //nacteni pri spusteni
    public List<Contact> LoadContacts() {
        if (!File.Exists(FilePath)) return new List<Contact>();
        string json = File.ReadAllText(FilePath);
        return JsonSerializer.Deserialize<List<Contact>>(json) ?? new List<Contact>();
    }
}
class Program {
    static void Main(string[] args) {
        Console.WriteLine("Správce kontaktů (Ukázka Navrhových vzorů)");
        var collection = new ContactCollection();
        var commandManager = new CommandManager();
        var storage = new ContactFileSystem();
        collection.Contacts.AddRange(storage.LoadContacts());
        Console.WriteLine($"Úspěšně načteno {collection.Contacts.Count} kontaktů ze souboru.");
        if (collection.Contacts.Count > 0) {
            Console.WriteLine($"Výpis kontaktů (iterátor):");
            var iterator = collection.CreateAlphabeticalIterator();
            while (iterator.HasNext()) {
                var contact = iterator.Next();
                Console.WriteLine($"- Jméno: {contact.Name} | Tel: {contact.PhoneNumber} | E-mail: {contact.Email}");
            }
        }
        Console.WriteLine("Stiskněte libovolnou klávesu pro pokračování do hlavního menu...");
        Console.ReadKey();
        bool isRunning = true;
        while (isRunning) {
            Console.Clear();
            Console.WriteLine("Správce kontaktů");
            Console.WriteLine("1. Přidat kontakt");
            Console.WriteLine("2. Vyhledat kontakt");
            Console.WriteLine("3. Vrátit poslední změnu (Undo)");
            Console.WriteLine("4. Uložit a ukončit");
            Console.Write("Vyberte akci: ");
            switch (Console.ReadLine()) {
                case "1":
                    Console.WriteLine("Zadejte jméno: "); string name = Console.ReadLine() ?? "";
                    Console.WriteLine("Zadejte číslo: "); string number = Console.ReadLine() ?? "";
                    Console.WriteLine("Zadejte email: "); string email = Console.ReadLine() ?? "";
                    var contact = new Contact(name, number, email);
                    var addCmd = new AddContactCommand(collection, contact);
                    commandManager.ExecuteCommand(addCmd);
                    Console.WriteLine("Kontakt úspěšně přidán!");
                    Console.WriteLine("Stiskněte libovolnou klávesu pro návrat do menu...");
                    Console.ReadKey();
                    break;
                case "2":
                    Console.WriteLine("Zadejte text pro vyhledávání: "); string query = Console.ReadLine() ?? "";
                    var searchIterator = new SearchIterator(collection.Contacts, query);
                    bool found = false;
                    Console.WriteLine("Výsledky hledání");
                    //procházení kolekce kontaktů přes iterátor
                    while (searchIterator.HasNext()) {
                        var c = searchIterator.Next();
                        Console.WriteLine($"- Jméno: {c.Name} | Tel: {c.PhoneNumber} | E-mail: {c.Email}");
                        found = true;
                    }
                    if (!found) {
                        Console.WriteLine("Žádný kontakt neodpovídá hledanému výrazu.");
                    }
                    Console.WriteLine("Stiskněte libovolnou klávesu pro návrat do menu...");
                    Console.ReadKey();
                    break;
                case "3":
                    commandManager.UndoLastCommand();
                    Console.WriteLine("Poslední akce byla vrácena (Undo)");
                    Console.WriteLine("Stiskněte libovolnou klávesu pro návrat do menu...");
                    Console.ReadKey();
                    break;
                case "4":
                    storage.SaveContacts(collection.Contacts);
                    isRunning = false;
                    break;
            }
        }
    }
}
