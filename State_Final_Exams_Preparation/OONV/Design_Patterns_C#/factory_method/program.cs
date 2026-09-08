using System.Runtime.InteropServices;
public interface Product{string Operation();}
class Produkt1: Product{public string Operation(){return "Udělal jsem produkt1";}} //concrete product
class Produkt2: Product{public string Operation(){return "Udělal jsem produkt2";}}
abstract class Creator{
    public abstract Product FactoryMethod(); //create product
    public string SomeOperation(){var product = FactoryMethod();var result="Creator pracoval na "+product.Operation();return result;}
}
class Tvurce1: Creator{public override Product FactoryMethod(){return new Produkt1();}} //vrací produkt
class Tvurce2: Creator{public override Product FactoryMethod(){return new Produkt2();}} //concrete creator 
class Program{
    static void Main(string[] args){
        //new Client().Main(); //celý
        Creator creator1 = new Tvurce1(); Console.WriteLine(creator1.SomeOperation()); Console.WriteLine("");
        Creator creator2 = new Tvurce2(); Console.WriteLine(creator2.SomeOperation());
    }
}
