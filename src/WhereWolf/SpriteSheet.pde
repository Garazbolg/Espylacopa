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
  float oneSpriteWidth;
  float oneSpriteHeight;
  
  SpriteSheet(String path, int widthS, int heightS){
    source = ImageManager.getImage(path);
    widthSize = widthS;
    heightSize = heightS;
    oneSpriteWidth = source.width / widthS;
    oneSpriteHeight = source.height / heightS;
  }
  
  public PImage getImage(int x, int y){
   return source.get((x%widthSize)*oneSpriteWidth,(y%heightSize)*oneSpriteHeight);
  } 
}
