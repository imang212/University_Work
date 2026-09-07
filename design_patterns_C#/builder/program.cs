// See https://aka.ms/new-console-template for more information
//interface IProgramator{ public void PijKavu(); public void Programuj(); public void VykradniKod();}
//class StudentUJEPAPI: IProgramator{
//    public StudentUJEPAPI(){}
//    public void PijKavu(){Console.WriteLine("Pij Kavu");}
//    public void Programuj(){Console.WriteLine("Programuju UJEP");}
//    public void VykradniKod(){Console.WriteLine("Vykradni kod");}
//    public void Chlastej(){Console.WriteLine("Vykradni kod");}
//}
//class StudentCVUTOI: IProgramator{
//    public StudentCVUTOI(){}
//    public void PijKavu(){Console.WriteLine("Pij Kavu");}
//    public void Programuj(){Console.WriteLine("Programuju CVUT");}
//    public void VykradniKod(){Console.WriteLine("Vykradni kod");}
//    public void Informatika(){Console.WriteLine("Vykradni kod");}
//}
//class Program{
//    static void Main(string[] args){
//        StudentUJEPAPI pepa = new StudentUJEPAPI();
//        StudentCVUTOI honza = new StudentCVUTOI();
//        //IProgramator muj_otrok = new StudentUJEPAPI();
//        IProgramator zamestnanec = pepa;        
//        zamestnanec.Programuj();
//    }
//}
//Buider
using System; using System.Text;
public interface IBuilder{ public void BuildStepA(); public void BuildStepB(); public void BuildStepC(); public void Reset(); public StringBuilder GetResult(); }
public class Builder1: IBuilder{
    StringBuilder _product = new StringBuilder();
    public Builder1(){}
    public void BuildStepA(){ this._product.Append("A"); }
    public void BuildStepB(){ this._product.Append("B"); }
    public void BuildStepC(){ this._product.Append("C"); }
    public void Reset(){ this._product = new StringBuilder(); }
    public StringBuilder GetResult(){ return this._product; }}
public class Builder2: IBuilder{
    private StringBuilder _product = new StringBuilder();
    public Builder2(){}
    public void BuildStepA(){ this._product.Append("D"); }
    public void BuildStepB(){ this._product.Append("E"); }
    public void BuildStepC(){ this._product.Append("F"); }
    public void Reset(){ this._product = new StringBuilder(); }
    public StringBuilder GetResult(){ return this._product; }}
public class Director{
    private IBuilder _builder;
    public Director(IBuilder builder){ this._builder = builder;}
    public void Zmen(IBuilder newBuilder){ this._builder = newBuilder; }
    public StringBuilder Postav(string type){
        this._builder.Reset();
        if(type=="simple"){ this._builder.BuildStepA(); }
        else{ this._builder.BuildStepB(); this._builder.BuildStepC(); }
        return this._builder.GetResult();
    }}
class Program{
    static void Main(string[] args){
        Builder1 tomas = new Builder1();
        Director director = new Director(tomas);
        StringBuilder vyslednyproduct = director.Postav("complex");
        Console.WriteLine("Udělám krok: "+tomas.GetResult());
        //director.Postav("Hard")
    }
}