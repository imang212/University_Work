public interface Component{ public void execute(); }
public abstract class Zakladni_decorator: Component{
    public Component wrappee;
    public Zakladni_decorator(Component c){ this.wrappee = c;}
    public virtual void execute(){wrappee.execute();}
}
public class Kavovar: Component{public void execute(){Console.WriteLine("Udelal jsem první věc");}    }
public class Mlekovar: Zakladni_decorator{
    public Mlekovar(Component wrapper): base(wrapper) {}
    public override void execute(){base.execute(); ExtraUkon();}
    public void ExtraUkon(){Console.WriteLine("Udelal jsem druhou věc");}
}
public class Cukrovar: Zakladni_decorator{
    public Cukrovar(Component wrapper): base(wrapper){}
    public override void execute(){base.execute();ExtraUkon();}
    public void ExtraUkon(){Console.WriteLine("Udelal jsem třetí věc");}
}
class Program{
    static void Main(string[] args){
        Component kavovar = new Kavovar();
        kavovar.execute();
        Component doplnek = new Mlekovar(kavovar);
        doplnek.execute();
        Component dalsi_doplnek = new Cukrovar(doplnek);
        dalsi_doplnek.execute();
    }
}

//abstract class Device{
//    public bool PoweredOn {get; protected set;}
//    public int ActualVolume {get; protected set;}
//    public int ActualChannel {get; protected set;}
//    public Device(){this.PoweredOn = false; this.ActualChannel = 0; this.ActualVolume = 0;}
//    public void TurnOn(){this.PoweredOn = true;}
//    public void TurnOff(){this.PoweredOn = false;}
//    protected abstract void SetVolume(int newVolume);
//    protected abstract void SetChannel(int newChannel);}
//class Televize: Device{
//    private int _maxChannels = 50;
//    protected override void SetVolume(int newVolume){
//        System.Console.WriteLine("Posilam do baze vetsi proud ... ja televize");
//        this.ActualVolume = newVolume > 0 && newVolume < 100 ? newVolume : this.ActualVolume;}
//    protected override void SetChannel(int newChannel){
//        System.Console.WriteLine("Vybiram dalsi bitovou sekvenci v poradi na dig. multiplexu");
//        this.ActualChannel = newChannel > 0 && newChannel < this._maxChannels ? newChannel : this.ActualChannel;}}
//class Remote{
//    private Device _pairedDevice;
//    public Remote(Device pairedDevice){this._pairedDevice = pairedDevice;}
//    public void TogglePower(){
//        if (this._pairedDevice.PoweredOn == true){this._pairedDevice.TurnOff();} 
//        else {this._pairedDevice.TurnOn();}}}
//
//class Program{
//    static void Main(string[] args){
//
//    }
//}
//
//--------------------------------------------------------------------------------------------------------------------------
//public interface IComponent{void ProvedUkon();}
//public abstract class Prislusenstvi:IComponent{
//    private IComponent wrapik;
//    public Prislusenstvi(IComponent wrapik){this.wrapik = wrapik;}
//    public virtual void ProvedUkon(){wrapik.ProvedUkon();}}
//public class Kavovar:IComponent{
//    public void ProvedUkon(){Console.WriteLine("Uvaril jsem kavu.");}}
//public class Mlekovar:Prislusenstvi{
//    public Mlekovar(IComponent wrapik) : base(wrapik) { }
//    public override void ProvedUkon(){base.ProvedUkon(); ExtraUkon();}
//    public void ExtraUkon(){Console.WriteLine("Pridal jsem mleko.");}}
//public class Cukrovar:Prislusenstvi{
//    public Cukrovar(IComponent wrapik) : base(wrapik) { }
//    public override void ProvedUkon(){base.ProvedUkon();ExtraUkon();}
//    public void ExtraUkon(){Console.WriteLine("Pridal jsem cukr.");}}
//class Program{
//        static void Main(string[] args){
//            IComponent kavovar = new Kavovar();
//            kavovar.ProvedUkon();
//            IComponent mlekoKavovar = new Mlekovar(kavovar);
//            mlekoKavovar.ProvedUkon();
//            IComponent cukroMlekoKavovar = new Cukrovar(mlekoKavovar);
//            cukroMlekoKavovar.ProvedUkon();}}