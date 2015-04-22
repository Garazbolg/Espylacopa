/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 17/04/2015 
        Last Modified : 22/04/2015
*/


/*
*/
public abstract class Component extends Updatable{
 public GameObject gameObject;
  
 void start(){}

 void update(){}
 
 GameObject getGameObject(){
   return gameObject;
 }
}
