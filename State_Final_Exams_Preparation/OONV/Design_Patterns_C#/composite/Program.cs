interface Component{ public void execute(); }
public class Leaf{
    public void execute(){ Console.WriteLine("Dělám nějakou práci") }
}
public class Composite{
    Component children;
    public void add(Component c){ }
    public void remove(Component c){}
    public Component getChildren(){ return c; }
    public execute(){ Console.WriteLine("Dělám nějakou práci pro děti") }
}