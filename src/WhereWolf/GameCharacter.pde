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
   
   animator.parameters.setFloat("SpeedX",(float)rigid.getVelocity().x);
  }
 
  
}
