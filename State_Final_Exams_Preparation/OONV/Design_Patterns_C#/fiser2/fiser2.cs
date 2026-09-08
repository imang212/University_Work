//class A: B //-> A dědí z B, A rozšiřuje
//class A: IB //->třída A implementuje B
//interface IA: IB //->rozhraní IA rozšiřuje, IB variance
//LIst<Zvire> List<Pes> Pes <: Zvire
//                      List<Pes> <: List<Zvire>
//                      invariance
//A <: B <out T>
//ReadOnlyList<A> <: ReadOnlyList<B> // kovariance
// kontravariance A <: B => T<B> <: T<A>

//Func<T,TResult> -> intfce(double x) Func<double,int>
//                   int PocetZvirat(Zvire z)   Pes <: Zvire, Func<.., Zvire> <: Func<.., Pes>
//                   int PocetZvirat(Pes z)
//                   kovariance   
//int Plus(int x){.....}
//Apply(plus)
// instanční metody
//statické metody
// class A{ int Plus(x){}}
//A a = new A();
//Apply(a.Plus) delegát: dkaz this, metoda
//delegát na statickou metodu: null, metoda
//Action<T1,T2> = void f(T1,T2)
//Func<T, TResult> = TResult f(T)
// (int x) => {return x+1}
// (int x) => x+1
// x => x+1
using System.Collections;
using System.Collections.Generic;
class LimitedList<T>: IList<T>{
    private List<T> data;
    private int maxLength;
    public LimitedList(int maxLength){
        this.data = new List<T>(capacity:Math.Min(this.maxLength,1024));
        this.maxLength = maxLength;
    }
    
    public void Clear() => data.Clear();
    public bool Contains(T item) => data.Contains(item);
    public void CopyTo(T[] array, int arrayIndex) => data.CopyTo(array, arrayIndex);
    public bool Remove(T item) => data.Remove(item);
    public int Count {get => data.Count}

    
} 