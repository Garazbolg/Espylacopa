
// Delegate used to init player specifc for each clients
public class DelegateDamageMove extends Delegate{
 
 DelegateDamageMove(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((GameCharacter)(thisComponent)).makeMoveCausedByDamage(new PVector(Float.parseFloat(argv[0]), Float.parseFloat(argv[1]))); 
 }
}


