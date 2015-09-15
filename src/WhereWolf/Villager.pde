
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
  
  
  Villager(String name, PVector position){
    
    super(name, position);
    
    SetLife(3);
    
    //fireShotSprite = new Sprite(characterSpriteSheetPath + "VillageoisSpriteSheet.png");
    walkAndIdle = new SpriteSheet(characterSpriteSheetPath + "VillageoisSpriteSheet.png",8,4);
    
    addComponent(new Collider(new Rect(0,0,walkAndIdle.getSpriteWidth(),walkAndIdle.getSpriteHeight())));
    characterCollider = (Collider)this.getComponent(Collider.class);
    
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
    addComponent(animator);
    
    leftShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), this);
    leftShotAttack.addComponent(new Collider(new Rect(-29, 0, 82, 10)));
    leftShotAttackCollider = (Collider)leftShotAttack.getComponent(Collider.class);
    leftShotAttackCollider.isTrigger = true;
    
    rightShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), this);
    rightShotAttack.addComponent(new Collider(new Rect(53, 0, 88, 10)));
    rightShotAttackCollider = (Collider)rightShotAttack.getComponent(Collider.class);
    rightShotAttackCollider.isTrigger = true;
    
    
  }
  
  public void update(){
    
    super.update();
    
    if(showWeapon && fireShotFacingRight != facingRight){
       fireShotFacingRight = facingRight;
       Sprite fire = (Sprite)barrelGun.getComponent(Sprite.class);
       fire.flip();
       if(fireShotFacingRight) barrelGun.position = new PVector(10,2);
       else barrelGun.position = new PVector(-10,2);
    }
    
    if(isFiring){
      rigid.setVelocity(new PVector(0,rigid.getVelocity().y));
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
   
  
  }
  
  
  public void fire(){
    if(!showWeapon) ShowWeapon();
    // Waiting for raycast implementation
    isFiring = true;
    animator.getCurrentState().startState(); // To have a fixed height for the weapon
    barrelGun.setActive(true);
    fireShotChrono = millis();
    
    if(facingRight) DamageClosestCollider(rightShotAttackCollider, 1, true);
    else DamageClosestCollider(leftShotAttackCollider, 1, false);
    
  }
  
  private void DamageClosestCollider(Collider collider, int damage, boolean rightDirection){
    ArrayList<Collider> allColliders = collider.getCurrentTriggers();
    int  closestColliderIndex = -1;
    float closestPositionX = (float)Double.POSITIVE_INFINITY;
   
    for(int i=0 ; i<allColliders.size() ; i++){
      if(allColliders.get(i).gameObject.getClass().getSuperclass() == GameCharacter.class){
        if(allColliders.get(i).gameObject != this && ((GameCharacter)(allColliders.get(i).gameObject)).isAlive()){
          if(abs(allColliders.get(i).gameObject.position.x - collider.gameObject.position.x) < closestPositionX){
             closestColliderIndex = i;
             closestPositionX = abs(allColliders.get(i).gameObject.position.x - collider.gameObject.position.x);
          }
        }
      }
    }
    
    if(closestColliderIndex > -1){
      ((GameCharacter)(allColliders.get(closestColliderIndex).gameObject)).DecreaseLife(damage, this.position); 
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
    barrelGun = new GameObject("BarrelGun", new PVector(-10,2), this);
    barrelGun.addComponent(fireShotSprite);
    
    barrelGun.setActive(false);
  }
  
}
