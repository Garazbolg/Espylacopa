/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 26/04/2015 
        Last Modified : 26/04/2015
*/


public static class GUI{
  
  private static processing.core.PApplet env;
  
  public static void start(processing.core.PApplet e){
    env = e;
    env.textFont(env.createFont("Misc/rainyhearts.ttf",48));
  }  
  
  public static void label(PVector position, String content){
    env.text(content,position.x,position.y);
  }
  
  public static void labelCenter(PVector position, String content){
   env.text(content,position.x - env.textWidth(content)/2 , position.y - env.textAscent()/2); 
  }
}
