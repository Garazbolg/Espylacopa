
public class Villager extends GameCharacter {
  
  private boolean showWeapon = false;
  private GameObject barrelGun;
  
  private Sprite fireShotSprite;
  
  private boolean isFiring = false;
  private float fireShotChrono;
  private float fireShotDelay = 100;
  private float stopXmovementDelay = 200;
  
  private boolean fireShotFacingRight = false;
  
  Villager(String name, PVector position){
    
    super(name, position);
    //fireShotSprite = new Sprite(characterSpriteSheetPath + "VillageoisSpriteSheet.png");
    walkAndIdle = new SpriteSheet(characterSpriteSheetPath + "VillageoisSpriteSheet.png",8,4);
    
    addComponent(new Collider(new Rect(0,0,walkAndIdle.getSpriteWidth(),walkAndIdle.getSpriteHeight())));
    
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
    addComponent(animator);
    
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
    
    if(!isFiring){
      rigid.setVelocity(new PVector(Input.getAxisRaw("Horizontal")*70.0f,((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().y));
    }
    
    else{
      rigid.setVelocity(new PVector(0,((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().y));
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
    println("Fire");
  }
  
  public void ShowWeapon(){
    showWeapon = true;
    walkAndIdle = new SpriteSheet(characterSpriteSheetPath + "ChasseurSpriteSheet.png",8,4);
    
    walkRight.animation.source = walkAndIdle;
    walkLeft.animation.source = walkAndIdle;
    idleRight.animation.source = walkAndIdle;
    idleLeft.animation.source = walkAndIdle;
    
    fireShotSprite = new Sprite(spritesPath + "fireShot.png");
    println("check check check");
    //fireShotSprite = new Sprite(characterSpriteSheetPath + "VillageoisSpriteSheet.png");
     
    //GameObject thisGameObject = (GameObject) this;
    barrelGun = new GameObject("BarrelGun", new PVector(-10,2), this);
    barrelGun.addComponent(fireShotSprite);
    
    barrelGun.setActive(false);
;  }
  
}
