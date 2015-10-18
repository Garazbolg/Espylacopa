
// Delegate used to init player specifc for each clients
public class DelegateOpenChest extends Delegate{
 
 DelegateOpenChest(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   println("DelegateOpenChest - Call");
   ((Chest)(thisComponent)).openChest(); 
 }
}


