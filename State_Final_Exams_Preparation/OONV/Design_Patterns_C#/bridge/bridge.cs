abstract class Device{
    public bool isEnabled{get; protected set;}
    public Device(){this.isEnabled=false;this.getChannel=0;this.getVolume=0;}
    public void enable(){this.isEnabled = true;}
    public void disable(){this.isEnabled = false;}
    public int getVolume{get; protected set;}
    public abstract void setVolume(int newVolume);
    public int getChannel{get; protected set;}
    public abstract void setChannel(int newChannel);
}
class Remote{
    private Device zarizeni;
    public Remote(Device parovane_zarizeni){ this.zarizeni = parovane_zarizeni; }    
    public void togglePower(){
        if(this.zarizeni.isEnabled == true){this.zarizeni.disable();Console.WriteLine("Televize se vypla");}
        else{ this.zarizeni.enable(); Console.WriteLine("Televize se zapla");}
    }
}
class Televize: Device{
    private int max_channels=50;
    public override void setVolume(int newVolume){
        Console.WriteLine("Zvuk sel nahoru");
        this.getVolume = newVolume > 0 && newVolume < 100 ? newVolume : this.getVolume;
    }
    public override void setChannel(int newChannel){
        Console.WriteLine("Prepnul jsem na dalsi program");
        this.getChannel = newChannel > 0 && newChannel < this.max_channels ? newChannel : this.getChannel;
    }
}
class Program{
    static void Main(string[] args){
        Device telka = new Televize();
        telka.setChannel(1);
        Remote ovladani = new Remote(telka);
        ovladani.togglePower();
    }
}