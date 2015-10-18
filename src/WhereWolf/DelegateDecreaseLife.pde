
// Delegate used to init player specifc for each clients
public class DelegateDecreaseLife extends Delegate{
 
 DelegateDecreaseLife(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   println("DelegateDecreaseLife - Call");
   ((GameCharacter)(thisComponent)).DecreaseLife(Integer.parseInt(argv[0]), new PVector(Float.parseFloat(argv[1]), Float.parseFloat(argv[2]))); 
 }
}


