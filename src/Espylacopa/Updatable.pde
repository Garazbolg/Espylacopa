//Parent class for class that have code to run every frame


//Holder for this class; Updatables.update() to put at the start of the draw function of the main
public static class Updatables{
 private static ArrayList<Updatable> items = new ArrayList<Updatable>(); 
 
 public static void add(Updatable u){
    items.add(u); 
 }
 
 public static void update(){
    for(Updatable u : items)
       u.update(); 
 }
}


//Parent class
public abstract class Updatable{
  
  Updatable(){
    Updatables.add(this);
  }
  
  public abstract void update();
}
