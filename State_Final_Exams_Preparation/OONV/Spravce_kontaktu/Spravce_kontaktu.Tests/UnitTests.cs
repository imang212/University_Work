namespace Spravce_kontaktu.Tests;
using NUnit.Framework;
using System.Collections.Generic;

[TestFixture]
public class ContactManagerTests {
    private ContactCollection _collection;
    private CommandManager _commandManager;
    [SetUp]
    public void Setup() {
        _collection = new ContactCollection();
        _commandManager = new CommandManager();
    }
    [Test]
    public void Prototype_Clone_Contact() {
        // arrange - příprava dat
        var original = new Contact("Jan Novak", "132456789", "jannovak@gmail.com");
        var clone = (Contact)original.Clone(); //klonování
        clone.Name = "Petr Novak"; // upravíme pouze jméno u klonu
        // assert - ověření výsledků
        Assert.That(original.Name, Is.Not.EqualTo(clone.Name)); // vraci false, nemelo by se rovnat
        Assert.That(original.PhoneNumber, Is.EqualTo(clone.PhoneNumber));
        Assert.That(original.Email, Is.EqualTo(clone.Email));
    }
    [Test]
    public void Command_ExecUndoDelete() {
        var contact = new Contact("Anna", "999", "anna@test.cz");
        _collection.Contacts.Add(contact);
        var deleteCmd = new DeleteContactCommand(_collection, contact);
        _commandManager.ExecuteCommand(deleteCmd);
        Assert.That(0, Is.EqualTo(_collection.Contacts.Count));
        _commandManager.UndoLastCommand();
        Assert.That(1, Is.EqualTo(_collection.Contacts.Count));
        Assert.That("Anna", Is.EqualTo(_collection.Contacts[0].Name));
    }
    [Test]
    public void Iterator_SearchIterator_ShouldFindMatchingContacts()
    {
        _collection.Contacts.Add(new Contact("Zdenek", "111", "zdenek@mail.cz"));
        _collection.Contacts.Add(new Contact("Adam", "222", "adam@mail.cz"));
        _collection.Contacts.Add(new Contact("Zdenka", "333", "zdenka@mail.cz"));
        // Act (testujeme Iterator vzor pro vyhledávání textu "Zden")
        var iterator = new SearchIterator(_collection.Contacts, "Zden");
        var foundContacts = new List<Contact>();
        while (iterator.HasNext()) foundContacts.Add(iterator.Next()); 
        // Assert
        Assert.That(2, Is.EqualTo(foundContacts.Count));
        Assert.That("Zdenek", Is.EqualTo(foundContacts[0].Name));
        Assert.That("Zdenka", Is.EqualTo(foundContacts[1].Name));
    }
}
