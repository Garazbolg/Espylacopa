public static class Rigidbodies{
 public static float gravity = 160; 
}

public class Rigidbody extends Component implements DebugDrawable{
  public boolean isKinematic = false;
  public boolean useGravity = true;
  public float mass = 1.0;
  
  
  
  private PVector velocity;
  
  public void start(){
    velocity = new PVector();
  }
  
  public void update(){
    if(useGravity)
      velocity.y += Rigidbodies.gravity * mass * Time.deltaTime();
    getGameObject().position.add(PVector.mult(velocity,Time.deltaTime()));
  }
  
  public void debugDraw(){
    stroke(255,0,0);
    line(0,0,velocity.x,velocity.y);
    fill(0,0);
    ellipse(velocity.x,velocity.y,3,3); 
  }
  
  public void setVelocity(PVector vel){
    velocity = vel;
  }
  
  public void addForce(PVector vel){}
}
