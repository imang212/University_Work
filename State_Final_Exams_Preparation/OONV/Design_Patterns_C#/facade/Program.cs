using System.Xml.XPath;
public class VideoConverter{
    protected VideoFile _videofile; protected Subsystem2 _subsystem2; 
    string filename; string format;
    public VideoConverter(VideoFile videoFile,Subsystem2 subsystem2){this._videofile = videoFile; this._subsystem2 = subsystem2;}
    public void subsystemOperation(string filename, string format){
        Console.WriteLine("Konvertuji video");
        this._videofile.videoCompress();
        this._subsystem2.anotherOperation();
    }}
public class VideoFile{public void videoCompress(){Console.WriteLine("Pristupuji k video souboru");}}
public class Subsystem2{public void anotherOperation(){Console.WriteLine("Spoustim video");}}
class Program{
    static void Main(string[] args){
        VideoFile konvertuj = new VideoFile();
        Subsystem2 spust = new Subsystem2();
        VideoConverter video = new VideoConverter(konvertuj, spust);
        video.subsystemOperation("mp4","asfdsfew");
    }
}