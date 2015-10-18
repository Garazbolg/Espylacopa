
// Delegate used to init player specifc for each clients
public class DelegateTransformToHuman extends Delegate{
 
 DelegateTransformToHuman(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((Werewolf)(thisComponent)).transformToHuman(); 
 }
}


