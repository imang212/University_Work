using System;
public interface IState{void publish(Document document);void edit(Document document);} //void render(Document document);
public class draftState:IState{
    public void publish(Document document){Console.WriteLine("Dokument byl odeslán ke kontrole.");
        document.SetState(new moderationState());
    }
    public void edit(Document document){Console.WriteLine("Dokument je v návrhu a lze jej editovat.");}
}
public class moderationState:IState{
    public void publish(Document document){ Console.WriteLine("Dokument byl publikován.");
        document.SetState(new publishedState());   
    }
    public void edit(Document document){Console.WriteLine("Dokument je v kontrole a nelze jej editovat.");}
}
public class publishedState:IState{
    public void publish(Document document){Console.WriteLine("Dokument je již publikovaný. Nelze jej znovu publikovat.");}
    public void edit(Document document){Console.WriteLine("Dokument je publikovaný a nelze jej editovat.");}
}
public class Document{
    private IState _state; 
    public Document(IState state){this._state = state;  
    
    Console.WriteLine("Dokument je nyní ve stavu: Draft");}
    public void SetState(IState state){_state = state;Console.WriteLine($"Stav dokumentu byl změněn na: {state.GetType().Name}");}
    public void publish(){_state.publish(this);}
    public void edit(){_state.edit(this);}}
class Program{
    static void Main(){
        IState kresli_se = new draftState();
        Document bakalarka = new Document(kresli_se);        
        bakalarka.edit();
        bakalarka.publish();
        bakalarka.SetState(new draftState());
        bakalarka.edit();bakalarka.publish();
        bakalarka.edit();bakalarka.publish();
        bakalarka.edit();
    }
}