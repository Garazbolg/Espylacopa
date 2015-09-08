/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 17/04/2015 
        Last Modified : 22/04/2015
*/


/*
  Static class for constants use by rigidbodies
*/
public static class Rigidbodies{
 public static float gravity = 350; 
}


/*
  Component that handle movement and gravity
*/
public class Rigidbody extends Component implements DebugDrawable{
  
  //if kinematic forces (including gravity) won't by applied
  public boolean isKinematic = false;
  //should the gameObject be affected by gravity
  public boolean useGravity = true;
  //mass of the gameObject
  public float mass = 1.0;
  
  //reference of the collider of the gameObject
  private Collider collider;
  
  //current velocity of the gameObject
  private PVector velocity;
  
  //current opposing Vector
  private PVector coll = new PVector();
  
  //start
  public void start(){
    velocity = new PVector();
    Component c = getGameObject().getComponent(Collider.class);
    if(c != null)
      collider = (Collider)c;
  }
  
  //update
  public void update(){
    //if the rigidbody is kinematic don't apply any forces
    if(!isKinematic){
      
      //apply gravity
      if(useGravity)
        velocity.y += Rigidbodies.gravity * mass * Time.deltaTime();
      
            
      //check for collisions
      if(collider != null)
      {
        coll = collider.getOppositeVelocity();
        
        PVector coll2 = coll.get();
        print("coll2 : (" +coll2.x +","+coll2.y +")\n");
        
        if(collider.xMoreMagnitude){
          velocity.x = 0;
        }
        if(collider.yMoreMagnitude){
          velocity.y = 0;
        }
        
        if((coll.y >0.001 && velocity.y < 0) || (coll.y <-0.001 && velocity.y > 0)){
          if(abs(collider.absOppositeVecteur.x) > 1f)
            velocity.y = 0;
          else 
            coll.y = 0;
            
          if(abs(coll2.y) < 1f )
            coll.y = 0;
        }
        else
          coll.y = 0;
        
        if((coll.x >0.001 && velocity.x < 0) || (coll.x <-0.001 && velocity.x > 0)){
          if(abs(collider.absOppositeVecteur.y) > 1f)
            velocity.x = 0;
          else
            coll.x = 0;
            
          if(abs(coll2.x) < 1f )
            coll.x = 0;
        }
        else
          coll.x = 0;
          
        
        /*
        if(abs(coll2.x) < 1f )
            coll.x = 0;
        if(abs(coll2.y) < 1f )
            coll.y = 0;
            
        if(collider.xMoreMagnitude){
          velocity.x = 0;
        }
        if(collider.yMoreMagnitude){
          velocity.y = 0;
        }*/
        
      }
      
      //Debug
      if(Constants.DEBUG_MODE){
        strokeWeight(5);
        stroke(0,0,255);
        line(0,0,coll.x,coll.y); 
        strokeWeight(1);
      }
      
      //temporary vector for calculation
      PVector vecteur = PVector.mult(velocity,Time.deltaTime());
      
      println("absOpposite : (" + collider.absOppositeVecteur.x +","+collider.absOppositeVecteur.y+")");
      println("velocity : (" + velocity.x +"," + velocity.y +")");
      println("coll : (" + coll.x +"," + coll.y +")\n");
      //Then apply the processed vector to the gameObject
      gameObject.position.add(vecteur);
      gameObject.position.add(PVector.mult(coll,0.99));
    }
  }
  
  
  //on Debug Draw
  public void debugDraw(){
    if(!isKinematic){
      stroke(255,0,0);
      line(0,0,velocity.x,velocity.y);
      fill(0,0);
      ellipse(velocity.x,velocity.y,3,3);
      
      strokeWeight(1);
    }
  }
  
  
  //to set the velocity of the gameObject
  public void setVelocity(PVector vel){
    velocity = vel;
  }
  
  public PVector getVelocity(){
    return velocity; 
  }
  
  //to apply a force on the gameObject
  public void addForce(PVector vel){}
}
