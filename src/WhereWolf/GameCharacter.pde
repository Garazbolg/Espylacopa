/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 23/05/2015 
        Last Modified : 22/05/2015
*/


/*
*/
public class GameCharacter extends GameObject{
  
  AnimatorController animator;
  Rigidbody rigid;
 
  private int life;  
  private int armorLife;
  private boolean isAlive = true;
  
  private PImage lifeSprite = loadImage("Resources/Sprites/heart.png");
  private PImage armorLifeSprite = loadImage("Resources/Sprites/armorHeart.png");
  
  private PVector colliderHalfDimensions;
  
  private boolean facingRight = false;
 
  GameCharacter(String name,String type,PVector position){
    super(name,position);
    
    rigid = new Rigidbody();
    addComponent(rigid);
    
    SpriteSheet walkAndIdle = new SpriteSheet(type + "SpriteSheet.png",8,4);
    addComponent(new Collider(new Rect(0,0,walkAndIdle.getSpriteWidth(),walkAndIdle.getSpriteHeight())));
    
    Parameters params = new Parameters();
    params.setFloat("SpeedX",0.0f);
    State walkLeft,walkRight,idleRight,idleLeft;
    walkRight = new State(new Animation(walkAndIdle,0,true),6);
    walkLeft =  new State(new Animation(walkAndIdle,1,true),6);
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
    float xVelocity = (float)rigid.getVelocity().x;
    animator.parameters.setFloat("SpeedX",xVelocity);
    if(xVelocity > 0) facingRight = true;
    else if(xVelocity < 0) facingRight = false;
  }
  
  public int GetLife(){
    return life;
  }
  
  public void IncreaseLife(int n){
    life += n;
  }
  
  public void DecreaseLife(int n){
    life -= n;
    if(life <0){
      life = 0;
      isAlive = false;
    }
  }
      
  public int GetArmorLife(){
    return armorLife;
  }
  
  public void IncreaseArmorLife(int n){
    armorLife += n;
  }
  
  public void DecreaseArmorLife(int n){
    armorLife -= n;
    if(armorLife <0){
      DecreaseLife(n+armorLife);
      armorLife = 0;
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
  
}
