public abstract class Component extends Updatable{
 public GameObject gameObject;
  
 void start(){}

 void update(){}
 
 GameObject getGameObject(){
   return gameObject;
 }
}
