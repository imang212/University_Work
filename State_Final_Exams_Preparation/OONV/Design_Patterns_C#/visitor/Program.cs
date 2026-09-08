using System; using System.Collections.Generic;
public interface IVisitor{void visitCircle(Circle circle);void visitRectangle(Rectangle rectangle);}
interface IShape{void Accept(IVisitor visitor);}//void Accept(Vypocet_obsahu vypocet_obsahu);void Accept(Vykreslit viskreslit); můžou i být 2 metody na 2 různé typy visiturů
public class Circle: IShape{
    public double Radius {get;}
    public Circle(double radius){Radius=radius;}
    public void Accept(IVisitor visitor){Console.WriteLine("Kruh");visitor.visitCircle(this);}
}
public class Rectangle: IShape{
    public double Width {get;} public double Height {get;}
    public Rectangle(double width, double height){Width=width;Height=height;}
    public void Accept(IVisitor visitor){Console.WriteLine("Čtverhran");visitor.visitRectangle(this);}
}

public class Vypocitam_obsah_visitor: IVisitor{
    public void visitCircle(Circle circle){
        double area = Math.PI*Math.Pow(circle.Radius,2);Console.WriteLine($"Kruh s poloměrem {circle.Radius} má plochu: {area:F2}");
    }
    public void visitRectangle(Rectangle rectangle){
        double area = rectangle.Width*rectangle.Height;Console.WriteLine($"Obdélník {rectangle.Width}x{rectangle.Height} má plochu: {area:F2}");
    }
}
public class Vykreslim_visitor: IVisitor{
    public void visitCircle(Circle circle){Console.WriteLine($"Vykresluji kruh s poloměrem {circle.Radius}.");}
    public void visitRectangle(Rectangle rectangle){Console.WriteLine($"Vykresluji obdélník o rozměrech {rectangle.Width}x{rectangle.Height}.");}
}
class Program{
    static void Main(){
        Vypocitam_obsah_visitor vypocet_rozsahu = new Vypocitam_obsah_visitor();
        Vykreslim_visitor render = new Vykreslim_visitor();
        Console.WriteLine("Výpočet plochy: ");
        new Circle(5).Accept(vypocet_rozsahu); //vytvořím tvar podle IShape interface, a potom zavolám metodu kam vstupuje objekt podle IVisitor
        new Circle(5).Accept(render);
        new Rectangle(4,6).Accept(vypocet_rozsahu);         
        new Rectangle(4,6).Accept(render);
    }
}
