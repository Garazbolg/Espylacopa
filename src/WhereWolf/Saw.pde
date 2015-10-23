
public class Saw extends Component {

  
  private GameObject currentSawTrail;
  private GameObject nextSawTrail;

  private boolean initialized = false;
  private float speed = 2;
  private float waitDurationBeforeReturn = 1000;
  
  private PVector distanceBetweenTwoSails;
  
    
  private AnimatorController animatorController;  
  private GameObject blockLocation;
  private boolean display = true;
  
  private int networkId;
  
  Saw(GameObject sawTrailGameObject){
    currentSawTrail = sawTrailGameObject;
  }
  
  public void init(){
    
    gameObject.addComponent(new DamageCollider(new Circle(0, 0, 12), 1));
    ((DamageCollider)gameObject.getComponent(DamageCollider.class)).layer = CollisionLayer.CharacterBody;
    ((DamageCollider)gameObject.getComponent(DamageCollider.class)).layerManagement = LayerManagement.OnlyMyLayer;
    
    
    nextSawTrail = ((SawTrail)currentSawTrail.getComponent(SawTrail.class)).getNextSawTrail();
    if(nextSawTrail ==  null) nextSawTrail = ((SawTrail)currentSawTrail.getComponent(SawTrail.class)).getPreviousSawTrail();
    
    if(nextSawTrail != null) {
      initialized = true;
      distanceBetweenTwoSails = PVector.sub(nextSawTrail.position, currentSawTrail.position);
    }
    
    animatorController = (AnimatorController)gameObject.getComponent(AnimatorController.class);
    
  }
  
  public void update(){
    if(initialized){
      
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
      
     if(!sawsManagedByNetwork ||Network.isServer){ 
       PVector movement = new PVector(distanceBetweenTwoSails.x, distanceBetweenTwoSails.y); 
        
       movement.mult(speed*Time.deltaTime());
        
       gameObject.position = PVector.add(gameObject.position, movement);
        
       if(PVector.dist(currentSawTrail.position, gameObject.position) > PVector.dist(currentSawTrail.position, nextSawTrail.position)){
          gameObject.position = nextSawTrail.position;
          defineNextSail();
       }
       
       if(Network.isServer){
         Network.write("SetPosition " + networkId + " " + gameObject.position.x + " " + gameObject.position.y + "#");
       }
     }
      
      
    }
  }
    
  public void defineNextSail(){
    SawTrail nextSawTrailComponent = (SawTrail)nextSawTrail.getComponent(SawTrail.class);
    
    if(nextSawTrailComponent.getNextSawTrail() != null && nextSawTrailComponent.getNextSawTrail().position != currentSawTrail.position){
      currentSawTrail = nextSawTrail;
      nextSawTrail = nextSawTrailComponent.getNextSawTrail();
    } else{
      if(nextSawTrailComponent.getPreviousSawTrail() != null){
        currentSawTrail = nextSawTrail;
        nextSawTrail = nextSawTrailComponent.getPreviousSawTrail();
      } else{
        currentSawTrail = nextSawTrail;
        nextSawTrail = nextSawTrailComponent.getNextSawTrail();
      }
    }
    
    distanceBetweenTwoSails = PVector.sub(nextSawTrail.position, currentSawTrail.position);
  }
  
  public void setBlockLocation(GameObject go){
     blockLocation = go;
  }
  
  public void addOnNetwork(){
    gameObject.addComponent(new NetworkView());
    networkId = ((NetworkView)(gameObject.getComponent(NetworkView.class))).getId(); 
  }
  
  
}
