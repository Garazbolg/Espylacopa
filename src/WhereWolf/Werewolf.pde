
public class Werewolf extends GameCharacter {

  private boolean isTransformed = false;
  private boolean canTransform = false;

  private float powerBar = 0;
  private float maxPowerBar = 1000;

  private float powerBarChrono;

  private float powerBarIncreaseSpeed = 100;
  private float powerBarIncreaseDelay = 10;

  private float powerBarDecreaseSpeed = 10;
  private float powerBarDecreaseDelay = 10;

  /*
  private float transformationChrono;
   private float transformationDelay = 3000;
   */

  private float vulnerabilityChrono;
  private float vulnerabilityDelay = 10000;

  private Sprite moonSprite;
  private Sprite moonMaskSprite;

  private float moonMaskMaxOffset = 100;


  protected Rect humanStaticColliderRect;
  protected Rect humanRunningColliderRect;
  
  protected Rect wherewolfStaticColliderRect;
  protected Rect wherewolfRunningColliderRect;

  private GameObject leftHumanAttack;
  private Collider leftHumanAttackCollider;
  
  private GameObject rightHumanAttack;
  private Collider rightHumanAttackCollider;
  
  private GameObject leftWerewolfAttack;
  private Collider leftWerewolfAttackCollider;
  
  private GameObject rightWerewolfAttack;
  private Collider rightWerewolfAttackCollider;
  
  
  private int humanAttackDamage = 1;
  private int werewolfAttackDamage = 2;
  


  Werewolf() {


    super();

    SetLife(3);

    walkAndIdle = new SpriteSheet(characterSpriteSheetPath + "VillageoisSpriteSheet.png", 8, 4);

    humanStaticColliderRect = staticColliderRect;
    humanRunningColliderRect = runningColliderRect;
    
    
    wherewolfStaticColliderRect = new Rect(-1, 2, 20, 44);
    wherewolfRunningColliderRect = new Rect(-1, 2, 30, 44);
        
    params = new Parameters();
    params.setFloat("SpeedX", 0.0f);

    walkRight = new State(new Animation(walkAndIdle, 0, true), 9);
    walkLeft =  new State(new Animation(walkAndIdle, 1, true), 9);
    idleRight = new State(new Animation(walkAndIdle, 2, true), 1);
    idleLeft =  new State(new Animation(walkAndIdle, 3, true), 1);

    Transition t = new Transition(idleRight, walkRight, "SpeedX", ConditionType.GreaterThan, 0.1f);
    t = new Transition(idleLeft, walkRight, "SpeedX", ConditionType.GreaterThan, 0.1f);
    t = new Transition(idleRight, walkLeft, "SpeedX", ConditionType.LesserThan, -0.1f);
    t = new Transition(idleLeft, walkLeft, "SpeedX", ConditionType.LesserThan, -0.1f);
    t = new Transition(walkRight, idleRight, "SpeedX", ConditionType.LesserThan, 0.1f);
    t = new Transition(walkLeft, idleLeft, "SpeedX", ConditionType.GreaterThan, -0.1f);
    animator = new AnimatorController(idleLeft, params);
    animator.parameters.setBool("Visible", true);
    animator.parameters.setBool("Alive", true);

    powerBarChrono = millis();

    moonSprite = new Sprite(spritesPath + "fullMoon.png");
    moonMaskSprite = new Sprite(spritesPath + "fullMoonMask.png"); 

    // DEBUG - TO DO : Delete forceDebugDraw
    //((Collider)rightHumanAttack.getComponent(Collider.class)).forceDebugDraw = true;
    //((Collider)leftHumanAttack.getComponent(Collider.class)).forceDebugDraw = true;
    //((Collider)rightWerewolfAttack.getComponent(Collider.class)).forceDebugDraw = true;
    //((Collider)leftWerewolfAttack.getComponent(Collider.class)).forceDebugDraw = true;
    
    
  }

  public void update() {

    if(isAlive){
      super.update();
  

      
      if (Input.getButtonDown("Fire")) {
        attack();
      }
  
      if (isTransformed) {
  
  
  
        if (millis() - powerBarChrono > powerBarDecreaseDelay) {
          powerBar -= powerBarDecreaseSpeed;
          if (powerBar <= 0) {
            powerBar = 0;
            transformToHuman();
          }
        }
      } else {
  
        if (!canTransform) {
          if (millis() - powerBarChrono > powerBarIncreaseDelay) {
            powerBar += powerBarIncreaseSpeed;
            if (powerBar >= maxPowerBar) {
              powerBar = maxPowerBar;
              canTransform = true;
            }
          }
        } else {
          if (Input.getButtonDown("Special")) {
            transformToWerewolf();
          }
        }
      }
    }
    
    else if(!staticGrave) super.update();
  }


  public void transformToWerewolf() {

    isTransformed = true;
    powerBarChrono = millis();

    changeCharacterSpriteSheet(characterSpriteSheetPath + "WerewolfSpriteSheet.png", 8, 4);

    ((Collider)gameObject.getComponent(Collider.class)).setArea(new Rect(0, 0, walkAndIdle.getSpriteWidth(), walkAndIdle.getSpriteHeight()));
    gameObject.position.add(new PVector(0, -7)); 

    SetArmorLife(2);
    AdaptCollidersWithTransformation();
  }

  public void transformToHuman() {

    isTransformed = false;
    canTransform = false;
    powerBarChrono = millis();

    changeCharacterSpriteSheet(characterSpriteSheetPath + "VillageoisLGSpriteSheet.png", 8, 4);

    ((Collider)gameObject.getComponent(Collider.class)).setArea(new Rect(0, 0, walkAndIdle.getSpriteWidth(), walkAndIdle.getSpriteHeight()));
    gameObject.position.add(new PVector(0, 7));

    SetArmorLife(0);
    AdaptCollidersWithTransformation();
  }

  public void attack() {
    
    if(isTransformed){
      if(facingRight){
        DamageAllInCollider(rightWerewolfAttackCollider, werewolfAttackDamage);       
      } else{
        DamageAllInCollider(leftWerewolfAttackCollider, werewolfAttackDamage);    
      }
    }
    
    else{
      if(facingRight){
        DamageAllInCollider(rightHumanAttackCollider, humanAttackDamage);       
      } else{
        DamageAllInCollider(leftHumanAttackCollider, humanAttackDamage);    
      }
    }
  }
  
  private void DamageAllInCollider(Collider collider, int damage){
    ArrayList<Collider> allColliders = collider.getCurrentTriggers();
        
    for(int i=0 ; i<allColliders.size() ; i++){
      if(allColliders.get(i).gameObject.getClass().getSuperclass() == GameCharacter.class){
        if(allColliders.get(i).gameObject != gameObject){
          ((GameCharacter)(allColliders.get(i).gameObject.getComponent(GameCharacter.class))).DecreaseLife(damage, gameObject.position);
        }
      }
    }
  } 


  public void changeCharacterSpriteSheet(String spriteSheetName, int widthS, int heightS) {
    walkAndIdle = new SpriteSheet(spriteSheetName, widthS, heightS); // TODO : changer parameters to match with finalized sprite sheet

    walkRight.animation.source = walkAndIdle;
    walkLeft.animation.source = walkAndIdle;
    idleRight.animation.source = walkAndIdle;
    idleLeft.animation.source = walkAndIdle;
  }

  public void drawLife() {
    super.drawLife();
    pushMatrix();
    translate(100, 110);
    moonSprite.draw();
    translate(scaleValue(0, maxPowerBar, 0, moonMaskMaxOffset, powerBar), 0);
    moonMaskSprite.draw();
    popMatrix();
  }

  public float scaleValue(float OldMin, float OldMax, float NewMin, float NewMax, float OldValue) {

    float OldRange = (OldMax - OldMin);
    float NewRange = (NewMax - NewMin);
    float NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;

    return(NewValue);
  }
  
  public void AdaptCollidersWithTransformation(){
    if(isTransformed){
      staticColliderRect = wherewolfStaticColliderRect;
      runningColliderRect = wherewolfRunningColliderRect;
    }
    
    else{
      staticColliderRect = humanStaticColliderRect;
      runningColliderRect = humanRunningColliderRect;
    }
    
    UpdateCollider();
  }
  

  public void setLeftHumanAttack(GameObject newLeftHumanAttack){
    leftHumanAttack = newLeftHumanAttack;
  }
    
  public void setLeftHumanAttackCollider(Collider newLeftHumanAttackCollider){
    leftHumanAttackCollider = newLeftHumanAttackCollider;
  }
    
  public void setRightHumanAttack(GameObject newRightHumanAttack){
    rightHumanAttack = newRightHumanAttack;
  }
    
  public void setRightHumanAttackCollider(Collider newRightHumanAttackCollider){
    rightHumanAttackCollider = newRightHumanAttackCollider;
  }
    
  public void setLeftWerewolfAttack(GameObject newLeftWerewolfAttack){
    leftWerewolfAttack = newLeftWerewolfAttack;
  }
    
  public void setLeftWerewolfAttackCollider(Collider newLeftWerewolfAttackCollider){
    leftWerewolfAttackCollider = newLeftWerewolfAttackCollider;
  }

  public void setRightWerewolfAttack(GameObject newRightWerewolfAttack){
    rightWerewolfAttack = newRightWerewolfAttack;
  }
    
  public void setRightWerewolfAttackCollider(Collider newRightWerewolfAttackCollider){
    rightWerewolfAttackCollider = newRightWerewolfAttackCollider;
  }
  

  
}
