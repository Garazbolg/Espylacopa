public static class Colliders{
 public static ArrayList<Collider> everyColliders = new ArrayList<Collider>(); 
 
 public static void add(Collider c){
   everyColliders.add(c);
 }
 
 public static void update(){   
   //Test for every colliders with every other colliders
  for(int i = 0; i< everyColliders.size();i++){
   for(int j = i;j< everyColliders.size();j++){
     
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
                        everyColliders.get(i).onCollisionsEnter(everyColliders.get(j));
                        everyColliders.get(j).onCollisionsEnter(everyColliders.get(i));
                        
                   }
                   else{//if they were already touching at the previous frame
                       //then apply onCollisionsStay
                        everyColliders.get(i).onTriggerStay(everyColliders.get(j));
                        everyColliders.get(j).onTriggerStay(everyColliders.get(i));
                   }
             }
        }
        else{
          if(everyColliders.get(i).isTrigger || everyColliders.get(j).isTrigger){
            if(everyColliders.get(i).currentTriggers.remove(everyColliders.get(j)) || everyColliders.get(j).currentTriggers.remove(everyColliders.get(i))){
               everyColliders.get(i).onTriggerExit(everyCOlliders.get(j));
               everyColliders.get(j).onTriggerExit(everyCOlliders.get(i));
            }
          }
          else{
           if(everyColliders.get(i).currentCollisions.remove(everyColliders.get(j)) || everyColliders.get(j).currentCollisions.remove(everyColliders.get(i))){
               everyColliders.get(i).onCollisionExit(everyCOlliders.get(j));
               everyColliders.get(j).onCollisionExit(everyCOlliders.get(i));
            } 
          }
        }
   }
  } 
 }
 
 
 
}



public class Collider extends Component{
 private Area area;
 
 public ArrayList<Collider> currentCollisions;
 public ArrayList<Collider> currentTriggers;
 
 public boolean isTrigger = false;
 
 Collider(Area zone){
  area = zone; 
  
  newCollisions = new ArrayList<Collider>();
  currentCollisions = new ArrayList<Collider>();
  newTriggers = new ArrayList<Collider>();
  currentTriggers = new ArrayList<Collider>();
  
 }
  
 public boolean inBounds(PVector pos){
  return area.inBounds(pos); 
 }
 
 public boolean inBounds(float x, float y){
  return area.inBounds(x,y); 
 }
 
 public boolean intersect(Collider other){
  return area.intersect(other.area); 
 }
 
 public void update(){
 }

 public void onCollisionEnter(Collider other){}
 
 public void onTriggerEnter(Collider other){}
 
 public void onCollisionStay(Collider other){}
 
 public void onTriggerStay(Collider other){}
 
 public void onCollisionExit(Collider other){}
 
 public void onTriggerExit(Collider other){}
 
}
