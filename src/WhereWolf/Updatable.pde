/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 20/04/2015 
        Last Modified : 22/04/2015
*/


/*
  Static class managing class that have code to run every frame
*/
public static class Updatables{
 private static ArrayList<Updatable> items = new ArrayList<Updatable>(); 
 private static boolean alreadyStarted = false;
 
 
 //to add a Updatable to items
 public static void add(Updatable u){
    items.add(u); 
    if(alreadyStarted)
      u.start();
 }
 
 
 //Updatables.start() to put at the end of the start function of the main 
  public static void start(){
    for(Updatable u : items)
       u.start(); 
       
    alreadyStarted = true;
 }
 
 //Updatables.update() to put at the start of the draw function of the main
 public static void update(){
    for(Updatable u : items)
       if(u.activeSelf && u.activeInHierarchy)
         u.update(); 
 }
}


//Parent class for class that have code to run every frame
public abstract class Updatable{
  
  protected boolean activeSelf;
  protected boolean activeInHierarchy;
  
  //ctor
  Updatable(){
    active = true;
    activeInHierarchy = true;
    Updatables.add(this);
  }
  
  
 public void setActive(boolean state){
   boolean last = activeSelf && activeInHierarchy;
   activeSelf = state;
   if(last && !(activeSelf && activeInHierarchy)){
      OnDisable(); 
   }
   else if(!last && (activeSelf && activeInHierarchy)){
      OnEnable();     
   }
 }
 
 public void setActiveInHierarchy(boolean state){
   boolean last = activeSelf && activeInHierarchy;
   activeInHierarchy = state; 
   if(last && !(activeSelf && activeInHierarchy)){
      OnDisable(); 
   }
   else if(!last && (activeSelf && activeInHierarchy)){
      OnEnable();     
   }
 }
  
  //start
  public void start(){}
  
  //update
  public void update(){}
  
  //OnEnable
  public void OnEnable(){}
  
  //OnDisable
  public void OnDisable(){}
}
