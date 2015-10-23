
// Delegate used to init player specifc for each clients
public class DelegateDamageMultiplicator extends Delegate{
 
 DelegateDamageMultiplicator(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((GameCharacter)(thisComponent)).setDamageMultiplicator(Float.parseFloat(argv[0])); 
 }
}


