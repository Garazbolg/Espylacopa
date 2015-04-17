public class GameObject extends Updatable{
  
 String name;
 PVector position;
 
 ArrayList<Component> components;
 
 GameObject(){
  components = new ArrayList<Component>(); 
 }
 
 
 //return the first component of type T and null if there isn't
 public <T> Component getComponent(){
   T compareTo = null;
   
  for(Component c : components){
   if(c.getClass() == compareTo.getClass())
     return c;
  } 
  
  return null;
 }

 public void draw(){}
 
 public void update(){}
}
