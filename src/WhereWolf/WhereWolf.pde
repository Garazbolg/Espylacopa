SceneState scene;

String playString = "Play";
Rect mouse;
Rect playButton;
int textSize = 32;

boolean skipMainMenu = false;

String characterSpriteSheetPath = "Resources/Characters/";
String mapTilesSpriteSheetPath = "Resources/Sprites/";
String spritesPath = "Resources/Sprites/";

private SpriteSheet tilesSpriteSheet;
private SpriteSheet torchSpriteSheet;
  
void setup(){
  
 //Init Programme
  
 size(displayWidth,displayHeight);
 frameRate(120);
 noSmooth();                        //To prevent antialiasing
 
 ImageManager.start(this);
 Input.start(this);
 
 scene = SceneState.MainMenu;
  textSize(textSize);   
  playButton = new Rect(width/2-textWidth(playString), height/2-textSize, textWidth(playString), 32);
  mouse = new Rect(mouseX, mouseY, 32,32);
 Input.addAxis("Horizontal","Q","D");
 Input.addAxis("Horizontal","joystick Axe X");
 Input.addAxis("Vertical","Z","S");
 Input.addAxis("Vertical","joystick Axe Y");
 Input.addButton("Jump","ESPACE");
 Input.addButton("Jump","joystick Bouton 0");
 Input.addButton("Fire","A");
 Input.addButton("Fire","joystick Bouton 1");
 
 if(skipMainMenu) {
    scene = SceneState.Game;
    initGame();
  }
  
  tilesSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "tilesSpriteSheet.png", 24, 20);
  torchSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "torchSpriteSheet.png", 4, 6);
}
 


void draw(){
  
  background(255);
  //Updatables.update();
  Input.update();
  
  
  if(scene==SceneState.MainMenu){
  mouse.position.x = mouseX - mouse.halfDimension.x;
    mouse.position.y = mouseY - mouse.halfDimension.y;
   
   fill(0);
   rect(mouse.position.x, mouse.position.y, 2*mouse.halfDimension.x, 2*mouse.halfDimension.y);
   //rect(mouse.position.x, mouse.position.y, mouse.dimension.x,mouse.dimension.y);
   
    text(playString, width/2-textWidth(playString),height/2-textSize);
    if(mouse.intersect(playButton)){
      if(mousePressed){
        scene = SceneState.Game;
        initGame();
      }

    }
    else{
      if(Input.getButtonDown("Jump")){
        scene = SceneState.Game;
        initGame();
      }      
    }
  }
  
  else if(scene==SceneState.Game){
    gameDraw();
  }
  
  else{
    println("ERROR ERROR CASE NOT MANAGED");  
  }  
    
}

boolean sketchFullScreen() {
  if(Constants.DEBUG_MODE)
    return false;
    
  return true;
}
