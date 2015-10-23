/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 26/04/2015 
        Last Modified : 26/04/2015
*/

public class Animation{
 private int index;
 protected SpriteSheet source;
 private boolean loop = false; // Animation has to be 2^n frames long (max 16 frames) for it to be smooth
 
 Animation(SpriteSheet spriteSheet, int line, boolean doesLoop){
  source = spriteSheet;
  index = line;
  loop = doesLoop;
 } 
 
 Animation(SpriteSheet spriteSheet, int line){
  this(spriteSheet,line,false); 
 }
 
 PImage getImage(int frame){
   return source.getImage(frame,index);
 }
 
 boolean getLoop(){
  return loop; 
 }
 
 int getSize(){
  return source.getWidth(); 
 }
 
}
