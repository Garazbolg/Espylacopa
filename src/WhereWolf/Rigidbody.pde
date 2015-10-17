/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 17/04/2015 
        Last Modified : 22/04/2015
*/


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
  //Is the rigidbody on an other collider (to know if he can or cannot jump)
  public boolean grounded = false;
  
  //reference of the collider of the gameObject
  private Collider collider;
  
  //current velocity of the gameObject
  private PVector velocity;
  
  //current opposing Vector
  private PVector coll = new PVector();

  
  //start
  public void start(){
    
    if(getGameObject() == null) return;
    
    velocity = new PVector();
    Component c = getGameObject().getComponent(Collider.class);
    if(c != null) collider = (Collider)c;
    
  }
  
  //update
  public void update(){
    //if the rigidbody is kinematic don't apply any forces
    if(!isKinematic){
      
      //apply gravity
      if(useGravity)
        velocity.y += Physics.gravity * mass * Time.deltaTime();
      
            
      //check for collisions
      if(collider != null)
      {
        grounded = false;
        coll = collider.getOppositeVelocity();
        
        //println("coll : (" + coll.x +"," + coll.y +")\n");
                       
        if((coll.y >0.05 && velocity.y < 0) || (coll.y <-0.05 && velocity.y > 0)){
            velocity.y = 0;
            if(coll.y<0){
              grounded = true;
            }
        }
        else
          coll.y = 0;
        
        if((coll.x >0.05 && velocity.x < 0) || (coll.x <-0.05 && velocity.x > 0))
            velocity.x = 0;
        else
          coll.x = 0;
          
          
         if(abs(coll.x) < 0.1f )
            coll.x = 0;
         if(abs(coll.y) < 0.1f )
            coll.y = 0;
        
      }
      
      
      //temporary vector for calculation
      PVector vecteur = PVector.mult(velocity,Time.deltaTime());
      
      //println("absOpposite : (" + collider.absOppositeVecteur.x +","+collider.absOppositeVecteur.y+")");
      /*
      println("velocity : (" + velocity.x +"," + velocity.y +")");
      println("vecteur : (" + vecteur.x +"," + vecteur.y +")");
      println("coll : (" + coll.x +"," + coll.y +")\n");
      */
      
      //Then apply the processed vector to the gameObject
      gameObject.position.add(vecteur);
      gameObject.position.add(PVector.mult(coll,0.99f));
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
