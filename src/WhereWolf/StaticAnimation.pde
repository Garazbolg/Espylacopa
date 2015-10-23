/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 22/05/2015 
        Last Modified : 22/05/2015
*/


public class StaticAnimation extends Renderer{
  
  Animation animation;
  int frame = 0;
  float currentFrame = 0;
  float framePerSecond;
 
  StaticAnimation(Animation anim, float speed){
    animation = anim;
    frame = 0;
    framePerSecond = speed;
  }
  
  public void draw(){
    pushMatrix();
     frame = ((int)(currentFrame*framePerSecond));
     PImage source = animation.getImage(frame);
     image(source,-source.width/2,-source.height/2); 
     popMatrix();
     currentFrame += Time.deltaTime();
  }
  
}
