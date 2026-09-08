using System; using System.Collections.Generic; using System.Reflection.Metadata;
public interface IMediator{void Notify(string message,Participant sender); void RegisterParticipant(Participant participant);}
public class ChatRoom: IMediator{ //concrete mediator, muzem si i predstavit jako noviny
    private readonly List<Participant> _participants = new List<Participant>();
    public void RegisterParticipant(Participant participant){_participants.Add(participant);Console.WriteLine($"{participant._name} se připojil do chatovací místnosti.");}
    public void Notify(string message, Participant sender){
        foreach (var p in _participants){ if (p != sender) { p.ReceiveMessage(message, sender); }
        }
    }
}
public abstract class Participant{ //component, který dělá něco pro ostatní například kráči na jedné mapě když něco jeden tak všichni
    protected IMediator mediator; public string _name {get;}
    protected Participant(string name, IMediator _mediator){_name = name; mediator = _mediator;}
    public void SendMessage(string message){Console.WriteLine($"{_name} posílá zprávu: {message}"); mediator.Notify(message, this);}
    public abstract void ReceiveMessage(string message, Participant sender);
}
public class Uzivatel:Participant{
    public Uzivatel(string name, IMediator mediator) : base(name, mediator){}
    public override void ReceiveMessage(string message, Participant sender){
        Console.WriteLine($"{_name} obdržel zprávu od {sender._name}: {message}");
    }
}
class Program{
    public static void Main(){
        ChatRoom chat_mistnost = new ChatRoom();
        Uzivatel componentA = new Uzivatel("Patrik",chat_mistnost); Uzivatel tomas = new Uzivatel("Tomas",chat_mistnost); Uzivatel alice = new Uzivatel("Alice",chat_mistnost); 
        chat_mistnost.RegisterParticipant(componentA); chat_mistnost.RegisterParticipant(tomas); chat_mistnost.RegisterParticipant(alice);
        componentA.SendMessage("Cau sasci!");
        tomas.SendMessage("Ahojte");

    }
}

