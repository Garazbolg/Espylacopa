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
       u.update(); 
 }
}


//Parent class for class that have code to run every frame
public abstract class Updatable{
  
  //ctor
  Updatable(){
    Updatables.add(this);
  }
  
  //start
  public void start(){}
  
  //update
  public void update(){}
}
