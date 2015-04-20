
public static class Time{
  private static int lastTime = 0;
  private static float delta;
  private static float timeScale = 1.0f;
  
  public static void update(int millis){
      delta = ((millis  - lastTime)/1000.0)*timeScale;
      lastTime = millis;
  }
  
  public static float deltaTime(){
    return delta;
  }
  
  public static float setTimeScale(float f){
    timeScale = (f<0)-f:f;
  }
  
}

private class TimeUpdater extends Updatable{

  TimeUpdater(){
    super();
    start(); 
  }
  
  public void start(){
    Time.update(millis());
  }
  
  public void update(){
    Time.update(millis());
  }
  
}

private TimeUpdater myPrivateTimeUpdater = new TimeUpdater();
