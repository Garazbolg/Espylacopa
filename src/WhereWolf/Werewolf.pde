
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
  
  private GameObject transformationEffect;
  private AnimatorController transformationEffectAnimatorController;
  

  


  Werewolf() {

    super();

    SetLife(30);

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
    
  }

  
  public void init(){
    super.init();
    
    this.addRPC("transformToWerewolf", new DelegateTransformToWerewolf(this));
    this.addRPC("transformToHuman", new DelegateTransformToHuman(this));
    
    leftHumanAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), gameObject);
    leftHumanAttack.addComponent(new Collider(new Rect(3, 0, 15, 20)));
    leftHumanAttackCollider = (Collider)leftHumanAttack.getComponent(Collider.class);
    leftHumanAttackCollider.isTrigger = true;
    
    GameObject rightHumanAttack = new GameObject("RigtHumanAttack", new PVector(-10,2), gameObject);
    rightHumanAttack.addComponent(new Collider(new Rect(15, 0, 15, 20)));
    rightHumanAttackCollider = (Collider)rightHumanAttack.getComponent(Collider.class);
    rightHumanAttackCollider.isTrigger = true;
    
    leftWerewolfAttack = new GameObject("LeftWerewolfAttack", new PVector(-10,2), gameObject);
    leftWerewolfAttack.addComponent(new Collider(new Rect(0, 5, 22, 30)));
    leftWerewolfAttackCollider = (Collider)leftWerewolfAttack.getComponent(Collider.class);
    leftWerewolfAttackCollider.isTrigger = true;
        
     rightWerewolfAttack = new GameObject("RigtWerewolfAttack", new PVector(-10,2), gameObject);
    rightWerewolfAttack.addComponent(new Collider(new Rect(22, 5, 22, 30)));
    rightWerewolfAttackCollider = (Collider)rightWerewolfAttack.getComponent(Collider.class);
    rightWerewolfAttackCollider.isTrigger = true;
   
    
    transformationEffect = new GameObject("transformationEffect", new PVector(), gameObject);
    
    Parameters transformationEffectParams = new Parameters();
    transformationEffectParams.setBool("Start", true);
    transformationEffectParams.setBool("Visible", false);
    
    State effectAnimation =  new State(new Animation(transformationEffectSpriteSheet,0,false),15);
    effectAnimation.setScale(1.5f);
    
    transformationEffectAnimatorController = new AnimatorController(effectAnimation,transformationEffectParams);
    transformationEffect.addComponent(transformationEffectAnimatorController);
         
  }
  
  
  public void update() {

    super.update();
      
    if(isAlive){
  

      if(!playerInitialized || !myCharacter) return;
      
      if (Input.getButtonDown(fireInput)) {
        attack();
      }
  
      if (isTransformed) {
  
  
  
        if (millis() - powerBarChrono > powerBarDecreaseDelay) {
          powerBar -= powerBarDecreaseSpeed;
          if (powerBar <= 0) {
            powerBar = 0;
            transformToHuman();
            Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + playerId + " transformToHuman#");    
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
          if (Input.getButtonDown(specialInput)) {
            transformToWerewolf();
            Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + playerId + " transformToWerewolf#");    
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
    
    if(myCharacter){
      AddArmorLife(2);
    }
    
    AdaptCollidersWithTransformation();
    
    transformationEffectAnimatorController.parameters.setBool("Visible", true);
    transformationEffectAnimatorController.getCurrentState().startState();
  }

  public void transformToHuman() {

    isTransformed = false;
    canTransform = false;
    powerBarChrono = millis();

    changeCharacterSpriteSheet(characterSpriteSheetPath + "VillageoisLGSpriteSheet.png", 8, 4);

    ((Collider)gameObject.getComponent(Collider.class)).setArea(new Rect(0, 0, walkAndIdle.getSpriteWidth(), walkAndIdle.getSpriteHeight()));
    gameObject.position.add(new PVector(0, 7));

    if(armorLife > 1) DecreaseArmorLife(2);
    else if(armorLife == 1) DecreaseArmorLife(1);
    
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
      
      if(!allColliders.get(i).isTrigger){
        GameCharacter character = (GameCharacter)(allColliders.get(i).gameObject.getComponentIncludingSubclasses(GameCharacter.class));
        if(character != null && character.isAlive && character.gameObject != this.gameObject){
          //((GameCharacter)(allColliders.get(i).gameObject.getComponent(GameCharacter.class))).DecreaseLife((int)(damage*damageMultiplicator), gameObject.position);
          Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + ((NetworkView)(character.gameObject.getComponent(NetworkView.class))).getId() + " decreaseLife " + (int)(damage*damageMultiplicator) + " " + gameObject.position.x + " " + gameObject.position.y +"#");    
        }
      }
    }
  } 


  public void changeCharacterSpriteSheet(String spriteSheetName, int widthS, int heightS) {
    walkAndIdle = new SpriteSheet(spriteSheetName, widthS, heightS);

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
  

  
}
