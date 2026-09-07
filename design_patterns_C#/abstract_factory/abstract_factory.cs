interface Abstractfactory{ public ProductA createProductA(); public ProductB createProductB(); }
class Tovarna1: Abstractfactory{ //vyrabi moderni veci
    public ProductA createProductA(){ return new ModerniZidle(); }
    public ProductB createProductB(){ return new ModerniStul(); }}
class Tovarna2: Abstractfactory{ //vyraby stary veci
    public ProductA createProductA(){ return new GotickaZidle(); }
    public ProductB createProductB(){ return new GotickyStul();  }}
interface ProductA{public void KolikMasNohou();} interface ProductB{public void KolikTohoUneses();}
class ModerniZidle: ProductA{public void KolikMasNohou(){Console.WriteLine("Jako každá moderní židle mám 3 nohy");}}
class GotickaZidle: ProductA{public void KolikMasNohou(){Console.WriteLine("Nemám žádné nohy. Jsem umělecká židle.");}}
class ModerniStul: ProductB{public void KolikTohoUneses(){Console.WriteLine("Moderní stoly moc neunesou. Max 5 kg.");}}
class GotickyStul: ProductB{public void KolikTohoUneses(){Console.WriteLine("Jsem z masivu. Unesu všechno");}}
class Program{
    static void Main(string[] args){
        Abstractfactory vyrobce = new Tovarna2();
        ProductA vyrobek1 = vyrobce.createProductA();
        ProductB vyrobek2 = vyrobce.createProductB();
        vyrobek1.KolikMasNohou();     
    }
}

//verze2
//interface AbstractFactory{
//    public Zidle VyrobZidli();
//    public Stul VyrobStul();
//    public Pohovka VyrobPohovku();
//}
//
//class ModerniTovarna: AbstractFactory{
//    public Zidle VyrobZidli(){return new ModerniZidle();}
//    public Stul VyrobStul(){return new ModerniStul();}
//    public Pohovka VyrobPohovku(){return new ModerniPohovka();}
//    public ModerniTovarna(){}
//}
//
//class UmeleckaTovarna: AbstractFactory{
//    public Zidle VyrobZidli(){return new UmeleckaZidle();}
//    public Stul VyrobStul(){return new UmeleckyStul();}
//    public Pohovka VyrobPohovku(){return new UmeleckaPohovka();}
//    public UmeleckaTovarna(){}
//}
//class GotickaTovarna: AbstractFactory{
//    public Zidle VyrobZidli(){return new GotickaZidle();}
//    public Stul VyrobStul(){return new GotickyStul();}
//    public Pohovka VyrobPohovku(){return new GotickaPohovka();}
//    public GotickaTovarna(){}
//}
//
//interface Zidle{public void KolikMasNohou();}
//interface Stul{public void KolikTohoUneses();}
//interface Pohovka{public void JakMocJsiMekka();}
//
//class ModerniZidle: Zidle{
//    public ModerniZidle(){}
//    public void KolikMasNohou(){Console.WriteLine("Jako každá moderní židle mám 3 nohy");}
//}
//class UmeleckaZidle: Zidle{
//    public void KolikMasNohou(){Console.WriteLine("Nemám žádné nohy. Jsem umělecká židle.");}
//}
//
//class GotickaZidle: Zidle{
//    public GotickaZidle(){}
//    public void KolikMasNohou(){Console.WriteLine("Mám všechny 4 nohy jako za zlatých časů");}
//}
//class ModerniStul: Stul{
//    public ModerniStul(){}
//    public void KolikTohoUneses(){Console.WriteLine("Moderní stoly moc neunesou. Max 5 kg.");}
//}
//class UmeleckyStul: Stul{
//    public UmeleckyStul(){}
//    public void KolikTohoUneses(){Console.WriteLine("Nic neunesu. Jsem tu jen pro umeni.");}
//}
//class GotickyStul: Stul{
//    public GotickyStul(){}
//    public void KolikTohoUneses(){Console.WriteLine("Jsem z masivu. Unesu všechno");}
//}
//class ModerniPohovka: Pohovka{
//    public ModerniPohovka(){}
//    public void JakMocJsiMekka(){Console.WriteLine("Poskytuju nejvetsi luxus v mekkosti.");}
//}
//class UmeleckaPohovka: Pohovka{
//    public UmeleckaPohovka(){}
//    public void JakMocJsiMekka(){Console.WriteLine("Jsem z dřevotřísky. Zkus hádat.");}
//}
//class GotickaPohovka: Pohovka{
//    public GotickaPohovka(){}
//    public void JakMocJsiMekka(){Console.WriteLine("To kdysi nebylo zapotřebí. Budou tě bolet záda");}
//}
//
//
//class Program{
//        static void Main(string[] args){
//            AbstractFactory mujVyrobceNabytku = new UmeleckaTovarna();
//            Pohovka mojePohovka = mujVyrobceNabytku.VyrobPohovku();
//            Zidle mojeZidlicka = mujVyrobceNabytku.VyrobZidli();
//            Stul mujStolecek = mujVyrobceNabytku.VyrobStul();
//            //mojePohovka.JakMocJsiMekka();
//            //mojeZidlicka.KolikMasNohou();
//            mujStolecek.KolikTohoUneses();
//        }
//    }