/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/04/2015 
        Last Modified : 23/04/2015
*/





/*
  Static class for managing Image loading
*/
public static class ImageManager{
 
 //Reference to the app (because static class)
 private static processing.core.PApplet env;
  
 //Collection containing the paths to the loaded Images
 private static ArrayList<String> keys = new ArrayList<String>();
 //Collection containing the loaded Images
 private static ArrayList<PImage> values = new ArrayList<PImage>();
 
 
 //To put at the begining of the start function in main : ImageManager.start(this);
 public static void start(processing.core.PApplet e){
  env = e; 
 }

 //return the Image at 'path' and load it if it wasn't
 public static PImage getImage(String path){
   for(int i = 0; i < keys.size(); i++){
     if(keys.get(i).equals(path))
       return values.get(i);
   }
   
   PImage im = env.loadImage(path);
   keys.add(path);
   values.add(im);
   
   return im;
 }
}

