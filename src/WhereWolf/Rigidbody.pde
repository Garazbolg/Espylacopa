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
  
  //start
  public void start(){
    velocity = new PVector();
    collider = (Collider)getGameObject().getComponent(Collider.class);
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
        
        //check for collision on the X axis
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
        //if it is still in collision then nullify this direction
        if(!canX){
          velocity.x = 0;
          vecteur.x = 0;
        }
        
        
        //check for collision on the Y axis
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
        //if it is still in collision then nullify this direction
        if(!canY){
          velocity.y = 0;
          vecteur.y = 0;
        }
      }
      
      
      //Then apply the processed vector to the gameObject
      gameObject.position.add(vecteur);
    }
  }
  
  
  //on Debug Draw
  public void debugDraw(){
    if(!isKinematic){
      stroke(255,0,0);
      line(0,0,velocity.x,velocity.y);
      fill(0,0);
      ellipse(velocity.x,velocity.y,3,3); 


      stroke(0,0,255);
        strokeWeight(5);
          
      PVector vX = PVector.sub(collider.getExtremePoint((velocity.x < 0)?Orientation.West:Orientation.East),gameObject.getPosition());
      float halfDimensionX = (collider.getExtremePoint(Orientation.North).y-gameObject.getPosition().y) * 0.9;
      vX.y -= halfDimensionX;
      halfDimensionX *= 2.0f/collisionPrecision;
          
       PVector vY = PVector.sub(collider.getExtremePoint((velocity.y < 0)?Orientation.North:Orientation.South),gameObject.getPosition());
      float halfDimensionY = (collider.getExtremePoint(Orientation.West).x-gameObject.getPosition().x)*0.9;
      vY.x -= halfDimensionY;
      halfDimensionY *= 2.0f/collisionPrecision;
      
      for(int i=0;i<=collisionPrecision;i++){
        point(vX.x,vX.y+halfDimensionX*i);
        point(vY.x+halfDimensionY*i,vY.y);
      }
      
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
