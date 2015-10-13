/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 20/04/2015 
        Last Modified : 22/04/2015
*/


/*
  Static class for managing time
*/
public static class Time{
  
  // run time at last Update
  private static int lastTime = 0;
  // time since last Update
  private static float delta;
  // time since last Update with scale applied
  private static float deltaWScale;
  //time scale
  private static float timeScale = 1.0f;
  
  //update
  public static void update(int millis){
      delta = ((millis  - lastTime)/1000.0);
      lastTime = millis;
      deltaWScale = delta*timeScale;
  }
  
  //return time since last frame with scale applied
  public static float deltaTime(){
    return deltaWScale;
  }
  
  public static float unscaledDeltaTime(){
    return delta;
  }
  
  //get the current Frame per second
  public static int getFPS(){
    return int( 1/delta); 
  }
  
  public static int getTime(){
    return lastTime; 
  }
  
  //set the speed of time in the game compared to speed in real world (1 => same)
  public static void setTimeScale(float f){
    timeScale = ((f<0)?-f:f);
  }
  
}


/*
    Private class to update the static Time manager
*/
private class TimeUpdater extends Updatable{

  //start
  public void start(){
    Time.update(millis());
  }
  
  //update
  public void update(){
    Time.update(millis());
  }
  
}

private TimeUpdater myPrivateTimeUpdater = new TimeUpdater();
