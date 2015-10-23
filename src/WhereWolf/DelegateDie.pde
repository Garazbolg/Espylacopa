
// Delegate used to init player specifc for each clients
public class DelegateDie extends Delegate{
 
 DelegateDie(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((GameCharacter)(thisComponent)).die(); 
 }
}


