
// Delegate used to init player specifc for each clients
public class DelegateInitPlayer extends Delegate{
 
 DelegateInitPlayer(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   println("DelegateInitPlayer - Call");
   ((GameCharacter)(thisComponent)).initPlayer(); 
 }
}


