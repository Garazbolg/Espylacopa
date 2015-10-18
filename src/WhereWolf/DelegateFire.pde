
// Delegate used to init player specifc for each clients
public class DelegateFire extends Delegate{
 
 DelegateFire(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   println("DelegateFire - Call");
   ((Villager)(thisComponent)).fire(); 
 }
}


