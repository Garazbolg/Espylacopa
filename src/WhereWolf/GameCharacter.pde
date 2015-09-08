/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/05/2015 
        Last Modified : 22/05/2015
*/


/*
*/
public class GameCharacter extends GameObject{
  
  AnimatorController animator;
  Rigidbody rigid;
 
  private int life;  
  private int armorLife;
  private boolean isAlive = true;
  
  // TODO : use image manager
  private PImage lifeSprite = loadImage("Resources/Sprites/heart.png");
  private PImage armorLifeSprite = loadImage("Resources/Sprites/armorHeart.png");
  
  private PVector colliderHalfDimensions;
  
  protected boolean facingRight = false;
  
  protected SpriteSheet walkAndIdle;
  protected Parameters params;
  protected State walkLeft,walkRight,idleRight,idleLeft;
  
 
  GameCharacter(String name, PVector position){
    super(name,position);
    
    rigid = new Rigidbody();
    addComponent(rigid);
  }
  
 
 public void update(){
    super.update();
    

    
    float xVelocity = (float)rigid.getVelocity().x;
    animator.parameters.setFloat("SpeedX",xVelocity);
    if(xVelocity > 0) facingRight = true;
    else if(xVelocity < 0) facingRight = false;
  }
  
  public int GetLife(){
    return life;
  }
  
  public void IncreaseLife(int n){
    life += n;
  }
  
  public void DecreaseLife(int n){
    life -= n;
    if(life <0){
      life = 0;
      isAlive = false;
    }
  }
      
  public int GetArmorLife(){
    return armorLife;
  }
  
  public void IncreaseArmorLife(int n){
    armorLife += n;
  }
  
  public void DecreaseArmorLife(int n){
    armorLife -= n;
    if(armorLife <0){
      DecreaseLife(n+armorLife);
      armorLife = 0;
    }
  }
  
  public void SetLife(int n){
    life = n;
  }

  public void SetArmorLife(int n){
    armorLife = n;
  }
  
  public boolean isAlive(){
    return isAlive; 
  }
  
  public PVector GetColliderHalfDimensions(){
    return colliderHalfDimensions;
  }
  
  public void drawLife(){
    int life = player.GetLife();
    for(int i=0 ; i<life ; i++){
      image(lifeSprite,10+(lifeSprite.width+10)*i,10);
    }
   
    for(int i=0 ; i<player.GetArmorLife() ; i++){
      image(armorLifeSprite,10+(lifeSprite.width+10)*(i+life),10);
    }
  }
  
  public boolean isFacingRight(){
    return facingRight; 
  }
  
}
