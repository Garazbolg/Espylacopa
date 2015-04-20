
public static class Time{
  private static int lastTime = 0;
  private static float delta;
  
  public static void update(int millis){
      delta = (millis  - lastTime)/1000.0;
      lastTime = millis;
  }
  
  public static float deltaTime(){
    return delta;
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
