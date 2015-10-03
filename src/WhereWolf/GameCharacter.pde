/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/05/2015 
        Last Modified : 22/05/2015
*/


/*
*/
public abstract class GameCharacter extends Component{
  
  AnimatorController animator;
  Rigidbody rigid;
  Collider characterCollider;
 
  private int life;  
  private int armorLife;
  protected boolean isAlive = true;
  
  // TODO : use image manager
  private PImage lifeSprite = ImageManager.getImage("data/Sprites/heart.png");
  private PImage armorLifeSprite = ImageManager.getImage("data/Sprites/armorHeart.png");
  
  private PVector colliderHalfDimensions;
  
  protected boolean facingRight = false;
  
  protected SpriteSheet walkAndIdle;  
  protected SpriteSheet deadSpriteSheet;
  
  protected Parameters params;
  protected State walkLeft,walkRight,idleRight,idleLeft, dead;
  
  protected boolean invulnerable = false;
  protected float blinkDelay = 100;
  protected float blinkChrono;
  protected float blinkNumber = 0;
  protected float maxBlinkNumber = 13;
  protected boolean visible = true;
  
 
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
  

   GameCharacter(){
            

    
    deadSpriteSheet = new SpriteSheet(characterSpriteSheetPath + "grave.png", 1, 1);
    dead = new State(new Animation(deadSpriteSheet, 0, false), 1);

    staticColliderRect = new Rect(0, 4, 6, 24);
    runningColliderRect = new Rect(0, 4, 10, 24);
    
  }
  
 
  public void update(){
    super.update();
    //if(Input.getAxisRaw("Horizontal") != 0) println(gameObject.position.y + ((Rect)(characterCollider.area)).halfDimension.y + characterCollider.area.position.y - 2);
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
  
      if(gameObject.name == "One") // TODO : remove this it's for debug
      {
        if(Input.getButtonDown("Jump")) {

          if(Input.getAxisRaw("Vertical") > 0){            
            for(int i=0 ; i<characterCollider.currentCollisions.size() ; i++){
              if(characterCollider.currentCollisions.get(i).passablePlatform){
                characterCollider.getOverlookColliders().add(characterCollider.currentCollisions.get(i));
              }
            } 

          }
          
          else{
            rigid.setVelocity(new PVector(rigid.getVelocity().x,-150.0f));
          }
        }
        
        else if(Input.getAxisRaw("Vertical") < 0 && rigid.getVelocity().x == 0){   
          for(int i=0 ; i<characterCollider.currentCollisions.size() ; i++){
            Chest chestComponent = (Chest)(characterCollider.currentCollisions.get(i).gameObject.getComponent(Chest.class));
            if(chestComponent != null){
              chestComponent.openChest(this); 
            }
          }
        }
        
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
    for(int i=0 ; i<life ; i++){
      image(lifeSprite,10+(lifeSprite.width+10)*i,10);
    }
   
    for(int i=0 ; i<armorLife ; i++){
      image(armorLifeSprite,10+(lifeSprite.width+10)*(i+life),10);
    }
  }
  
  public boolean isFacingRight(){
    return facingRight; 
  }
  
  public void makeMoveCausedByDamage(PVector aggressorPosition){
    PVector direction = PVector.sub(gameObject.position, aggressorPosition);
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
    animator.setCurrentState(dead);
    characterCollider.setArea(new Rect(0, 0, deadSpriteSheet.getSpriteWidth(), deadSpriteSheet.getSpriteHeight()));
    characterCollider.layer = CollisionLayer.Environment;
    rigid.setVelocity(new PVector(0, rigid.getVelocity().y));
    
    //characterCollider.isTrigger = true;
    //characterCollider.forceDebugDraw = true;
    
    
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
  
  public void setRigid(Rigidbody newRigid){
    rigid = newRigid; 
  }
  
  public void onCollisionEnter(Collider other){
    CheckIfPassThroughtPlatform(other);
  }
   
  public void onCollisionStay(Collider other){
    CheckIfPassThroughtPlatform(other);
  }
   
  public void CheckIfPassThroughtPlatform(Collider other){
    // TODO : too much checks in this if condition, not really optimized but more safe, check rigid.velocity inizialited is essential for sure
    if(rigid == null || rigid.velocity == null || characterCollider == null || other == null || gameObject == null) return; // if condition to avoid error at launch when initialization is not finish
    if(other.passablePlatform && !characterCollider.getOverlookColliders().contains(other)){
      
      float errorMargin = 0.5f;
      errorMargin +=  rigid.velocity.y/100;
      float playerBottomY = gameObject.position.y + ((Rect)(characterCollider.area)).halfDimension.y + characterCollider.area.position.y - errorMargin;
      float platformTopY = other.gameObject.position.y - ((Rect)(other.area)).halfDimension.y + other.area.position.y; 
      if(other.gameObject.isChildTile) platformTopY += other.gameObject.parent.position.y;
     
      if(playerBottomY > platformTopY)  characterCollider.getOverlookColliders().add(other);
    }
  }
  
  public void onCollisionExit(Collider other){
    if(characterCollider.getOverlookColliders().contains(other)){
      characterCollider.getOverlookColliders().remove(other);
    }
  }
  
  public SpriteSheet getWalkAndIdle(){
    return walkAndIdle;
  }
    
  public void setCharacterCollider(Collider newCharacterCollider){
    characterCollider = newCharacterCollider;
  }
  
  public AnimatorController getAnimator(){
    return(animator);
  }
    
  
  
}
