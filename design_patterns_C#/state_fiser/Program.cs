using System;
interface IProduct{
    string Name {get;}
    string Price {get;}
}
class SimpleProduct: IProduct{
    public SimpleProduct(string name){Name=name;}
    string Name {get; private set;}
    string Price {get;} = 0;
    public override string ToString(){ return $"Simple Product {Name}, Price{Price}";}
}
class Factory{
    INameCreator NameCreator{get;set;}
    public Factory(INameCreator nameCreator){NameCreator = nameCreator;}
    public IProduct Create(){
        return new SimpleProduct(NameCreator.Create());
    }
}
interface INameCreator{
    string Create();
}
class TestNameCreator: INameCreator{
    private int id = 0;
    public string Create(){ id++; return "product"+id.ToString(); }
}
class RandomGenerator{
    private int state=0;
    int Generate(){ return state;}
    public int State{ get => state; set => state = value;}
    Memento CreateMemento(){
        Memento m = new Memento();
        m.State = state;}
}
class Memento{ private int State{get; set;}}
class Program{
    public static void Main(string[] args){
        var factory = new Factory(new TestNameCreator());
        IProduct product = factory.Create();
        Console.WriteLine(product);
    } 
}