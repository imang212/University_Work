using System.Globalization


record Interval{
    List<int> p = new List<int>() {1,2,3,4};
    var result:IEnumerable<{Number,BinReminder}> = from item:int in p 
        select new {Number = item, BinRemainder = item % 2}
    var t = (1,2,2);
    public Interval(double lower, double upper) => (Lower, Upper) = (lower, upper);
    public double Lower{ get; init;}
    public double Upper{get;init;}
    public double Length => Upper - Lower
}
class Program{
    public static void Main(){
        Interval i = new Interval(lower:1.0, upper:2.0);
        
    }
}