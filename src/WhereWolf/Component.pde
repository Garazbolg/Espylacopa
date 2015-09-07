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
 
 
 /*
   Use to declare a RPC Function to be called remotely
   Exemple :
   
void start(){
  super.start();
  
  //Do your usual start  
  
  //And then :
   addRPC("RPCFunctionName",new Delegate(this){public void call(String [] argv){
     if(Network.isServer){
         //  Code your server behaviour here
     }
     else{
         //  Code you client Behaviour here
     }
     
     this.Myfunction(String[] argv);
        
   }});
}


  You can use thisComponent to reference the object on wich the callback is called but remember to cast it to your component class

 */
 protected void addRPC(String callbackName,Delegate implementation){
   gameObject.rpcHolder.addRPC(callbackName,implementation);
 }
 
 
 //Function to override for collision effect
 
  //What happens when the collider of the gameObject enter in collision with an other collider
 public void onCollisionEnter(Collider other){}
  
 //What happens when the collider of the gameObject start to overlap an other collider
 public void onTriggerEnter(Collider other){}
  
 //What happens when the collider of the gameObject is in collision with an other collider
 public void onCollisionStay(Collider other){}
 
 //What happens when the collider of the gameObject is overlapping an other collider
 public void onTriggerStay(Collider other){}
  
 //What happens when the collider of the gameObject stop colliding with an other collider
 public void onCollisionExit(Collider other){}
 
 //What happens when the collider of the gameObject stop overlapping an other collider
 public void onTriggerExit(Collider other){}
 
}
