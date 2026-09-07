using System; using System.Collections.Generic;
public interface ITree{void Display(int x, int y); } // Umístění stromu na dané souřadnice
public class Tree: ITree{
    private readonly string _type; // Sdílený stav: typ stromu
    private readonly string _texture; // Sdílený stav: textura stromu
    public Tree(string type, string texture){ _type = type; _texture = texture; }
    public void Display(int x, int y){Console.WriteLine($"Vykresluji strom typu '{_type}' s texturou '{_texture}' na souřadnicích ({x}, {y}).");}
}
public class TreeFactory{
    private readonly Dictionary<string, Tree> _trees = new Dictionary<string, Tree>();
    public ITree GetTree(string type, string texture){
        string key = $"{type}-{texture}";
        if (!_trees.ContainsKey(key)){
            Console.WriteLine($"Vytvářím nový strom typu '{type}' s texturou '{texture}'.");
            _trees[key] = new Tree(type, texture);
        }
        return _trees[key];
    }
}
public class Forest{
    private readonly List<(ITree tree, int x, int y)> _trees = new List<(ITree tree, int x, int y)>();
    private readonly TreeFactory _treeFactory = new TreeFactory();
    public void PlantTree(string type, string texture, int x, int y){
        ITree tree = _treeFactory.GetTree(type, texture);
        _trees.Add((tree, x, y));
    }
    public void Display(){ foreach (var (tree, x, y) in _trees){ tree.Display(x, y); }}
}
class Program{
    static void Main(){
        Forest forest = new Forest();
        // Sázíme stromy
        forest.PlantTree("Dub", "Zelená textura", 10, 20);
        forest.PlantTree("Dub", "Zelená textura", 15, 25);
        forest.PlantTree("Borovice", "Hnědá textura", 50, 60);
        forest.PlantTree("Borovice", "Hnědá textura", 55, 65);
        // Vykreslíme les
        forest.Display();
    }
}