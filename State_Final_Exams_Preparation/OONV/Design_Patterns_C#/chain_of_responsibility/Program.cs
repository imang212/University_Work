public interface IHandler{public IHandler setNext(IHandler Handler); void Handle(Request request); }
public abstract class BaseHandler: IHandler{
    private IHandler? _nextHandler;
    public IHandler setNext(IHandler handler){ _nextHandler = handler; return handler;}
    public virtual void Handle(Request request){ if (_nextHandler != null){ _nextHandler.Handle(request);} else{ Console.WriteLine("Požadavek nebyl zpracován žádným handlerem.");} }}
public class Editor: BaseHandler{
    public override void Handle(Request request){
        if (request.ApprovalLevel == 1){ Console.WriteLine("Editor schválil požadavek."); request.IsHandled = true;}
        else{ Console.WriteLine("Editor předává požadavek dále."); base.Handle(request); }
    }}
public class Manager: BaseHandler{
    public override void Handle(Request request){
        if (request.ApprovalLevel == 2){Console.WriteLine("Manažer schválil požadavek."); request.IsHandled = true;}
        else{Console.WriteLine("Manažer předává požadavek dále."); base.Handle(request); }
    }}
public class Director: BaseHandler{
    public override void Handle(Request request){
        if (request.ApprovalLevel == 3){Console.WriteLine("Ředitel schválil požadavek."); request.IsHandled = true;}
        else{ Console.WriteLine("Ředitel nemůže požadavek zpracovat."); base.Handle(request); }
    }}
public class Request{ //to je jenom požadavek, může být i jenom samotný string
    public string Content{get;set;} public int ApprovalLevel{get;set;} public bool IsHandled{get;set;} = false; 
    public Request(string content, int approvalLevel){Content = content; ApprovalLevel = approvalLevel;}
}

public class Program{
    static void Main(string[] args){
        IHandler editor = new Editor(); IHandler manager = new Manager(); IHandler director = new Director();
        editor.setNext(manager);editor.setNext(director);
        // Zpracování požadavků
        editor.Handle(new Request("Požadavek 1", 1)); //editor <- schválení editorem (zpracování požadavku)
        editor.Handle(new Request("Požadavek 2", 2)); //manažer <- schválení
        editor.Handle(new Request("Požadavek 3", 3)); //ředitel
        editor.Handle(new Request("Požadavek 4", 4));
    }
}