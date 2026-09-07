interface ServiceInterface{ public void operation();}
class Sluzba_databaze: ServiceInterface{public void operation(){Console.WriteLine("Služba: příjímá požadavek");}}
class Proxy: ServiceInterface{
    public Sluzba_databaze realService;
    public Proxy(Sluzba_databaze s){this.realService = s;}
    public bool checkAccess(){ Console.WriteLine("Kontrola požadavku"); return true;}
    public void operation(){ if(checkAccess()){ realService.operation(); }
    }
}
public class Program{
    static void Main(string[] args){
         ServiceInterface server = new Proxy(new Sluzba_databaze()); server.operation();
    }
}
