using System.Text.RegularExpressions;

public class HTML{ string content; public HTML(string content){this.content = content;}}
interface ClientI{ public void method(HTML data);}
class Service{
    public Service(){}
    public void serviceMethod(HTML specialData){Console.WriteLine("Dělám tu metodu, vzkresluji, atd... "+specialData);}
}
class Adapter: ClientI{
    Service adapter_;
    public Adapter(Service adapter){this.adapter_ = adapter;}
    public HTML Preved_data(HTML data){ return new HTML("fegerre"); }
    public void method(HTML data){
        HTML prevedenaData = this.Preved_data(data);
        this.adapter_.serviceMethod(data);
    }
}
class Program{
    static void Main(string[] args){
        Service sluzba = new Service();
        Adapter prevadec = new Adapter(sluzba);
        HTML data = new HTML("<a></a>");
        prevadec.method(data);
    }
}
