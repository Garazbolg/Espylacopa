
public class Werewolf extends GameCharacter {
  
  private boolean isTransformed = false;
  private boolean canTransform = false;
  
  private float powerBar = 0;
  private float maxPowerBar = 1000;
  
  private float powerBarChrono;
  
  private float powerBarIncreaseSpeed = 1;
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
  
 
  
  
  Werewolf(String name, PVector position){
    
    super(name, position);
    
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
    
    powerBarChrono = millis();
    
    moonSprite = new Sprite(spritesPath + "fullMoon.png");
    moonMaskSprite = new Sprite(spritesPath + "fullMoonMask.png");
    
  }
  
  public void update(){
    
    super.update();
    
    rigid.setVelocity(new PVector(Input.getAxisRaw("Horizontal")*70.0f, rigid.getVelocity().y));
    
    if(isTransformed){
      
      if(Input.getButtonDown("Fire")){
        attack();
      }
      
      if(millis() - powerBarChrono > powerBarDecreaseDelay){
        powerBar -= powerBarDecreaseSpeed;
        if(powerBar <= 0){
          powerBar = 0;
          transformToHuman();
        }
      }

    }
    
    else{
      
      if(!canTransform){
        if(millis() - powerBarChrono > powerBarIncreaseDelay){
          powerBar += powerBarIncreaseSpeed;
          if(powerBar >= maxPowerBar){
            powerBar = maxPowerBar;
            canTransform = true;
          }
        }
      }
      
      else{
        if(Input.getButtonDown("Fire")){
          transformToWerewolf();
        }
      }
    }
    
  }
  
  
  public void transformToWerewolf(){
   
    isTransformed = true;
    powerBarChrono = millis();
    
    changeCharacterSpriteSheet(characterSpriteSheetPath + "WerewolfSpriteSheet.png", 8, 4);
    
    ((Collider)this.getComponent(Collider.class)).setArea(new Rect(0,0,walkAndIdle.getSpriteWidth(),walkAndIdle.getSpriteHeight()));
    this.position.add(new PVector(0,-7));  
  }
  
  public void transformToHuman(){
    
    isTransformed = false;
    canTransform = false;
    powerBarChrono = millis();
    
    changeCharacterSpriteSheet(characterSpriteSheetPath + "VillageoisLGSpriteSheet.png", 8, 4);
    
    ((Collider)this.getComponent(Collider.class)).setArea(new Rect(0,0,walkAndIdle.getSpriteWidth(),walkAndIdle.getSpriteHeight()));
    this.position.add(new PVector(0,7));
    

    
    
    
  }
  
  public void attack(){
    //TODO
  }
  
  
  public void changeCharacterSpriteSheet(String spriteSheetName, int widthS, int heightS){
    walkAndIdle = new SpriteSheet(spriteSheetName,widthS,heightS); // TODO : changer parameters to match with finalized sprite sheet
    
    walkRight.animation.source = walkAndIdle;
    walkLeft.animation.source = walkAndIdle;
    idleRight.animation.source = walkAndIdle;
    idleLeft.animation.source = walkAndIdle;
  }
  
  public void drawLife(){
    super.drawLife();
    pushMatrix();
    translate(100,110);
    moonSprite.draw();
    translate(scaleValue(0,maxPowerBar, 0, moonMaskMaxOffset, powerBar), 0);
    moonMaskSprite.draw();
    popMatrix();
 
  }
 
  public float scaleValue(float OldMin, float OldMax, float NewMin, float NewMax, float OldValue){
 
    float OldRange = (OldMax - OldMin);
    float NewRange = (NewMax - NewMin);
    float NewValue = (((OldValue - OldMin) * NewRange) / OldRange) + NewMin;
 
    return(NewValue);
  }
  
 
  
}
