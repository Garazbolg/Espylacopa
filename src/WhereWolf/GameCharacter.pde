/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/05/2015 
        Last Modified : 22/05/2015
*/


/*
*/
public abstract class GameCharacter extends GameObject{
  
  AnimatorController animator;
  Rigidbody rigid;
  Collider characterCollider;
 
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
  
  private boolean invulnerable = false;
  private float blinkDelay = 100;
  private float blinkChrono;
  private float blinkNumber = 0;
  private float maxBlinkNumber = 13;
  private boolean visible = true;
  
 
  protected boolean isRunning = false;
  protected Rect staticColliderRect;
  protected Rect runningColliderRect;
 
 
  GameCharacter(String name, PVector position){
    super(name,position);
    
    rigid = new Rigidbody();
    addComponent(rigid);
  }
  
 
 public void update(){
    super.update();
    
    float xVelocity = (float)rigid.getVelocity().x;
    animator.parameters.setFloat("SpeedX",xVelocity);
    if(xVelocity > 0) {
      if(!isRunning){
        isRunning = true;
        characterCollider.setArea(runningColliderRect); 
      }
      facingRight = true;
    }
    else if(xVelocity < 0) {
      if(!isRunning){
        isRunning = true;
        characterCollider.setArea(runningColliderRect); 
      }
      facingRight = false;
    }
    
    else{
      if(isRunning){
        isRunning = false;
        characterCollider.setArea(staticColliderRect); 
      } 
    }
    
    if(invulnerable){
      if(millis() - blinkChrono > blinkDelay){
        blinkNumber++;
        visible = !visible;
        animator.parameters.setBool("Visible", visible);
        
        if(blinkNumber == maxBlinkNumber){
          invulnerable = false; 
        }
        
        blinkChrono = millis();
        
      }
    }
  }
  
  public int GetLife(){
    return life;
  }
  
  public void IncreaseLife(int n){
    life += n;
  }
  
  public void DecreaseLife(int n){
    if(invulnerable) return;
    
    if(armorLife > 0){
      DecreaseArmorLife(n); 
    }
    
    else{
      life -= n;
      
      if(life <=0){
        life = 0;
        Die();
      }
      
      else{
        activateBlinkOfInvulnerability(); 
      }
    }
  }
      
  public int GetArmorLife(){
    return armorLife;
  }
  
  public void IncreaseArmorLife(int n){
    armorLife += n;
  }
  
  public void DecreaseArmorLife(int n){
    if(invulnerable) return;
    armorLife -= n;
    if(armorLife <0){
      DecreaseLife(n+armorLife);
      armorLife = 0;
    }
    
    else{
      activateBlinkOfInvulnerability(); 
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
  
  public void activateBlinkOfInvulnerability(){
    invulnerable = true;
    blinkChrono = millis();
    blinkNumber = 0;
    
    visible = false;
    animator.parameters.setBool("Visible", visible);
  }
  
  public void Die(){
    isAlive = false;
    // TODO : feedback death + stop character control
  }
  
  public void UpdateCollider(){
    if(rigid.getVelocity().x != 0){
      characterCollider.setArea(runningColliderRect); 
    }
    
    else{
      characterCollider.setArea(staticColliderRect); 
    }
  }
  
}
