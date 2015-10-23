
// Delegate used to init player specifc for each clients
public class DelegateBlink extends Delegate{
 
 DelegateBlink(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((GameCharacter)(thisComponent)).activateBlinkOfInvulnerability(Integer.parseInt(argv[0])); 
 }
}


