
public class Chest extends Component {
  
  private boolean opened = false;
  private ChestContent chestContent;
  
  private float initialContentScale = 0;
  private float finalContentScale = 0.15f;
  private float minBumpContentScale = 0.08f;
  private float scaleAnimationSpeed = 0.4f;
  private boolean contentScaleAnimation = false;
  private float contentScale;
  
  
  private boolean contentPositionAnimation = false;
  private float initialHeightPosition = -5;  
  private float totalHeightAnimation = 25;
  private float finalHeightPosition;
  private float positionAnimationSpeed = 40f;
  private float contentHeightPosition;
  
  private int totalBumpNumber = 1;
  private int bumpNumber;
  
  private GameObject contentGameObject;
  private Sprite contentSpriteComponent;
  
  private GameCharacter characterOwner;
  
  private boolean bonusAttribued = false;
  private float effectDuration = 0; 
  private float effectChrono; 
  
  Chest(){
    DefineContent();
  }

  public void update(){
    if(contentScaleAnimation){
      
      if(bumpNumber > 2*totalBumpNumber){
        contentScale -= scaleAnimationSpeed * Time.deltaTime();
        
        if(contentScale <= 0){
          contentScale = 0;
          contentScaleAnimation = false;
          ApplyContentEffect();
        }
        
        contentSpriteComponent.setScale(contentScale);
      }
      
      else{
        if(bumpNumber % 2 == 0) contentScale += scaleAnimationSpeed * Time.deltaTime();
        else contentScale -= scaleAnimationSpeed * Time.deltaTime();
        
        if(contentScale >= finalContentScale){
           contentScale = finalContentScale;
           bumpNumber++;
        }
        
        else if(bumpNumber > 0 && contentScale <=minBumpContentScale){
           contentScale = minBumpContentScale;
           bumpNumber++;
        }
        
        contentSpriteComponent.setScale(contentScale);
      
      }
      
    }
   
    if(contentPositionAnimation){
      
      contentHeightPosition -= positionAnimationSpeed * Time.deltaTime();
      
      if(contentHeightPosition <= finalHeightPosition){
        contentHeightPosition = finalHeightPosition;
        contentPositionAnimation = false;
      }
      
      contentGameObject.position = new PVector(contentGameObject.position.x, contentHeightPosition);
    } 
    
    if(bonusAttribued){
      if(Time.getTime() - effectChrono > effectDuration){
        RemoveContentEffect();
        contentGameObject.destroy();
      } 
    }
  }
  
  private void DefineContent(){
    int numberOfPossibilities = ChestContent.values().length;
    chestContent = ChestContent.fromInteger((int)(random(numberOfPossibilities)));
  } 
  
  public void openChest(GameCharacter owner){
    
    ((Sprite)(gameObject.getComponent(Sprite.class))).setSprite(mapTilesSpriteSheetPath + "openChest.png");
          
    if(!opened){

      
      String spriteName = null;
    
      switch(chestContent){
        case ArmorHeart :
          spriteName = "armorHeart.png";
          break;
        case Invincibility :
          spriteName = "shieldContent.png";
          break;
        case SpeedBoost :
          spriteName = "speedContent.png";
          break;
        case Empty :
          return;
        case PowerBoost :
          spriteName = "powerContent.png";
          break;
      }
      
      opened = true;
      characterOwner = owner;
      
      contentScaleAnimation = true;
      contentPositionAnimation = true;
      contentScale = initialContentScale;
      bumpNumber = 0;
      
      contentGameObject = new GameObject("chestContent", PVector.add(gameObject.position, gameObject.parent.position, new PVector(0,initialHeightPosition)));

      contentGameObject.addComponent(new Sprite(mapTilesSpriteSheetPath + spriteName, 1));
      contentSpriteComponent = (Sprite)contentGameObject.getComponent(Sprite.class);
      
      float spriteWidth = contentSpriteComponent.getWidth();
      contentSpriteComponent.setScale(0); // this line must be after definition of spriteWidth
      
      finalContentScale = 1 - (spriteWidth/46.0f);
      minBumpContentScale = finalContentScale / 2;
      scaleAnimationSpeed = 2.7f * finalContentScale;
      
      contentHeightPosition = contentGameObject.position.y;
      finalHeightPosition = contentHeightPosition - totalHeightAnimation;
    }
  }
  
  public void ApplyContentEffect(){
    switch(chestContent){
      
      case ArmorHeart :
        characterOwner.IncreaseArmorLife(1);
        break;
      case Invincibility :
        characterOwner.activateBlinkOfInvulnerability(5000);
        characterOwner.activateInvincibilityFeedback();
        break;
      case SpeedBoost :
        effectDuration = 5000;
        characterOwner.setMovementSpeed(150);
        break;
      case PowerBoost :
        effectDuration = 5000;
        characterOwner.setDamageMultiplicator(2);
        characterOwner.getPowerEffect().setActive(true);
        break;
        
    }
    
    effectChrono = millis();
    bonusAttribued = true;
  }
  
  public boolean getOpened(){
    return opened; 
  }
  
  public void RemoveContentEffect(){
    switch(chestContent){
      case SpeedBoost :
        characterOwner.setMovementSpeed(70);
        break;
       case PowerBoost :
         characterOwner.setDamageMultiplicator(1);
        characterOwner.getPowerEffect().setActive(false);
         break;
        
    }
  }
}
