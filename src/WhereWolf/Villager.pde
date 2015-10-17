
public class Villager extends GameCharacter {
  
  private boolean showWeapon = false;
  private GameObject barrelGun;
  
  private Sprite fireShotSprite;
  
  private boolean isFiring = false;
  private float fireShotChrono;
  private float fireShotDelay = 100;
  private float stopXmovementDelay = 200;
  
  private boolean fireShotFacingRight = false;
  
  private GameObject leftShotAttack;
  private Collider leftShotAttackCollider;
  
  private GameObject rightShotAttack;
  private Collider rightShotAttackCollider;

  
  private float placingTrapChrono;
  private float placingTrapDelay = 1000;
  private boolean placingTrap = false;
  
  private int maxTrapsNumber = 3;
  private int availableTraps;
  
  
  
  Villager(){
    
    super();
    
    SetLife(30);
    
    walkAndIdle = new SpriteSheet(characterSpriteSheetPath + "VillageoisSpriteSheet.png",8,4);
    
    params = new Parameters();
    params.setFloat("SpeedX",0.0f);
    
    walkRight = new State(new Animation(walkAndIdle,0,true),9);
    walkLeft =  new State(new Animation(walkAndIdle,1,true),9);
    idleRight = new State(new Animation(walkAndIdle,2,true),1);
    idleLeft =  new State(new Animation(walkAndIdle,3,true),1);
    
    Transition t = new Transition(idleRight,walkRight,"SpeedX",ConditionType.GreaterThan,0.1f);
    t = new Transition(idleLeft,walkRight,"SpeedX",ConditionType.GreaterThan,0.1f);
    t = new Transition(idleRight,walkLeft,"SpeedX",ConditionType.LesserThan,-0.1f);
    t = new Transition(idleLeft,walkLeft,"SpeedX",ConditionType.LesserThan,-0.1f);
    t = new Transition(walkRight,idleRight,"SpeedX",ConditionType.LesserThan,0.1f);
    t = new Transition(walkLeft,idleLeft,"SpeedX",ConditionType.GreaterThan,-0.1f);
    animator = new AnimatorController(idleLeft,params);
    animator.parameters.setBool("Visible", true);
    
    
    activateBlinkOfInvulnerability(takeDamageCooldown); 
    availableTraps = maxTrapsNumber; 
    
  }
  
  
  public void init(){
    super.init();
    
    leftShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), gameObject);
    leftShotAttack.addComponent(new Collider(new Rect(-29, 0, 82, 10)));
    Collider leftShotAttackCollider = (Collider)leftShotAttack.getComponent(Collider.class);
    leftShotAttackCollider.isTrigger = true;
    
    
    rightShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), gameObject);
    rightShotAttack.addComponent(new Collider(new Rect(53, 0, 88, 10)));
    Collider rightShotAttackCollider = (Collider)rightShotAttack.getComponent(Collider.class);
    rightShotAttackCollider.isTrigger = true;  
 
  }
  
  public void update(){
    if(!playerInitialized) return;
    if(isAlive){
      
      if(!placingTrap){
      
      
        super.update();
        //println("update");
        if(showWeapon && fireShotFacingRight != facingRight){
           fireShotFacingRight = facingRight;
           Sprite fire = (Sprite)barrelGun.getComponent(Sprite.class);
           fire.flip();
           if(fireShotFacingRight) barrelGun.position = new PVector(10,2);
           else barrelGun.position = new PVector(-10,2);
        }
        
        if(isFiring){
          rigid.setVelocity(new PVector(0,rigid.getVelocity().y));
          animator.parameters.setFloat("SpeedX",0);
        }
        
        if(Input.getButtonDown("Fire")){
          fire();
          PVector rigidVelocity = rigid.getVelocity();
          rigidVelocity.x = 0;
          rigid.setVelocity(new PVector(0,rigidVelocity.y));
        }
        
       
        if(isFiring){
         
          if(millis() - fireShotChrono - stopXmovementDelay > fireShotDelay){
            isFiring = false;
          }
         
          else{
            if(millis() - fireShotChrono > fireShotDelay){
              barrelGun.setActive(false);
            }
          }
        }
      
        else{
          
          if (rigid.grounded){
            if(Input.getButtonDown("Special") && availableTraps > 0) {
              availableTraps--;
              placingTrap = true;
              placingTrapChrono = millis();
              rigid.setVelocity(new PVector(0,0));
              animator.parameters.setFloat("SpeedX",0);
            }
            
            // TODO : if animation for pickup trap, add delay  after pickup to avoid multiple traps pickup at once
            if(availableTraps < maxTrapsNumber && Input.getAxisRaw("Vertical") < 0){
              ArrayList<Collider> allTriggers = characterCollider.getCurrentTriggers();
              boolean pickupTrap = false;
              int iterator = 0;
              while(!pickupTrap && iterator <  allTriggers.size()){
                Trap trapComponent = (Trap)(allTriggers.get(iterator).gameObject.getComponent(Trap.class));
                if(trapComponent != null && trapComponent.getDamageApplied()){
                  pickupTrap = true;
                  availableTraps++;
                  trapComponent.gameObject.destroy();
                }
                
                iterator++;
              }
            } 
          } 
        }
      }
     
      else{
        if(millis() - placingTrapChrono > placingTrapDelay){
          placeTrap();
          placingTrap = false;
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
  }
  
  
  public void fire(){
    if(!showWeapon) ShowWeapon();
    // Waiting for raycast implementation
    isFiring = true;
    animator.getCurrentState().startState(); // To have a fixed height for the weapon
    barrelGun.setActive(true);
    fireShotChrono = millis();
    println("Fire - " + rightShotAttackCollider + " " + leftShotAttackCollider);
    if(facingRight) DamageClosestCollider(rightShotAttackCollider, 1, true);
    else DamageClosestCollider(leftShotAttackCollider, 1, false);
    
  }
  
  private void DamageClosestCollider(Collider collider, int damage, boolean rightDirection){
    ArrayList<Collider> allColliders = collider.getCurrentTriggers();
    int  closestColliderIndex = -1;
    float closestPositionX = (float)Double.POSITIVE_INFINITY;
   println("size + " + allColliders.size());
    for(int i=0 ; i<allColliders.size() ; i++){
      println(allColliders.get(i).gameObject.getComponent(GameCharacter.class));
      if(allColliders.get(i).gameObject.getClass().getSuperclass() == GameCharacter.class){
        if(allColliders.get(i).gameObject != this.gameObject && ((GameCharacter)(allColliders.get(i).gameObject.getComponent(GameCharacter.class))).isAlive()){
          if(abs(allColliders.get(i).gameObject.position.x - collider.gameObject.position.x) < closestPositionX){
             closestColliderIndex = i;
             closestPositionX = abs(allColliders.get(i).gameObject.position.x - collider.gameObject.position.x);
          }
        }
      }
    }
    
    if(closestColliderIndex > -1){
      println("check");
      ((GameCharacter)(allColliders.get(closestColliderIndex).gameObject.getComponent(GameCharacter.class))).DecreaseLife((int)(damage*damageMultiplicator), gameObject.position); 
    }
  } 
  
  public void ShowWeapon(){
    showWeapon = true;
    walkAndIdle = new SpriteSheet(characterSpriteSheetPath + "ChasseurSpriteSheet.png",8,4);
    
    walkRight.animation.source = walkAndIdle;
    walkLeft.animation.source = walkAndIdle;
    idleRight.animation.source = walkAndIdle;
    idleLeft.animation.source = walkAndIdle;
    
    fireShotSprite = new Sprite(spritesPath + "fireShot.png");
    //fireShotSprite = new Sprite(characterSpriteSheetPath + "VillageoisSpriteSheet.png");
     
    //GameObject thisGameObject = (GameObject) this;
    barrelGun = new GameObject("BarrelGun", new PVector(-10,2), gameObject);
    barrelGun.addComponent(fireShotSprite);
    
    barrelGun.setActive(false);
    
  }


  public void placeTrap(){
    new TrapPrefab(gameObject.position);
  }
  
  /*
  public void onTriggerEnter(Collider other){
    if(availableTrapsNumber < maxTrapsNumber){
      Trap trapComponent = (Trap)other.getComponent(Trap.class);
      if(trapComponent != null){
         
      }
    }
  }
  */
  
}
