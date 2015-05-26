/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 21/05/2015 
        Last Modified : 22/05/2015
*/


/*
*/
public class AnimatorController extends Renderer{
  
  public Parameters parameters;
  private State currentState;
  
  AnimatorController(State st, Parameters params){
    currentState = st;
    parameters = params;
  }
  
  public void start(){
   currentState.startState(); 
  }
  
  public void draw(){
    currentState.draw();
  }

  public void update(){
   State next = currentState.update(parameters);
   if(next != null)
     currentState = next;
     next.startState();
  }
}



/*
*/
public class Transition{
  public State from,to;
  
  private String  conditionParameterName;
  
  private boolean conditionParameterValueBool;
  private int     conditionParameterValueInt;
  private float   conditionParameterValueFloat;
  
  private ConditionType condition;
  
  private int conditionDataType = 0;
  
  Transition(State f,State t){
    //Exit Time transition
    if(f !=null && t != null){
      from = f;
      to = t;
      from.to.add(this);
    }
    else
      println("Error : Transition Init Failed !!!");
  }
  
  Transition(State f,State t,String parameterName, ConditionType ct, boolean value){
      conditionParameterName = parameterName;
      conditionParameterValueBool = value;
      condition = ct;
      conditionDataType = 1;
  }
  
  Transition(State f,State t,String parameterName, ConditionType ct, int value){
      conditionParameterName = parameterName;
      conditionParameterValueInt = value;
      condition = ct;
      conditionDataType = 2;
  }
  
  Transition(State f,State t,String parameterName, ConditionType ct, float value){
      conditionParameterName = parameterName;
      conditionParameterValueFloat = value;
      
      condition = ct;
      conditionDataType = 3;
  }
  
  public boolean evaluate(Parameters params){
   if(conditionDataType == 1){
     switch(condition){
       case Equal :
         return params.getBool(conditionParameterName) == conditionParameterValueBool;
       default :
         return params.getBool(conditionParameterName) != conditionParameterValueBool;
     }
   }
   
   if(conditionDataType == 2){
     switch(condition){
       case Equal :
         return params.getInt(conditionParameterName) == conditionParameterValueInt;
         
       case GreaterThan :
         return params.getInt(conditionParameterName) > conditionParameterValueInt;
         
       case LesserThan :
         return params.getInt(conditionParameterName) < conditionParameterValueInt;
         
       case GreaterEqual :
         return params.getInt(conditionParameterName) >= conditionParameterValueInt;
         
       case LesserEqual :
         return params.getInt(conditionParameterName) <= conditionParameterValueInt;
         
       default :
         return params.getInt(conditionParameterName) != conditionParameterValueInt;
     }
   }
   
   if(conditionDataType == 3){
     switch(condition){
       case Equal :
         return params.getFloat(conditionParameterName) == conditionParameterValueFloat;
         
       case GreaterThan :
         return params.getFloat(conditionParameterName) > conditionParameterValueFloat;
         
       case LesserThan :
         return params.getFloat(conditionParameterName) < conditionParameterValueFloat;
         
       case GreaterEqual :
         return params.getFloat(conditionParameterName) >= conditionParameterValueFloat;
         
       case LesserEqual :
         return params.getFloat(conditionParameterName) <= conditionParameterValueFloat;
         
       default :
         return params.getFloat(conditionParameterName) != conditionParameterValueFloat;
     }
   }
   
   return from.getExitTime();
   
  } 
  
}




/*
*/
public class State{
  private Animation animation;
  private float framePerSecond;
  private float currentFrame;
  
  private ArrayList<Transition> to;
  
  State(Animation anim,float speed){
    framePerSecond = speed;
    animation = anim;
    currentFrame = 0;
    to = new ArrayList<Transition>();
  }
  
 private void startState(){
   currentFrame = 0; 
  }
 
 public boolean getExitTime(){
   return !animation.getLoop() && currentFrame > animation.getSize();
 }
 
 public void draw(){
   
     PImage source = animation.getImage(((int)(currentFrame*framePerSecond)));
     image(source,-source.width/2,-source.height/2); 
     currentFrame += Time.deltaTime();
     if(currentFrame > animation.getSize() && animation.getLoop())
       currentFrame -= animation.getSize();
 }
 
 public State update(Parameters params){
   for(int i = 0; i< to.size() ; i ++){
     if(to.get(i).evaluate(params)){
       return to.get(i).to;
     }
   }
   
   return null;
 }
}



/*
*/
public class Parameters{
  private HashMap<String,Boolean> parametersBool;
  private HashMap<String,Integer> parametersInt;
  private HashMap<String,Float> parametersFloat;
  
  Parameters(){
    parametersBool = new HashMap<String,Boolean>();
    parametersInt = new HashMap<String,Integer>();
    parametersFloat = new HashMap<String,Float>();
  }
  
  public boolean setBool(String k, boolean value){
    return parametersBool.put(k,value);
  }
  
  public int setInt(String k, int value){
    return parametersInt.put(k,value);
  }
  
  public float setFloat(String k, float value){
    return parametersFloat.put(k,value);
  }
  
  public boolean getBool(String k){
    return parametersBool.get(k);
  }
  
  public int getInt(String k){
    return parametersInt.get(k);
  }
  
  public float getFloat(String k){
    return parametersFloat.get(k);
  }
}


