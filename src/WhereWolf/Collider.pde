/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 17/04/2015 
        Last Modified : 22/04/2015
*/


/*
  Static class for managing colliders
*/
public static class Colliders{
  
 //Collection containing every Collider in the Game
 public static ArrayList<Collider> everyColliders = new ArrayList<Collider>(); 
 
 //To add a collider to the collection
 public static void add(Collider c){
   everyColliders.add(c);
 }
 
 //Update
 public static void update(){   
   //Test for every colliders with every other colliders
  for(int i = 0; i< everyColliders.size();i++){
   for(int j = i+1;j< everyColliders.size();j++){
     
         //if they touch
        if(everyColliders.get(i).intersect(everyColliders.get(j))){
               //if either one of them is a trigger
             if(everyColliders.get(i).isTrigger || everyColliders.get(j).isTrigger){
                   //if they weren't already overlapping at the previous frame
                  if(!everyColliders.get(i).currentTriggers.contains(everyColliders.get(j))){
                        //then add them to current Triggers and activate on Trigger Enter for both
                        everyColliders.get(i).currentTriggers.add(everyColliders.get(j));
                        everyColliders.get(j).currentTriggers.add(everyColliders.get(i));
                        everyColliders.get(i).onTriggerEnter(everyColliders.get(j));
                        everyColliders.get(j).onTriggerEnter(everyColliders.get(i));
                  }
                  else{//if they were already overlapping at the previous frame
                        //then apply onTriggerStay
                        everyColliders.get(i).onTriggerStay(everyColliders.get(j));
                        everyColliders.get(j).onTriggerStay(everyColliders.get(i));
                  }
             }
             else{//if none is a trigger
                   //if they weren't already touching at the previous frame
                   if(!everyColliders.get(i).currentCollisions.contains(everyColliders.get(j))){
                        //then add them to current Triggers and activate on Trigger Enter for both
                        everyColliders.get(i).currentCollisions.add(everyColliders.get(j));
                        everyColliders.get(j).currentCollisions.add(everyColliders.get(i));
                        everyColliders.get(i).onCollisionEnter(everyColliders.get(j));
                        everyColliders.get(j).onCollisionEnter(everyColliders.get(i));
                        
                   }
                   else{//if they were already touching at the previous frame
                       //then apply onCollisionsStay
                        everyColliders.get(i).onCollisionStay(everyColliders.get(j));
                        everyColliders.get(j).onCollisionStay(everyColliders.get(i));
                   }
             }
        }
        else{//if the two colliders aren't overlapping
          //if either one of the colliders is a Trigger
          if(everyColliders.get(i).isTrigger || everyColliders.get(j).isTrigger){
            //if they were overlapping last frame then apply onTriggerExit
            if(everyColliders.get(i).currentTriggers.remove(everyColliders.get(j)) && everyColliders.get(j).currentTriggers.remove(everyColliders.get(i))){
               everyColliders.get(i).onTriggerExit(everyColliders.get(j));
               everyColliders.get(j).onTriggerExit(everyColliders.get(i));
            }
          }
          else{//if none is a trigger
          //if they were colliding last frame then apply onCollisionExit
           if(everyColliders.get(i).currentCollisions.remove(everyColliders.get(j)) && everyColliders.get(j).currentCollisions.remove(everyColliders.get(i))){
               everyColliders.get(i).onCollisionExit(everyColliders.get(j));
               everyColliders.get(j).onCollisionExit(everyColliders.get(i));
            } 
          }
        }
   }
  } 
 }
}


/*
  Collision Main class
  To create you need to define a area that will englobe your gameObject
*/
public class Collider extends Component implements DebugDrawable{
  
 //area that represent the collider
 private Area area;
 
 //other Colliders currently in contact with this collider
 private ArrayList<Collider> currentCollisions;
 //other Colliders current overlapping with this collider
 private ArrayList<Collider> currentTriggers;
 
 
 //is this collider a trigger ? (it doesn't prevent Rigidbodies to move through itself)
 public boolean isTrigger = false;
 
 //ctor
 Collider(Area zone){
  area = zone; 
  
  currentCollisions = new ArrayList<Collider>();
  currentTriggers = new ArrayList<Collider>();
  Colliders.add(this);
 }
  
 //is the point pos inside the area of the collider ?
 public boolean inBounds(PVector pos){
  return area.inBounds(PVector.sub(pos,getGameObject().getPosition())); 
 }
 
 //is the point (x,y) inside the area of the collider ?
 public boolean inBounds(float x, float y){
   PVector pos = getGameObject().getPosition();
  return area.inBounds(x-pos.x,y-pos.y); 
 }
 
 
 //Does this collider and an other collider intersect  (Overlap) ?
 public boolean intersect(Collider other){
   Area myArea = (Area)area.clone();
   Area otherArea = (Area)other.area.clone();
   
   myArea.position.add(getGameObject().getPosition());
   otherArea.position.add(other.getGameObject().getPosition());
   
  return myArea.intersect(otherArea);
 }
 
 
 //update
 public void update(){
 }
 
 //return the extreme point of an area for a given orientation (North,South,East,West)
 public PVector getExtremePoint(Orientation o){
   return PVector.add(gameObject.getPosition(),area.getExtremePoint(o));
 }
 
 
 //is the point p inside one of the collider in collision with this collider
 public boolean inCurrentCollisions(PVector p){
   return inCurrentCollisions(p.x,p.y);
 }
 
 
 //is the point (x,y) inside one of the collider in collision with this collider
 public boolean inCurrentCollisions(float x, float y){
   for(Collider c : currentCollisions)
     if(c.inBounds(x,y))
       return true;
       
   return false;
 }


 //What happens when this collider enter in collision with an other collider
 public void onCollisionEnter(Collider other){
   if(Constants.DEBUG_MODE)println(gameObject.name + " Enter Collision with " + other.gameObject.name);
   gameObject.onCollisionEnter(other);
 }
 
 
 //What happens when this collider start to overlap an other collider
 public void onTriggerEnter(Collider other){
   if(Constants.DEBUG_MODE)println(gameObject.name + " Enter Trigger with " + other.gameObject.name);
   gameObject.onTriggerEnter(other);
 }
 
 
 //What happens when this collider is in collision with an other collider
 public void onCollisionStay(Collider other){
   //if(Constants.DEBUG_MODE)println(gameObject.name + " Stay Collision with " + other.gameObject.name);
   gameObject.onCollisionStay(other);
 }
 
 
 //What happens when this collider is overlapping an other collider
 public void onTriggerStay(Collider other){
   //if(Constants.DEBUG_MODE)println(gameObject.name + " Stay Trigger with " + other.gameObject.name);
   gameObject.onTriggerStay(other);
 }
 
 
 //What happens when this collider stop colliding with an other collider
 public void onCollisionExit(Collider other){
   if(Constants.DEBUG_MODE)println(gameObject.name + " Exit Collision with " + other.gameObject.name);
   gameObject.onCollisionExit(other);
 }
 
 //What happens when this collider stop overlapping an other collider
 public void onTriggerExit(Collider other){
   if(Constants.DEBUG_MODE)println(gameObject.name + " Exit Trigger with " + other.gameObject.name);
   gameObject.onTriggerExit(other);
 }
 
 
 //debug Draw
 public void debugDraw(){
   fill(0,0);
   stroke(0,255,0);
   area.draw();
 }
 
 
 
 
}


/*
    Private class to update the static Collider colletion
*/
private class ColliderUpdater extends Updatable{
  
  public void start(){
    Colliders.update();
  }
  
  public void update(){
    Colliders.update();
  }
  
}

private ColliderUpdater myPrivateColliderUpdater = new ColliderUpdater();
