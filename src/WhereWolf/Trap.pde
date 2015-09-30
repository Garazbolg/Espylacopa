
public class Trap extends Component {

  private AnimatorController animatorController;
  
  private float creationTime;
  private float delayBeforePossibleActivation = 500;
  private int damage = 1;
  
  private boolean activate = false;
  private boolean damageApplied = false;
  
  private float activationChrono;
  private float damageDelay = 200;
  
  Trap(){
    
    super();
    
    creationTime = millis();
    /*
    gameObject = go;
    Parameters trapParams = new Parameters();
    trapParams.setBool("Close", false);
    
    State trapIdle = new State(new Animation(trapSpriteSheet,0,false),0);
    State trapClose =  new State(new Animation(trapSpriteSheet,0,false),9);
    
    Transition t = new Transition(trapIdle,trapClose,"Close",ConditionType.Equal,true);
    
    animatorController = new AnimatorController(trapIdle,trapParams);
    gameObject.addComponent(animatorController);
    
    gameObject.addComponent(new Collider(new Rect(0,0,15,15)));
    ((Collider)gameObject.getComponent(Collider.class)).isTrigger = true;
    */
  }

  public void init(){
    
    Parameters trapParams = new Parameters();
    trapParams.setBool("Close", false);
    
    State trapIdle = new State(new Animation(trapSpriteSheet,0,false),0);
    State trapClose =  new State(new Animation(trapSpriteSheet,0,false),9);
    
    Transition t = new Transition(trapIdle,trapClose,"Close",ConditionType.Equal,true);
    
    animatorController = new AnimatorController(trapIdle,trapParams);
    gameObject.addComponent(animatorController);
    
    gameObject.addComponent(new Collider(new Rect(0,0,15,15)));
    ((Collider)gameObject.getComponent(Collider.class)).isTrigger = true;
    ((Collider)gameObject.getComponent(Collider.class)).layer = CollisionLayer.CharacterBody;
    ((Collider)gameObject.getComponent(Collider.class)).layerManagement = LayerManagement.OnlyMyLayer;
       
  }
   
  public void update(){
     if(activate && !damageApplied){
       if(millis() - activationChrono > damageDelay){
         damageApplied = true;
         damageAllCharactersInEffectZone();
       }
     }
  }
     
  public void onTriggerEnter(Collider other){
    if(!activate){
      if(millis() - creationTime > delayBeforePossibleActivation){
        if(other.gameObject.getComponent(Trap.class) == null){
        activate = true;
        animatorController.parameters.setBool("Close",true);
        activationChrono = millis();
        }
      }
    }
  }
   
  public void setAnimatorController(AnimatorController newAnimatorController){
    animatorController = newAnimatorController; 
  }
  
  public void damageAllCharactersInEffectZone(){
    ArrayList<Collider> allColliders = ((Collider)(gameObject.getComponent(Collider.class))).getCurrentTriggers();
     
    
    for(int i=0 ; i<allColliders.size() ; i++){
      GameCharacter gameCharacter = (GameCharacter)allColliders.get(i).gameObject.getComponentIncludingSubclasses(GameCharacter.class);
      if(gameCharacter != null) gameCharacter.DecreaseLife(damage, gameObject.position);
    }
    
    trapsContainer.addChildren(gameObject);
    

  }
}