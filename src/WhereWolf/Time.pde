
public static class Time{
  private static int lastTime = 0;
  private static float delta;
  private static float deltaWScale;
  private static float timeScale = 1.0f;
  
  public static void update(int millis){
      delta = ((millis  - lastTime)/1000.0);
      deltaWScale = delta*timeScale;
      lastTime = millis;
  }
  
  public static float deltaTime(){
    return deltaWScale;
  }
  
  public static int getFPS(){
    return int( 1/delta); 
  }
  
  public static void setTimeScale(float f){
    timeScale = ((f<0)?-f:f);
  }
  
}

private class TimeUpdater extends Updatable{

  
  public void start(){
    Time.update(millis());
  }
  
  public void update(){
    Time.update(millis());
  }
  
}

private TimeUpdater myPrivateTimeUpdater = new TimeUpdater();
