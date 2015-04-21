public static class Colliders{
 public static ArrayList<Collider> everyColliders = new ArrayList<Collider>(); 
 
 public static void add(Collider c){
   everyColliders.add(c);
 }
 
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
        else{
          if(everyColliders.get(i).isTrigger || everyColliders.get(j).isTrigger){
            if(everyColliders.get(i).currentTriggers.remove(everyColliders.get(j)) && everyColliders.get(j).currentTriggers.remove(everyColliders.get(i))){
               everyColliders.get(i).onTriggerExit(everyColliders.get(j));
               everyColliders.get(j).onTriggerExit(everyColliders.get(i));
            }
          }
          else{
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



public class Collider extends Component implements DebugDrawable{
 private Area area;
 
 public ArrayList<Collider> currentCollisions;
 public ArrayList<Collider> currentTriggers;
 
 public boolean isTrigger = false;
 
 Collider(Area zone){
  area = zone; 
  
  currentCollisions = new ArrayList<Collider>();
  currentTriggers = new ArrayList<Collider>();
  Colliders.add(this);
 }
  
 public boolean inBounds(PVector pos){
  return area.inBounds(PVector.sub(pos,getGameObject().position)); 
 }
 
 public boolean inBounds(float x, float y){
   PVector pos = getGameObject().position;
  return area.inBounds(x-pos.x,y-pos.y); 
 }
 
 public boolean intersect(Collider other){
   Area myArea = (Area)area.clone();
   Area otherArea = (Area)other.area.clone();
   
   myArea.position.add(getGameObject().position);
   otherArea.position.add(other.getGameObject().position);
   
  return myArea.intersect(otherArea);
 }
 
 public void update(){
 }

 public void onCollisionEnter(Collider other){
   println(getGameObject().name + " Enter Collision with " + other.getGameObject().name);
 }
 
 public void onTriggerEnter(Collider other){
   println(getGameObject().name + " Enter Trigger with " + other.getGameObject().name);
 }
 
 public void onCollisionStay(Collider other){
   //println(getGameObject().name + " Stay Collision with " + other.getGameObject().name);
 }
 
 public void onTriggerStay(Collider other){
   //println(getGameObject().name + " Stay Trigger with " + other.getGameObject().name);
 }
 
 public void onCollisionExit(Collider other){
   println(getGameObject().name + " Exit Collision with " + other.getGameObject().name);
 }
 
 public void onTriggerExit(Collider other){
   println(getGameObject().name + " Exit Trigger with " + other.getGameObject().name);
 }
 
 public void debugDraw(){
   fill(0,0);
   stroke(0,255,0);
   area.draw();
 }
 
 
 
 
}

private class ColliderUpdater extends Updatable{
  
  public void start(){
    Colliders.update();
  }
  
  public void update(){
    Colliders.update();
  }
  
}

private ColliderUpdater myPrivateColliderUpdater = new ColliderUpdater();
