/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 10/06/2015 
        Last Modified : 10/06/2015
*/

import procontroll.*;
import java.io.*;
import java.util.Map;


/*
*/
public static class Input{
  
  private static /*processing.core.PApplet*/WhereWolf env;
  
  private static ControllIO controll = null;
  
  private static ControllDevice controller;
  private static ControllDevice mouse;
  private static ControllDevice keyboard;
  
  private static HashMap<String,Button> buttons = new HashMap<String,Button>();
  
  private static HashMap<String,Axis> axis  = new HashMap<String,Axis>();
  
  
  public static void start(WhereWolf e){
    env = e;
    controll = ControllIO.getInstance(e);
    ControllDevice temp;
    for(int i = 0; i< controll.getNumberOfDevices() ; i++){
      temp = controll.getDevice(i);
      temp.setTolerance(0.3f);
      if(temp.getNumberOfButtons()>100 && keyboard == null)
        keyboard = temp;
      else if(temp.getNumberOfSliders() > 4 && controller == null)
        controller = temp;
      else if(temp.getNumberOfSticks() == 1 && mouse == null)
        mouse = temp;
    }
    
    if(Constants.DEBUG_MODE){
      println("Devices :");
      println("Keyboard : " + (keyboard != null)); 
      println("Mouse : " + (mouse != null));
      println("Controller : " + (controller != null));      
    }
    
    
  }
  
  public static void update(){
    
  }
   
  public static boolean addButton(String name, String buttonName){
    String[] s = buttonName.split(" ",2);
    ControllButton b;
    if(s[0].compareTo("joystick") == 0)
     b = controller.getButton(s[1]);
    else if(s[0].compareTo("mouse") == 0)
     b = mouse.getButton(s[1]);
    else
     b = keyboard.getButton(buttonName);
    
    if(b != null){
      buttons.put(name,env.new Button(b)); 
      return true;
     }
    else
      println("ERROR : " + buttonName + " isn't a valid button !");
      
    return false;
  }
  
  public static boolean addAxis(String name, String sliderName){
    String[] s = sliderName.split(" ",2);
    ControllSlider b;
    if(s[0].compareTo("joystick") == 0)
     b = controller.getSlider(s[1]);
    else if(s[0].compareTo("mouse") == 0)
     b = mouse.getSlider(s[1]);
    else
     b = keyboard.getSlider(sliderName);
    
    if(b != null){
      axis.put(name,env.new Axis(b)); 
      return true;
     }
    else{
      println("ERROR : " + sliderName + " isn't a valid slider !");
      println(":"+ s[1] +":");
    }
    return false;
  }
  
  public static boolean addAxis(String name, String buttonNegative,String buttonPositive){
    String[] s = buttonNegative.split(" ",2);
    ControllButton b,d;
    if(s[0].compareTo("joystick") == 0)
     b = controller.getButton(s[1]);
    else if(s[0].compareTo("mouse") == 0)
     b = mouse.getButton(s[1]);
    else
     b = keyboard.getButton(buttonNegative);
     
    s = buttonPositive.split(" ",2);
    if(s[0].compareTo("joystick") == 0)
     d = controller.getButton(s[1]);
    else if(s[0].compareTo("mouse") == 0)
     d = mouse.getButton(s[1]);
    else
     d = keyboard.getButton(buttonPositive);
    
    if(b != null && d != null){
      axis.put(name,env.new Axis(b,d)); 
      return true;
     }
    else
      println("ERROR : " + buttonNegative + " or " + buttonPositive + " isn't a valid button !");
      
    return false;
  }
  
  public static boolean getButtonDown(String name){
    return buttons.get(name).getButtonDown();
  }
  
  public static boolean getButtonUp(String name){
    return buttons.get(name).getButtonUp();
  }
  
  public static boolean getButton(String name){
    return buttons.get(name).getButton();
  }
  
  public static float getAxis(String name){
    return axis.get(name).getAxis();
  }
  
  public static float getAxisRaw(String name){
    return axis.get(name).getAxisRaw();
  }
  
}

public class Button extends Updatable{
  private boolean justChanged = false;
  private boolean state = false;
  
  private ControllButton source;
  
  Button(ControllButton cb){
    source = cb;
    justChanged = false;
    state = false;
  }
  
  void start(){
    
  }
  
  void update(){
    justChanged = false;
    if(state != source.pressed()){
       justChanged = true;
       state = ! state;
    }
    
  }
  
  boolean getButtonDown(){
    return (state && justChanged); 
  }
  
  boolean getButtonUp(){
    return (!state && justChanged); 
  }
  
  boolean getButton(){
    return state; 
  }
}

public class Axis{
 ControllSlider slider;
 ControllButton negative;
 ControllButton positive;
 
 boolean useSlider;
 
 Axis(ControllSlider s){
   slider = s;
   useSlider = true;  
 }
 
 Axis(ControllButton neg, ControllButton pos){
  negative = neg;
  positive = pos;
  useSlider = false; 
 }
 
 public float getAxisRaw(){
   float res = 0;
   if(useSlider){
     res += ((abs(slider.getValue())>0.5f)? ((slider.getValue()>0)?1.0f:-1.0f) : 0.0f);
   }
   else{
    res += (negative.pressed()? -1.0f : 0.0f);
    res += (positive.pressed()? 1.0f : 0.0f);
   }
    return res; 
 }
 
 public float getAxis(){
   float res = 0;
   if(useSlider){
     res += slider.getValue();
   }
   else{
    res += (negative.pressed()? -1.0f : 0.0f);
    res += (positive.pressed()? 1.0f : 0.0f);
   }
    return res; 
 }
}
