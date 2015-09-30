

public class SawTrail extends Component {
  
  private byte trailType = 0; // 8 bits, 4 to indicate position of previousSawTrail and 4 to indicate position of nextSawTrail
  // 0000  : nothing    1000 : left    0100 : up    0010 right    0001 down  
 
  private GameObject previousSawTrail;
  private GameObject nextSawTrail;
  
  SawTrail(){
    
  }
  
  public void init(ArrayList<GameObject> sawsTrailsOfBlock, float tilePixelSize){
    
    PVector thisPosition = gameObject.position;
    int i=0;
    
    while(i<sawsTrailsOfBlock.size() && (previousSawTrail == null || nextSawTrail == null)){
      
      PVector otherPosition = sawsTrailsOfBlock.get(i).position;
      
      if(otherPosition.x == thisPosition.x - tilePixelSize){
        if(otherPosition.y == thisPosition.y){
          if(updateTrailType(3)){
            previousSawTrail = sawsTrailsOfBlock.get(i); 
          } else{
            nextSawTrail = sawsTrailsOfBlock.get(i); 
          }
        }
   
      }
      
      else if(otherPosition.x == thisPosition.x){
        if(otherPosition.y == thisPosition.y - tilePixelSize){
          if(updateTrailType(2)){
            previousSawTrail = sawsTrailsOfBlock.get(i); 
          } else{
            nextSawTrail = sawsTrailsOfBlock.get(i); 
          }
        }
        
        else if(otherPosition.y == thisPosition.y + tilePixelSize){
          if(updateTrailType(0)){
            previousSawTrail = sawsTrailsOfBlock.get(i); 
          } else{
            nextSawTrail = sawsTrailsOfBlock.get(i); 
          }
        }
      }
      
      else if(otherPosition.x == thisPosition.x + tilePixelSize){
        if(otherPosition.y == thisPosition.y){
          if(updateTrailType(1)){
            previousSawTrail = sawsTrailsOfBlock.get(i); 
          } else{
            nextSawTrail = sawsTrailsOfBlock.get(i); 
          }
        }
      }
      
      i++;
    }
    
    
    addGoodSprite();
  }
  
  public boolean updateTrailType(int bitPower){
    if(trailType >= 0 && trailType < 8){
      trailType|=(1<<(bitPower+4)); // set type for previousSawTrail
      return true;
    }
          
    else{
      trailType|=(1<<bitPower); // set type for nextSawTrail
      return false;
    }
  }
  
  public void addGoodSprite(){

    int unsginedValue = trailType;
    if(unsginedValue < 0 ){
      unsginedValue+= 256;
    } 
    
    switch(unsginedValue){
      case 0 : 
      case 32 : 
      case 40 : 
      case 128 : 
      case 130 : 
        gameObject.addComponent(new Sprite(mapTilesSpriteSheetPath + "sawTrailLeftToRight.png"));
        break;
      case 16 : 
      case 20 : 
      case 64 :  
      case 65 :  
        gameObject.addComponent(new Sprite(mapTilesSpriteSheetPath + "sawTrailUpToDown.png"));
        break;
      case 18 :
      case 33 :
        gameObject.addComponent(new Sprite(mapTilesSpriteSheetPath + "sawTrailDownToRight.png"));
        break;
      case 24 :
      case 129 :
        gameObject.addComponent(new Sprite(mapTilesSpriteSheetPath + "sawTrailLeftToDown.png"));
        break;
      case 36 :
      case 66 :  
        gameObject.addComponent(new Sprite(mapTilesSpriteSheetPath + "sawTrailUpToRight.png"));
        break;
      case 72 :  
      case 132 :
        gameObject.addComponent(new Sprite(mapTilesSpriteSheetPath + "sawTrailLeftToUp.png"));
        break;
        
        
      default : println("Error in the init method algorithm, get this unespected value : " + unsginedValue + "from this byte value : " + trailType);
        break;  
      
    }
    
  }

  public GameObject getPreviousSawTrail(){
    return previousSawTrail;
  }
  
  public GameObject getNextSawTrail(){
    return nextSawTrail;
  }
  
  
}
