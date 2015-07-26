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
  //Precision of the collision detection the higher the better but ressource consuming ( the bigger the higher it needs to be)
  public int collisionPrecision = 5;
  
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
      
      //temporary vector for calculation
      PVector vecteur = PVector.mult(velocity,Time.deltaTime());
      
      //check for collisions
      //by check if points that are on the border
      //would still be in the colliders that the collider is already in collision with
      //after apllying the vector
      if(collider != null)
      {
        coll = collider.getOppositeVelocity();
        
        PVector coll2 = coll.get();
        
        if(coll.y >0.01 && velocity.y < 0){
          if(abs(coll2.x) > 5f ){
            velocity.y = 0;
            vecteur.y = 0;
           }
          else
            coll.y = 0;
        }
        else if(coll.y <-0.01 && velocity.y > 0){
          if(abs(coll2.x) > 5f ){
            velocity.y = 0;
            vecteur.y = 0;
          }
          else
            coll.y = 0;
        }
        else
          coll.y = 0;
        
        
        if(coll.x >0.01 && velocity.x < 0){
          if(abs(coll2.y) > 5f ){
            velocity.x = 0;
            vecteur.x = 0;
          }
          else
            coll.x = 0;
        }
        else if(coll.x <-0.01 && velocity.x > 0){
          if(abs(coll2.y) > 5f ){
            velocity.x = 0;
            vecteur.x = 0;
          }
          else
            coll.x = 0;
        }
        else
          coll.x = 0;
          
        
          
      }
      
      //Debug
      if(Constants.DEBUG_MODE){
        stroke(0,0,255);
        line(0,0,coll.x,coll.y); 
      }
      
      
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
