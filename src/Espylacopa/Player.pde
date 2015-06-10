
// TODO : extends Component, use motor + subclasses for each type of characters !!!

//public class Player extends Component(){
public class Player{  

  private int life = 2;
  private int armorLife = 3;
  private PImage lifeSprite = loadImage("Resources/Sprites/heart.png");
  private PImage armorLifeSprite = loadImage("Resources/Sprites/armorHeart.png");
  private float speed = 5;
  
  private void update(){
    

    
    checkInputs();
    
  }
  
  private void checkInputs(){
    
    if(keyPressed){
      if(key == CODED){
        if(keyCode == RIGHT){
          player.position.x += speed;
        }
        
        else if(keyCode == LEFT){
          player.position.x -= speed;
        }
        
        else if(keyCode == UP){
          player.position.y -= speed;  
        }
        
        else if(keyCode == DOWN){
          player.position.y += speed;
        }
      }
      
    }
  }
  
  public void drawUI(){
    for(int i=0 ; i<life ; i++){
      image(lifeSprite,10+(lifeSprite.width+10)*i,10);
    }
   
   for(int i=0 ; i<armorLife ; i++){
      image(armorLifeSprite,10+(lifeSprite.width+10)*(i+life),10);
   }
  }
  
}
