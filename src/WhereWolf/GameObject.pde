public class GameObject extends Updatable implements Drawable,DebugDrawable{
  
 String name;
 PVector position;
 
 ArrayList<Component> components;
 ArrayList<GameObject> children;
 
 GameObject(String n, PVector pos){
   position = pos;
   name = n;
  components = new ArrayList<Component>(); 
  children = new ArrayList<GameObject>();
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
   if(!children.contains(nGameObject))
     children.add(nGameObject);
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
}
