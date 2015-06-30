/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 17/04/2015 
        Last Modified : 22/04/2015
*/

public static class Scene{
 private static GameObject root;
 
 public static void startScene(GameObject g){
  root =  g;
 }
 
 public static void addChildren(GameObject g){
   root.addChildren(g); 
 }
 
 public static void draw(){
  root.draw(); 
 }
 
 public static void debugDraw(){
  root.debugDraw(); 
 }
}


/**/

public class GameObject extends Updatable implements Drawable,DebugDrawable{
  
 String name;
 public PVector position;
 
 private ArrayList<Component> components;
 private ArrayList<GameObject> children;
 private GameObject parent;
 public RPCHolder rpcHolder;
 
 GameObject(String n, PVector pos){
   position = pos;
   name = n;
  components = new ArrayList<Component>(); 
  children = new ArrayList<GameObject>();
  parent = null;
  Scene.addChildren(this);
  rpcHolder = new RPCHolder();
 }
 
 GameObject(String n, PVector pos,GameObject newParent){
   position = pos;
   name = n;
  components = new ArrayList<Component>(); 
  children = new ArrayList<GameObject>();
  parent = null;
  if(newParent != null)
    newParent.addChildren(this);
 }
 
 public PVector getPosition(){
  if(parent != null)
     return PVector.add(parent.getPosition(),position);
    
  return position; 
 }
 
 //return the first component of type T and null if there isn't
 public Component getComponent(Class cl){
  for(Component c : components){
   if(c.getClass() == cl)
     return c;
  } 
  
  return null;
 }
 
 public void addChildren(GameObject nGameObject){
   if(!children.contains(nGameObject)){
     children.add(nGameObject);
     if(nGameObject.parent != null)
       nGameObject.parent.children.remove(nGameObject);
     nGameObject.parent = this;
   }
 }
 
 public boolean addComponent(Component newComponent){
     if(newComponent.gameObject == null && getComponent(newComponent.getClass()) == null){
       components.add(newComponent);
       newComponent.gameObject = this;
      return true; 
     }
     return false;
 }

 public void draw(){
     pushMatrix();
     translate(position.x,position.y);
     
     Renderer render = (Renderer) getComponent(Renderer.class);
     if(render != null)
       render.draw();
       
     for(Component c : components){
      if(c instanceof Drawable){
       Drawable d = (Drawable)c;
       d.draw();
      } 
     }
     
     for(GameObject g : children){
      g.draw(); 
     }
     
     popMatrix();
 }
 
 public void debugDraw(){
   pushMatrix();
   translate(position.x,position.y);
   for(GameObject g : children){
      g.debugDraw(); 
     }
   
    for(Component c : components){
      if(c instanceof DebugDrawable){
       DebugDrawable d = (DebugDrawable)c;
       d.debugDraw();
      } 
     }
     
   fill(0);
   stroke(0);
   text(name,-textWidth(name)/2,0);
   popMatrix();
 }
 
 public void update(){}
 
 
 
  //What happens when the collider of the gameObject enter in collision with an other collider
 public void onCollisionEnter(Collider other){
    for(Component c : components)
       if(! (c instanceof Collider))
          c.onCollisionEnter(other);
 }
  
 //What happens when the collider of the gameObject start to overlap an other collider
 public void onTriggerEnter(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onTriggerEnter(other);
 }
  
 //What happens when the collider of the gameObject is in collision with an other collider
 public void onCollisionStay(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onCollisionStay(other);
 }
 
 //What happens when the collider of the gameObject is overlapping an other collider
 public void onTriggerStay(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onTriggerStay(other);
 }
  
 //What happens when the collider of the gameObject stop colliding with an other collider
 public void onCollisionExit(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onCollisionExit(other);
 }
 
 //What happens when the collider of the gameObject stop overlapping an other collider
 public void onTriggerExit(Collider other){
   for(Component c : components)
       if(! (c instanceof Collider))
          c.onTriggerExit(other);
 }
}
