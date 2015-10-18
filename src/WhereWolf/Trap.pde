
public class Trap extends Component {

  private AnimatorController animatorController;
  
  private float creationTime;
  private float delayBeforePossibleActivation = 500;
  private int damage = 1;
  
  private boolean activate = false;
  private boolean damageApplied = false;
  
  private float activationChrono;
  private float damageDelay = 200;
  
  private GameObject blockLocation;
  private boolean display = true;
  
  private boolean applyDamage = false;
  
  Trap(){
    
    super();
    
    creationTime = millis();
    
    blockLocation = map.getCurrentBlock();
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
    
    
    gameObject.addComponent(new NetworkView());
    this.addRPC("activateTrap", new DelegateActivateTrap(this));
    this.addRPC("destroy", new DelegateDestroy(this));
    
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
       
    if(display){
      if(!blockLocation.isActive()){
        display = false;
        animatorController.parameters.setBool("Visible", false);
      }
    } else{
      if(blockLocation.isActive()){
        display = true;
        animatorController.parameters.setBool("Visible", true);
      }
    }
    
     if(activate && !damageApplied){
       if(millis() - activationChrono > damageDelay){
         damageApplied = true;
         if(applyDamage){
           damageAllCharactersInEffectZone();
         }
       }
     }
  }
  
  /*
  public void onTriggerEnter(Collider other){
    if(millis() - creationTime > delayBeforePossibleActivation){
      if(other.gameObject.getComponent(Trap.class) == null){
      activate = true;
      animatorController.parameters.setBool("Close",true);
      activationChrono = millis();
      }
    }
  }
  */
  
  public boolean canBeActivated(){
    return(millis() - creationTime > delayBeforePossibleActivation);
  }
  
  public void activate(boolean haveToApplyDamage){
    applyDamage = haveToApplyDamage;
    activate = true;
    animatorController.parameters.setBool("Close",true);
    activationChrono = millis();
  }
  
  public void setAnimatorController(AnimatorController newAnimatorController){
    animatorController = newAnimatorController; 
  }
  
  public void damageAllCharactersInEffectZone(){
    ArrayList<Collider> allColliders = ((Collider)(gameObject.getComponent(Collider.class))).getCurrentTriggers();
    
    for(int i=0 ; i<allColliders.size() ; i++){
      if(allColliders.get(i).isTrigger) continue;
      GameCharacter character = (GameCharacter)allColliders.get(i).gameObject.getComponentIncludingSubclasses(GameCharacter.class);
      if(character != null && character.isAlive){
        character.DecreaseLife(damage, gameObject.position);
        Network.write("RPC " + RPCMode.Others + " " + ipAdress + " " + ((NetworkView)(character.gameObject.getComponent(NetworkView.class))).getId() + " decreaseLife " + damage + " " + gameObject.position.x + " " + gameObject.position.y +"#");    
      }
    }
    
    trapsContainer.addChildren(gameObject);
  }
  
  public boolean getDamageApplied(){
    return damageApplied; 
  }
  
  public void OnDestroy(){
    animatorController.OnDestroy();
    super.OnDestroy();
  }
}
