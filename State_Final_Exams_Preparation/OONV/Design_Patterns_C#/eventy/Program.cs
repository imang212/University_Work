using System.Xml.XPath;
class Activator{
    public event EventHandler<int>
    public void ResultPrepared(int result){}
}
class Printer{
    public void PrintResult(object sender, int result){ System.Console.WriteLine($"Result is {result}")}
}
class Mediator{
    public static void Main(){

    }
}