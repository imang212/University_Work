
public interface Prototype{public Prototype clone();}
public class Clovek: Prototype{
    private string jmeno;
    private int vek;
    public Clovek(string jmeno, int vek){ this.jmeno=jmeno; this.vek=vek;}
    public Prototype clone(){ return new Clovek(this.jmeno,this.vek); }
    public void Zestarni(int o_kolik){this.vek += o_kolik;}
    public int Vek(){return this.vek;}
}
class Program{
    static void Main(string[] args){
        Clovek pepa = new Clovek("Pepa",25);
        pepa.Zestarni(20);
        Clovek pepaKlon = (Clovek)pepa.clone(); //klon
        Console.WriteLine(pepaKlon.Vek());
    }
}