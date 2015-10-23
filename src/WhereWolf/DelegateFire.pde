
// Delegate used to init player specifc for each clients
public class DelegateFire extends Delegate{
 
 DelegateFire(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((Villager)(thisComponent)).fire(); 
 }
}


