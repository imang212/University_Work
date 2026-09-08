using System.Text.RegularExpressions;
class Program{
    static void Main(){
        SimpleParagraph p = new(new HtmlText("Frodo for president"));
        Console.WriteLine(p.ToText());
    }
}

interface IBlockElement{
}

interface IStructuredText{
    string ToText();
}

class HtmlText : IStructuredText{
    public string Text { get; init; }
    public HtmlText(string text){
        Text = text;
    }
    public string ToText(){
        string output = Text;
        output = Regex.Replace(output, "&", "&amp;");
        output = Regex.Replace(output, ">", "&gt;");
        output = Regex.Replace(output, "<", "&lt;");
        return output;
    }
}
class SimpleParagraph : BaseHtmlElement, IBlockElement{
    public SimpleParagraph(IStructuredText context) : base(context) { }
    public override string ToText(){
        return Context switch{
            IBlockElement => throw new Exception("Invalid HTML"),
            _ => $"<p>{Context.ToText()}</p>"};
    }
}
class InlineTag{
    public const string Bold = "b";
    public const string Italics = "i";
    public const string Span = "span";
}
class SimpleInlineElement : BaseHtmlElement{
    public InlineTag Tag { get; init; }
    public SimpleInlineElement(InlineTag tag, IStructuredText context) : base(context){ 
        Tag = tag;
    }
    public override string ToText(){
        return $"<{Tag}>{Context.ToText()}<{Tag}/>";
    }
}
abstract class BaseHtmlElement : IStructuredText{
    public IStructuredText Context { get; init; }
    public BaseHtmlElement(IStructuredText context){
        Context = context;
    }
    public abstract string ToText();
}