//singleton
public sealed class Singleton{
    private static Singleton? _instance;
    public int counter;
    private Singleton() { this.counter = 0; }   
    public static Singleton GetInstance(){
        if (_instance == null){ _instance = new Singleton();}
        return _instance;
    }
}
class Vlak{
        //fields
        private int _pocetVagonu; public string StrojVedouci; private int _vykon;
        //konstruktor
        public Vlak(int pocetVagonu, int vykon){ this._pocetVagonu = pocetVagonu; this._vykon = vykon; this.StrojVedouci = null; }
        public int VratPocetVagonu(){ return this._pocetVagonu;}
        public static void UdelejZvuk(){ Console.WriteLine("Ty sasku jeden");}
    }
public partial class Program{
    static void Main(string[] args){
        Singleton s1 = Singleton.GetInstance();
        Singleton s2 = Singleton.GetInstance();
        Console.WriteLine(s1.counter);
        s1.counter += 1;
        Console.WriteLine(s2.counter);
        
        Vlak pepa = new Vlak(5, 28000);
        Vlak martin = new Vlak(1,20);
        pepa.StrojVedouci = "Patrik";
        Console.WriteLine(pepa.StrojVedouci);
        Vlak.UdelejZvuk();
    }}
// https://leanpub.com/fp-made-easier