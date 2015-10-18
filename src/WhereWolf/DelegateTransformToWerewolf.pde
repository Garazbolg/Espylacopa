
// Delegate used to init player specifc for each clients
public class DelegateTransformToWerewolf extends Delegate{
 
 DelegateTransformToWerewolf(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((Werewolf)(thisComponent)).transformToWerewolf(); 
 }
}


