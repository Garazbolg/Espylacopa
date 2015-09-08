/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/04/2015 
        Last Modified : 23/04/2015
*/


/*
  Renderer Component to display simple image
*/
public class Sprite extends Renderer{
 
 float scaleX,scaleY; 
 
 PImage source;
 
 Sprite(String path){
   source = ImageManager.getImage(path);
   scaleX = 1.0f;
   scaleY = 1.0f;
 }
 
 Sprite(String path,float scale){
   source = ImageManager.getImage(path);
   scaleX = scale;
   scaleY = scale;
 }
 
 Sprite(String path,float sx,float sy){
   source = ImageManager.getImage(path);
   scaleX = sx;
   scaleY = sy;
 }
 
 Sprite(SpriteSheet ssh, int x, int y){
  source = ssh.getImage(x,y);
  scaleX = 1.0f;
  scaleY = 1.0f;
 }
 
 Sprite(PImage sour){
  source = sour;
  scaleX = 1.0f; 
  scaleY = 1.0f;
 }
 
 Sprite(PImage sour, float scale){
  source = sour;
  scaleX = scale;
  scaleY = scale;
 }
 
 Sprite(PImage sour,float sx,float sy){
   source = sour;
   scaleX = sx;
   scaleY = sy;
 }
 
 public float getHeight(){
   return source.height*scaleY; 
 }
 
 public float getWidth(){
   return source.width*scaleX; 
 }
 
 public void flip(){
   scaleX = -scaleX;
 }
 
 public void draw(){
   pushMatrix();
   scale(scaleX,scaleY);
   image(source,-source.width/2,-source.height/2); 
   popMatrix();
 }
  
}
