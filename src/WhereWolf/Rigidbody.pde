public static class Rigidbodies{
 private static ArrayList<Rigidbody> items = new ArrayList<Rigidbody>(); 
 
 public static void add(Rigidbody u){
    items.add(u); 
 }
 
 public static void update(){
    for(Rigidbody u : items){
      
    }
 }
}

public class Rigidbody extends Component{
  public boolean isKinematic = false;
  public boolean useGravity = true; 
  
  private PVector velocity;
  
  public void start(){
    
  }
  
  public void setVelocity(PVector vel){
    velocity = vel;
  }
  
  public void addForce(PVector vel){}
}
