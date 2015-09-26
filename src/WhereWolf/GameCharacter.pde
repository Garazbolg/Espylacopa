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
  protected boolean isAlive = true;
  
  // TODO : use image manager
  private PImage lifeSprite = loadImage("Resources/Sprites/heart.png");
  private PImage armorLifeSprite = loadImage("Resources/Sprites/armorHeart.png");
  
  private PVector colliderHalfDimensions;
  
  protected boolean facingRight = false;
  
  protected SpriteSheet walkAndIdle;  
  protected SpriteSheet deadSpriteSheet;
  
  protected Parameters params;
  protected State walkLeft,walkRight,idleRight,idleLeft, dead;
  
  private boolean invulnerable = false;
  private float blinkDelay = 100;
  private float blinkChrono;
  private float blinkNumber = 0;
  private float maxBlinkNumber = 13;
  private boolean visible = true;
  
 
  protected boolean isRunning = false;
  protected Rect staticColliderRect;
  protected Rect runningColliderRect;
  
  private float damageMovementFactor = 150;
  private float damageMovementDecreaseSpeed = 2;
  
  private float xMovementCausedByDamage = 0;  
  private float minXmovementCausedByDamage = 0;  
  private float minYmovementCausedByDamage = 0;
  private float maxYmovementCausedByDamage = 0.5f;
  
  protected boolean staticGrave = false;
  
 
 
  GameCharacter(String name, PVector position){
    super(name,position);
    
    rigid = new Rigidbody();
    addComponent(rigid);
    
    deadSpriteSheet = new SpriteSheet(characterSpriteSheetPath + "grave.png", 1, 1);
    dead = new State(new Animation(deadSpriteSheet, 0, false), 1);

    staticColliderRect = new Rect(0, 4, 6, 24);
    runningColliderRect = new Rect(0, 4, 10, 24);
    
  }
  
 
  public void update(){
    super.update();
      
    if(isAlive){

      rigid.setVelocity(new PVector(Input.getAxisRaw("Horizontal")*70.0f, rigid.getVelocity().y));
      
      rigid.setVelocity(new PVector(rigid.getVelocity().x + xMovementCausedByDamage, rigid.getVelocity().y));
      
      if(xMovementCausedByDamage < 0){
        xMovementCausedByDamage += damageMovementDecreaseSpeed;
        if(xMovementCausedByDamage > 0) xMovementCausedByDamage = 0;
      }
      
      else if(xMovementCausedByDamage > 0){
        xMovementCausedByDamage -= damageMovementDecreaseSpeed;
        if(xMovementCausedByDamage < 0) xMovementCausedByDamage = 0;
      }
      
      // TODO : Prevent air jump
  
      if(name == "One") // TODO : remove this it's for debug
      {
        if(Input.getButtonDown("Jump")) rigid.setVelocity(new PVector(rigid.getVelocity().x,-150.0f));
      }

      //float xVelocity = (float)rigid.getVelocity().x;
      float xVelocity = Input.getAxisRaw("Horizontal")*70.0f;
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
    
    // TODO : use matrix collider to avoid floating grave (if grave fall on a mooving character for example)
    else if(!staticGrave) {
      if(rigid.grounded){
        staticGrave = true;
        rigid.isKinematic = true;
        characterCollider.isTrigger = true;
        
      } 
    }
  }
  
  public int GetLife(){
    return life;
  }
  
  public void IncreaseLife(int n){
    life += n;
  }
  
  public void DecreaseLife(int n, PVector aggressorPosition){
    if(invulnerable) return;
    
    if(armorLife > 0){
      DecreaseArmorLife(n, aggressorPosition); 
    }
    
    else{
      life -= n;
      
      if(life <=0){
        life = 0;
        Die();
      }
      
      else{
        activateBlinkOfInvulnerability(); 
        makeMoveCausedByDamage(aggressorPosition);
      }
    }
  }
      
  public int GetArmorLife(){
    return armorLife;
  }
  
  public void IncreaseArmorLife(int n){
    armorLife += n;
  }
  
  public void DecreaseArmorLife(int n, PVector aggressorPosition){
    if(invulnerable) return;
    armorLife -= n;
    if(armorLife <0){
      DecreaseLife(n+armorLife, aggressorPosition);
      armorLife = 0;
    }
    
    else{
      activateBlinkOfInvulnerability(); 
      makeMoveCausedByDamage(aggressorPosition);
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
  
  public void makeMoveCausedByDamage(PVector aggressorPosition){
    PVector direction = PVector.sub(this.position, aggressorPosition);
    direction.normalize();
    
    if(direction.y < -0.5f){
      if(direction.x < 0) direction.x += (direction.y + 0.5f);
      else if(direction.x > 0) direction.x -= (direction.y + 0.5f);
      direction.y = -0.5f; 
    }
    
    else if(direction.y > 0.5f) {
      
      if(direction.x < 0) direction.x -= (direction.y - 0.5f);
      else if(direction.x > 0) direction.x += (direction.y - 0.5f);
      direction.y = 0.5f; 
    }
    
    println(direction);
    //rigid.setVelocity(PVector.mult(aggressorPosition,damageMovementFactor));
    xMovementCausedByDamage = direction.x * damageMovementFactor;
    //rigid.setVelocity(new PVector(-150,-150));
    rigid.setVelocity(new PVector(rigid.getVelocity().x, direction.y * damageMovementFactor - 100));
    //rigid.setVelocity(new PVector(rigid.getVelocity().x,-100.0f));
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
    println(animator);
    animator.setCurrentState(dead);
    println();
    characterCollider.setArea(new Rect(0, 0, deadSpriteSheet.getSpriteWidth(), deadSpriteSheet.getSpriteHeight()));
    characterCollider.layer = CollisionLayer.Environment;
    
    //characterCollider.isTrigger = true;
    
    characterCollider.forceDebugDraw = true;
    staticGrave = false;
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
