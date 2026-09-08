public interface IRouteStrategy{void BuildRoute(string startPoint, string endPoint);} //můžem i přidávat další druhy strategií pro silnice
public class CarRouteStrategy: IRouteStrategy{
    public void BuildRoute(string startPoint, string endPoint){Console.WriteLine($"Vytvářím trasu pro auto z {startPoint} do {endPoint}...");Console.WriteLine("Preferuji silnice a dálnice.");}
}
public class WalkingRouteStrategy: IRouteStrategy{
    public void BuildRoute(string startPoint, string endPoint){Console.WriteLine($"Vytvářím trasu pro pěší z {startPoint} do {endPoint}...");Console.WriteLine("Preferuji chodníky a pěší stezky.");}
}
public class BikeRouteStrategy: IRouteStrategy{
    public void BuildRoute(string startPoint, string endPoint){Console.WriteLine($"Vytvářím trasu pro cyklistu z {startPoint} do {endPoint}...");Console.WriteLine("Preferuji cyklostezky a bezpečné silnice.");}
}
public class Navigator{
    private IRouteStrategy _routeStrategy; public void SetRouteStrategy(IRouteStrategy routeStrategy) {_routeStrategy = routeStrategy;} // Nastavení výchozí strategie (lze měnit)
    public void Navigate(string startPoint, string endPoint){ // Metoda pro spuštění navigace (buildroute)
        if (_routeStrategy == null){Console.WriteLine("Není nastavena žádná strategie!");return;}
        _routeStrategy.BuildRoute(startPoint, endPoint);}
}
class Program{
    static void Main(){
        Navigator navigator = new Navigator();
        navigator.SetRouteStrategy(new CarRouteStrategy());
        navigator.Navigate("Praha", "Brno");
        Console.WriteLine();
        navigator.SetRouteStrategy(new WalkingRouteStrategy());
        navigator.Navigate("Praha", "Brno");
        Console.WriteLine();
        navigator.SetRouteStrategy(new BikeRouteStrategy());
        navigator.Navigate("Praha", "Brno");
    }
}

/*
namespace HelloWorld;
public interface ISortovaciStrategie{List<int> SortujVzestupne(List<int> cisla);List<int> SortujSestupne(List<int> cisla);}
public class BubbleSort:ISortovaciStrategie{
    public List<int> SortujVzestupne(List<int> cisla){
        for (int i = 0; i < cisla.Count - 1; i++){
            for (int j = 0; j < cisla.Count - 1 - i; j++){
                if (cisla[j] > cisla[j + 1]){
                        int temp = cisla[j];
                        cisla[j] = cisla[j + 1];
                        cisla[j + 1] = temp;
                }
            }
        }
        return cisla;
    }
    public List<int> SortujSestupne(List<int> cisla){
        for (int i = 0; i < cisla.Count - 1; i++){
            for (int j = 0; j < cisla.Count - 1 - i; j++){
                if (cisla[j] < cisla[j + 1]){
                        int temp = cisla[j];
                        cisla[j] = cisla[j + 1];
                        cisla[j + 1] = temp;
                }
            }
        }
        return cisla;
    }
}
public class QuickSort:ISortovaciStrategie{
    public List<int> SortujVzestupne(List<int> cisla){
        return QuickSortAlgorithm(cisla, true);
    }
    public List<int> SortujSestupne(List<int> cisla){
        return QuickSortAlgorithm(cisla, false);
    }
    private List<int> QuickSortAlgorithm(List<int> cisla, bool vzestupne){
        if (cisla.Count <= 1) return cisla;

        int pivot = cisla[0];
        List<int> left = new List<int>();
        List<int> right = new List<int>();

        for (int i = 1; i < cisla.Count; i++){
            if ((vzestupne && cisla[i] < pivot) || (!vzestupne && cisla[i] > pivot)){
                    left.Add(cisla[i]);
            } else{
                right.Add(cisla[i]);
            }
        }
        var result = new List<int>();
        result.AddRange(QuickSortAlgorithm(left, vzestupne));
        result.Add(pivot);
        result.AddRange(QuickSortAlgorithm(right, vzestupne));
        return result;
    }
}

class SortovacCisel{
    private ISortovaciStrategie algoritmus;
    public SortovacCisel(ISortovaciStrategie pocatecniStrategie){
        algoritmus = pocatecniStrategie;}
    public void NastavSortovaciAlgoritmus(ISortovaciStrategie novaStrategie){
        algoritmus = novaStrategie;}
    public List<int> Sortuj(List<int> cisla, string jak){
        if (jak == "vzestupne"){
            return algoritmus.SortujVzestupne(cisla);
        } else if (jak == "sestupne"){
            return algoritmus.SortujSestupne(cisla);
        } else{
            throw new ArgumentException("Neznámý způsob třídění: " + jak);}}}
class Program{
    static void Main(string[] args){
        SortovacCisel sortovac = new SortovacCisel(new BubbleSort());
        List<int> cisla = sortovac.Sortuj(new List<int> { 5, 1, 2, 3, 4, 5 }, "vzestupne");
        Console.WriteLine("BubbleSort vzestupně: " + string.Join(", ", cisla));
        sortovac.NastavSortovaciAlgoritmus(new QuickSort());
        cisla = sortovac.Sortuj(new List<int> { 5, 1, 2, 3, 4, 5 }, "vzestupne");
        Console.WriteLine("QuickSort vzestupně: " + string.Join(", ", cisla));

        cisla = sortovac.Sortuj(new List<int> { 5, 1, 2, 3, 4, 5 }, "sestupne");
        Console.WriteLine("QuickSort sestupně: " + string.Join(", ", cisla));
    }
}
*/

