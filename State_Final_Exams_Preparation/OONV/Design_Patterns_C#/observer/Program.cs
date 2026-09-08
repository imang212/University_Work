using System; using System.Collections.Generic;
public interface ISubscriber{void Update(string message);}
public interface IPublisher{ void Subscribe(ISubscriber subscriber); void UnSubscribe(ISubscriber subscriber); void NotifySubscribers(); }
public class Alza:IPublisher{
    private readonly List<ISubscriber> subscribers = new List<ISubscriber>();
    private string predchozi_zprava;
    public void Subscribe(ISubscriber subscriber){subscribers.Add(subscriber); Console.WriteLine("Nový subscriber Přidán");}
    public void UnSubscribe(ISubscriber subscriber){subscribers.Remove(subscriber); Console.WriteLine("subscriber smazán");}
    public void PublishNews(string news){predchozi_zprava = news; Console.WriteLine($"Newsletter publikoval zprávu: {news}"); NotifySubscribers();} //patří k for cyklu
    public void NotifySubscribers(){ foreach (var s in subscribers){ s.Update(this.predchozi_zprava); }}
}
public class Uzivatel: ISubscriber{
    private readonly string _name; public Uzivatel(string name){this._name = name;}
    public void Update(string message){Console.WriteLine($"{_name} obdržel zprávu: {message}");}
}
class Program{
    public static void Main(){
        Alza noviny = new Alza();
        Uzivatel user1 = new Uzivatel("Patrik"); Uzivatel user2 = new Uzivatel("Tomas"); Uzivatel user3 = new Uzivatel("Alice");
        noviny.Subscribe(user1);
        noviny.Subscribe(user2);
        noviny.PublishNews("Nova zprava: o necem");
        Console.WriteLine();
        noviny.Subscribe(user3);
        noviny.UnSubscribe(user1);
        noviny.PublishNews("Dalsi zprava: o necem");
    }
}