
// Delegate used to init player specifc for each clients
public class DelegateFlipFireSprite extends Delegate{
 
 DelegateFlipFireSprite(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   println("DelegateFlipFireSprite - Call");
   println("argv[0] = " + argv[0]);
   println("boolean(argv[0]) = " + boolean(argv[0]));
   ((Villager)(thisComponent)).flipFireSprite(boolean(argv[0])); 
 }
}


