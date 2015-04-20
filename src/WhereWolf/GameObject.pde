public class GameObject extends Updatable{
  
 String name;
 PVector position;
 
 ArrayList<Component> components;
 
 GameObject(){
  components = new ArrayList<Component>(); 
 }
 
 
 //return the first component of type T and null if there isn't
 public Component getComponent(Class cl){
  for(Component c : components){
   if(c.getClass() == cl)
     return c;
  } 
  
  return null;
 }
 
 public boolean addComponent(Component newComponent){
     if(getComponent(newComponent.getClass()) == null){
       components.add(newComponent);
      return true; 
     }
     return false;
 }

 public void draw(){}
 
 public void update(){}
}
