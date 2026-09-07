using System;using System.IO;
abstract class FileLoader{ //game ai
    public void LoadFile(string filePath){ if (!File.Exists(filePath)){Console.WriteLine("Soubor neexistuje.");return;}
        // Template Method - definuje kroky algoritmu    
        OpenFile(filePath);ReadFileContent(filePath);ProcessFileData();CloseFile(); //kroky algoritmu
    }
    protected virtual void OpenFile(string filePath){Console.WriteLine($"Otevírám soubor: {filePath}");} //Otevření souboru - může být přepsán podtřídou
    protected abstract void ReadFileContent(string filePath); //Načtení obsahu souboru - povinný pro potomky
    protected abstract void ProcessFileData(); //Zpracování dat - povinný pro potomky
    protected virtual void CloseFile(){Console.WriteLine("Zavírám soubor.");} //Zavření souboru - může být přepsán podtřídou
}
class TextFileLoader: FileLoader{ //orcs ai
    private string fileContent;
    protected override void ReadFileContent(string filePath){Console.WriteLine("Načítám obsah textového souboru..."); fileContent = File.ReadAllText(filePath);}
    protected override void ProcessFileData(){Console.WriteLine("Zpracovávám textová data..."); Console.WriteLine($"Obsah souboru:{fileContent}");}
}
class BinaryFileLoader: FileLoader{ // monsters ai
    private byte[] fileData;
    protected override void ReadFileContent(string filePath){Console.WriteLine("Načítám obsah binárního souboru..."); fileData = File.ReadAllBytes(filePath);}
    protected override void ProcessFileData(){Console.WriteLine("Zpracovávám binární data..."); Console.WriteLine($"Počet načtených bajtů: {fileData.Length}");}
}
class Program{
    static void Main(){
        string textFilePath = "data.txt";string binaryFilePath = "data.bin";
        FileLoader textLoader = new TextFileLoader();
        textLoader.LoadFile(textFilePath);
        //Console.WriteLine();
        //FileLoader binaryLoader = new BinaryFileLoader(); binaryLoader.LoadFile(binaryFilePath);
    }
}
/*
using System.Globalization;
namespace HelloWorld;

abstract class SumFileAnalyzer{
    public int SumFileData(string filePath){ //Template Method
        StreamReader sr = OpenFile(filePath);
        string fileContent = ReadFileContent(sr);
        List<int> parsedNumbers = ParseNumbers(fileContent); // <------------------
        int sumOfFileNumbers = SumNumbers(parsedNumbers);
        return sumOfFileNumbers;
    }

    public StreamReader OpenFile(string filePath){
        return new StreamReader(filePath);
    }

    public string ReadFileContent(StreamReader sr){
        string content = sr.ReadToEnd();
        sr.Close();
        return content;
    }

    public abstract List<int> ParseNumbers(string fileContent); // <-----------------

    public int SumNumbers(List<int> numbers){
        return numbers.Sum();
    }
}

class CSVSumFileAnalyzer: SumFileAnalyzer{
    public override List<int> ParseNumbers(string fileContent){
        var lines = fileContent.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
        var numbers = new List<int>();

        foreach (var line in lines){
            var values = line.Split(',');
            foreach (var value in values){
                if (int.TryParse(value.Trim(), out int number)){numbers.Add(number);}
            }
        }
        return numbers;
    }
}
class XMLSumFileAnalyzer: SumFileAnalyzer{
    public override List<int> ParseNumbers(string fileContent){
        var numbers = new List<int>();
        var lines = fileContent.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
        foreach (var line in lines){
            if (line.Contains("<number>") && line.Contains("</number>")){
                var start = line.IndexOf("<number>") + 8;
                var end = line.IndexOf("</number>");
                var numberString = line.Substring(start, end - start);           
                if (int.TryParse(numberString, out int number)){numbers.Add(number);}
            }
        }
        return numbers;    
    }
}
class Program{
    static void Main(string[] args){
        string csvFilePath = "numbers.csv"; string xmlFilePath = "numbers.xml";
        SumFileAnalyzer csvAnalyzer = new CSVSumFileAnalyzer();
        int csvSum = csvAnalyzer.SumFileData(csvFilePath);
        Console.WriteLine($"Sum of CSV numbers: {csvSum}");
        SumFileAnalyzer xmlAnalyzer = new XMLSumFileAnalyzer();
        int xmlSum = xmlAnalyzer.SumFileData(xmlFilePath);
        Console.WriteLine($"Sum of XML numbers: {xmlSum}");
    }
}
*/