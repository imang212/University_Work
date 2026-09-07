// Polymorfismus
// statický
// přetypování - sin(a) - číselný typ -> double, implicitní přetypování: metoda pro implicitní přetypování - Digit -> int
//                                                                                                                int(Digit) přetypovací konstruktor
//                                                                                                                instanční metoda digit (toInt)
// AvaloniaUI                                                                                                        u digit lze definovat přetypovací operátor (statické)
// přetěžování - souble Sin(double x), double Sin(int x), int Size(X x)
class Zlomek {
    public Zlomek () {}
    public Zlomek (int p) {}
    public Zlomek (int cit=0, int jmen=1) {}
    public Zlomek (double x, int jm_cislice=100) {}
    //public Zlomek(Numeric p) {}
}
// generické typy (generics)
// třídy a metody parametrizované pomocí typů - List = generický typ, T = typový parametr, Tuple<T1>, Tuple<T1, T2>, Tuple<T1, T2, T3>
//                                              List<T> = generický typ
// specializace (dosazení typové parametry) -> konkrétní typ - List<int>, Tuple<int, int>
// Java generika: ArrayList<int> = ArrayList<object>   + dodatečná typová informace
// C# generika: specializace za překladu
//              List<T>
//                  Add(T item)
// 1. vlastní překlad: kontrola při překladu
// 2. --> bytkódu, bytokód -> strojového kódu (JIT, A0T)
//  specializace generických typů
// 3. běh (runtime)
// c++ generika (šablony)

// dynamický polymorfismus
// dědičnost
abstract class Zvire {
    public abstract string Hlas();
    public virtual string Jmeno(){

    } 
}
class Pes: Zvire {
    public override string Hlas(){
        return "Haf";
    }
    public new string Jmeno(){

    }
}
//A: metody x,y
//B: A: dědí x,y a přidává z List<int>
//A: přidá metodu z
// bázová: abstract, virtual (definovaná)
// odvozená: override, new (jen v případě kolize u více týmů)
// bázová: sealed (nelze definovat)
// Zvire z = new Pes()
// z.Hlas() -> volá podle skutečného typu metoda u Pes
//z.Jmeno() -> zavolá se metoda u zvířat
//dědičnost je jednoduchá: lze dědit jen z jedné třídy -> relace dědičnosti je strom 
//hiearchický pohled na svět
//interface: hlavičky metod (dnes i další možnosti)
//interface IFlyable { void TakeOff(); void Land(); int Altitude {get; set;}}
// class Dragon : IFlyable, Zvire, IEnergySource { void TakeOff(){...} ...}
// duck polymorfismus - dynamic i;, object i;, var i = 2;