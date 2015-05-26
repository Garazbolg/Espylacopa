/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/04/2015 
        Last Modified : 23/04/2015
*/


/*
  
*/
public class SpriteSheet{
  
  
  PImage source;
  int widthSize;
  int heightSize;
  int oneSpriteWidth;
  int oneSpriteHeight;
  
  SpriteSheet(String path, int widthS, int heightS){
    source = ImageManager.getImage(path);
    widthSize = widthS;
    heightSize = heightS;
    oneSpriteWidth = source.width / widthS;
    oneSpriteHeight = source.height / heightS;
  }
  
  public PImage getImage(int x, int y){
   return source.get(((int)((x%widthSize)*oneSpriteWidth)),((int)((y%heightSize)*oneSpriteHeight)),oneSpriteWidth,oneSpriteHeight);
  }
  
  public int getWidth(){
   return widthSize; 
  }
  
  public int getSpriteWidth(){
    return oneSpriteWidth;
  }
  
  public int getSpriteHeight(){
    return oneSpriteHeight;
  }
}
