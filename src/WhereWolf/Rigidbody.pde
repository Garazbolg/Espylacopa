public static class Rigidbodies{
 public static float gravity = 160; 
}

public class Rigidbody extends Component implements DebugDrawable{
  public boolean isKinematic = false;
  public boolean useGravity = true;
  public float mass = 1.0;
  public int collisionPrecision = 5;
  
  private Collider collider;
  
  private PVector velocity;
  
  public void start(){
    velocity = new PVector();
    collider = (Collider)getGameObject().getComponent(Collider.class);
  }
  
  public void update(){
    if(useGravity)
      velocity.y += Rigidbodies.gravity * mass * Time.deltaTime();
      
    PVector vecteur = PVector.mult(velocity,Time.deltaTime());
      
    PVector vX = collider.getExtremePoint((vecteur.x < 0)?Orientation.West:Orientation.East);
    float halfDimensionX = (vX.y - collider.getExtremePoint(Orientation.North).y) * 0.9;
    vX.x += vecteur.x;
    vX.y -= halfDimensionX;
    halfDimensionX *= 2.0f/collisionPrecision;
    boolean canX = true,canY = true;
    for(int i=0;i<=collisionPrecision;i++){
      
      if(collider.inCurrentCollisions(vX.x,vX.y+halfDimensionX*i)){
        canX = false;
        break;
      }
    }
    if(!canX){
      velocity.x = 0;
      vecteur.x = 0;
    }
    
    PVector vY = collider.getExtremePoint((vecteur.y < 0)?Orientation.North:Orientation.South);
    float halfDimensionY = (vY.x - collider.getExtremePoint(Orientation.West).x)*0.9;
    vY.y+=vecteur.y;
    vY.x -= halfDimensionY;
    halfDimensionY *= 2.0f/collisionPrecision;
    for(int i=0;i<=collisionPrecision;i++){
      
      if(collider.inCurrentCollisions(vY.x+halfDimensionY*i,vY.y)){
        canY = false;
        break;
      }
    }
    if(!canY){
      velocity.y = 0;
      vecteur.y = 0;
    }
      
    getGameObject().position.add(vecteur);
  }
  
  public void debugDraw(){
    stroke(255,0,0);
    line(0,0,velocity.x,velocity.y);
    fill(0,0);
    ellipse(velocity.x,velocity.y,3,3); 
    
    
    
    
    
    stroke(0,0,255);
      strokeWeight(5);
        
    PVector vX = PVector.sub(collider.getExtremePoint((velocity.x < 0)?Orientation.West:Orientation.East),gameObject.position);
    float halfDimensionX = (collider.getExtremePoint(Orientation.North).y-gameObject.position.y) * 0.9;
    vX.y -= halfDimensionX;
    halfDimensionX *= 2.0f/collisionPrecision;
        
     PVector vY = PVector.sub(collider.getExtremePoint((velocity.y < 0)?Orientation.North:Orientation.South),gameObject.position);
    float halfDimensionY = (collider.getExtremePoint(Orientation.West).x-gameObject.position.x)*0.9;
    vY.x -= halfDimensionY;
    halfDimensionY *= 2.0f/collisionPrecision;
    
    for(int i=0;i<=collisionPrecision;i++){
      point(vX.x,vX.y+halfDimensionX*i);
      point(vY.x+halfDimensionY*i,vY.y);
    }
    
    strokeWeight(1);
  }
  
  public void setVelocity(PVector vel){
    velocity = vel;
  }
  
  public void addForce(PVector vel){}
}
