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
    for(int i=0 ; i<items.size() ; i++){
      items.get(i).start();
    }
    
    alreadyStarted = true;
 }
 
 //Updatables.update() to put at the start of the draw function of the main
 public static void update(){
   for(int i = 0; i<items.size(); i++)
       if(items.get(i).isActive())
         items.get(i).update(); 
 }
 
 public static boolean destroy(Updatable u){
  return items.remove(u); 
 }
}


//Parent class for class that have code to run every frame
public abstract class Updatable{
  
  private boolean activeSelf;
  private boolean activeInHierarchy;
  
  //ctor
  public Updatable(){
    activeSelf = true;
    activeInHierarchy = true;
    Updatables.add(this);
  }
  
  
 public void setActive(boolean state){
   boolean last = isActive();
   activeSelf = state;
   if(last && !isActive()){
      OnDisable(); 
   }
   else if(!last && isActive()){
      OnEnable();     
   }
 }
 
 public void setActiveInHierarchy(boolean state){
   boolean last = isActive();
   activeInHierarchy = state; 
   if(last && !isActive()){
      OnDisable(); 
   }
   else if(!last && isActive()){
      OnEnable();     
   }
 }
 
 public boolean isActive(){
   return  activeSelf && activeInHierarchy;
 }
  
  //start
  public void start(){}
  
  //update
  public void update(){}
  
  //OnEnable
  public void OnEnable(){}
  
  //OnDisable
  public void OnDisable(){}
  
  public void OnDestroy(){
    Updatables.destroy(this);
  }
}
