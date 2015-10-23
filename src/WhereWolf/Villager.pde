
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
    
    SetLife(3);
    
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
    
    
    availableTraps = maxTrapsNumber; 
    
  }
  
  
  public void init(){
    super.init();
    
    this.addRPC("fire", new DelegateFire(this));
    this.addRPC("flipFireSprite", new DelegateFlipFireSprite(this));
    
    leftShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), gameObject);
    leftShotAttack.addComponent(new Collider(new Rect(-29, 0, 82, 10)));
    leftShotAttackCollider = (Collider)leftShotAttack.getComponent(Collider.class);
    leftShotAttackCollider.isTrigger = true;
    leftShotAttackCollider.forceDebugDraw = true;
    
    
    rightShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), gameObject);
    rightShotAttack.addComponent(new Collider(new Rect(53, 0, 88, 10)));
    rightShotAttackCollider = (Collider)rightShotAttack.getComponent(Collider.class);
    rightShotAttackCollider.isTrigger = true;  
 
  }
  
  public void update(){
    
    //if(Network.isServer && gameObject.name == "clientPlayer")
    super.update();
    
    if(isAlive){
      if(isFiring){
       
        if(millis() - fireShotChrono - stopXmovementDelay > fireShotDelay){
          isFiring = false;
        }
       
        else{
          if(millis() - fireShotChrono > fireShotDelay){
            barrelGun.setActive(false);
            //canMove = false;
          }
        }
      }
    
      if(!playerInitialized || !myCharacter) return;
      
      if(!placingTrap){
      
        if(showWeapon && fireShotFacingRight != facingRight){
          fireShotFacingRight = facingRight;
          flipFireSprite(fireShotFacingRight);
          Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + ((NetworkView)(gameObject.getComponent(NetworkView.class))).getId() + " flipFireSprite " + fireShotFacingRight +"#");    
        }
        
        if(isFiring){
          rigid.setVelocity(new PVector(0,rigid.getVelocity().y));
          animator.parameters.setFloat("SpeedX",0);
        }
        
        if(Input.getButtonDown(fireInput)){
          fire();
          Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + ((NetworkView)(gameObject.getComponent(NetworkView.class))).getId() + " fire#");    
          PVector rigidVelocity = rigid.getVelocity();
          rigidVelocity.x = 0;
          rigid.setVelocity(new PVector(0,rigidVelocity.y));
          
          immobileDelay = 300;
          immobileChrono = millis();
          
          xVelocity = 0;
          setXvelocity(xVelocity);
          Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + playerId + " setXvelocity " + xVelocity +"#");   
        }
        

      
        if(canMove){
          
          if (rigid.grounded){
            if(Input.getButtonDown(specialInput) && availableTraps > 0) {
              availableTraps--;
              placingTrap = true;
              placingTrapChrono = immobileChrono = millis();
              immobileDelay = placingTrapDelay;
              rigid.setVelocity(new PVector(0,0));
              canMove = false;
              
              xVelocity = 0;
              setXvelocity(xVelocity);
              Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + playerId + " setXvelocity " + xVelocity +"#");   
            }
            
            if(availableTraps < maxTrapsNumber && Input.getAxisRaw(verticalInput) < 0){
              ArrayList<Collider> allTriggers = characterCollider.getCurrentTriggers();
              boolean pickupTrap = false;
              int iterator = 0;
              while(!pickupTrap && iterator <  allTriggers.size()){
                Trap trapComponent = (Trap)(allTriggers.get(iterator).gameObject.getComponent(Trap.class));
                if(trapComponent != null && trapComponent.getDamageApplied()){
                  pickupTrap = true;
                  availableTraps++;
                  Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + ((NetworkView)(trapComponent.gameObject.getComponent(NetworkView.class))).getId() + " destroy#"); 
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
       

      }
    }
    
   
  }
  
  
  public void fire(){
    
    
    if(!showWeapon) showWeapon();
    // Waiting for raycast implementation
    isFiring = true;
    canMove = false;
    animator.getCurrentState().startState(); // To have a fixed height for the weapon
    barrelGun.setActive(true);
    fireShotChrono = millis();
    
    if(myCharacter){
      if(facingRight) DamageClosestCollider(rightShotAttackCollider, 1, true);
      else DamageClosestCollider(leftShotAttackCollider, 1, false);
    }
    
  }

  private void DamageClosestCollider(Collider collider, int damage, boolean rightDirection){
    ArrayList<Collider> allColliders = collider.getCurrentTriggers();
    int  closestColliderIndex = -1;
    float closestPositionX = (float)Double.POSITIVE_INFINITY;
    GameObject gameObjectIterator = null;
    GameCharacter character = null;
    
    for(int i=0 ; i<allColliders.size() ; i++){

      gameObjectIterator = allColliders.get(i).gameObject;
      
      if(!allColliders.get(i).isTrigger && gameObjectIterator!= null && gameObjectIterator != this.gameObject){
        character = (GameCharacter)(allColliders.get(i).gameObject.getComponentIncludingSubclasses(GameCharacter.class));
        if(character != null || !allColliders.get(i).passablePlatform){
          if(abs(gameObjectIterator.position.x - collider.gameObject.position.x) < closestPositionX){
              closestColliderIndex = i;
              closestPositionX = abs(gameObjectIterator.position.x - collider.gameObject.position.x);
           }
        }
      }
    }
    
    if(closestColliderIndex > -1){
      character = (GameCharacter)(allColliders.get(closestColliderIndex).gameObject.getComponentIncludingSubclasses(GameCharacter.class));
      if(character!= null && character != this && character.isAlive() && !character.isInvulnerable()){
        Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + ((NetworkView)(allColliders.get(closestColliderIndex).gameObject.getComponent(NetworkView.class))).getId() + " decreaseLife " + (int)(damage*damageMultiplicator) + " " + gameObject.position.x + " " + gameObject.position.y +"#");    
      }
    }
  } 
  
  public void showWeapon(){
    
    
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
    
    if(Network.isServer) {
      Network.Instantiate(globalEnv, "WhereWolf$TrapPrefab", gameObject.position, null);      
    }
    
    else Network.Instantiate(globalEnv, "WhereWolf$TrapPrefab", gameObject.position, null);
  }
  
  public void flipFireSprite(boolean barrelIsFacingRight){
    Sprite fireSprite = (Sprite)barrelGun.getComponent(Sprite.class);
    fireSprite.flip();
    if(barrelIsFacingRight) barrelGun.position = new PVector(10,2);
    else barrelGun.position = new PVector(-10,2);
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
