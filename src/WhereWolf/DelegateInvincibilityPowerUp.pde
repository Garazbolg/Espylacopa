
// Delegate used to init player specifc for each clients
public class DelegateInvincibilityPowerUp extends Delegate{
 
 DelegateInvincibilityPowerUp(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((GameCharacter)(thisComponent)).applyInvincibilityPowerUp(Integer.parseInt(argv[0])); 
 }
}


