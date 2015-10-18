
// Delegate used to init player specifc for each clients
public class DelegateSetXvelocity extends Delegate{
 
 DelegateSetXvelocity(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   ((GameCharacter)(thisComponent)).setXvelocity(Float.parseFloat(argv[0])); 
 }
}


