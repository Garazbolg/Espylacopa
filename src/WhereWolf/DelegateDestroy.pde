// Delegate used to init player specifc for each clients
public class DelegateDestroy extends Delegate{
 
 DelegateDestroy(Component ref){
   super(ref); 
 }
  
 public void call(String [] argv){
   println("DelegateDestroy - Call");
   thisComponent.gameObject.destroy(); 
 }
}


