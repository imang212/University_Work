//facade, je další úroveň závislosti, cílem je zmenšení závislosti
//bridge - IA: A1,A2,A3(high level), A.. používá metody rozhraní IB 
//         IB: B1, B2, B2 (low level interface) 
//         (A1)B1 (A1)B2 (A1)B3 ... (A3)B1 ... (A3)B3 - n*n = 9 tříd implementačních
// bridge: -> m+n tříd
// IShape: Rectangle, Ellipse, Line, Polygon, ...
// GUI knihovna? Winforms, Avalonia, WPF, Qt#
// každý objekt třídy implementující IShape má odkaz na IMultiPainter
// IMultipainter: kreslení primitiv: DrawPath
// r = new Rectange(canvas, ...); r.Draw() impl->DrawPath(....); #impl. je z IMultipainter
using System.Drawing;
interface Ishape{void Draw(int x, int y);}
//TODO: Rectangle, Line,
interface IPath{void DrawPath(params BezierSegment[] segments);}
//TODO: WinForms, Avalonia, PDF
class BezierSegment(Point start, Point end, Point control){
    private readonly Point _start = start;
    private readonly Point _end = end;
    private readonly Point _control = control;}
record struct Point{int x, y;}
class PathSegment{Point GetStartPoint { get; } Point GetEndPoint{ get; }}
class Line:Ishape{
    private Point _start; private Point _end;
    public Line(Point start, Point end){_start = start;_end = end;}
    public void Draw(int x, int y){Console.WriteLine($"Drawing Line from ({_start.x}, {_start.y}) to ({_end.x}, {_end.y})");}
}
class Rectangle:Ishape{
    private Point _topLeft; private int _width; private int _height;
    public Rectangle(Point topLeft, int width, int height){_topLeft = topLeft;_width = width;_height = height;}
    public void Draw(int x, int y){Console.WriteLine($"Drawing Rectangle at ({_topLeft.x}, {_topLeft.y}) with width {_width} and height {_height}");}
}
class PathRenderer:IPath{
    public void DrawPath(params BezierSegment[] segments){
        foreach (var segment in segments){
            Console.WriteLine($"Drawing BezierSegment from {segment.Start} to {segment.End} with control {segment.Control}");
        }
    }
}
class Program{
    static void Main(){
    Ishape line = new Line(new Point { x = 0, y = 0 }, new Point { x = 10, y = 10 });
    line.Draw(0, 0);
    Ishape rectangle = new Rectangle(new Point { x = 5, y = 5 }, 20, 15);
    rectangle.Draw(0, 0);
    IPath path = new PathRenderer();
    path.DrawPath(new BezierSegment(new Point { x = 0, y = 0 }, new Point { x = 10, y = 10 }, new Point { x = 5, y = 5 }),
            new BezierSegment(new Point { x = 10, y = 10 }, new Point { x = 20, y = 20 }, new Point { x = 15, y = 15 }));
    }
}