
import java.awt.event.*;

SceneState scene;

String launchString = "Launch a game";
String playString = "Play";
String waitingPlayerString;

PImage titleBackground;
PImage title;
float titleBackgroudOffset = 0;
float titleScale = 1;
boolean displayPressA = false;
float displayPressATimer = 0;

Rect mouse;
Rect launchButton;
Rect playButton;

int textSize = 32;

boolean playGameWithOneComptuer = true; // Used to attributes differents inputs for each player using same keyboard
int maxPlayerNumberOnOneComputer = 3; // Depands of the number of differents inputs established


PVector cameraPosition;
float cameraWidth;
float cameraHeight;

// Data paths
String characterSpriteSheetPath = "data/Characters/";
String mapTilesSpriteSheetPath = "data/Sprites/";
String spritesPath = "data/Sprites/";

private SpriteSheet tilesSpriteSheet;
private SpriteSheet torchSpriteSheet;
private SpriteSheet lavaSpriteSheet;
private SpriteSheet trapSpriteSheet;
private SpriteSheet sawSpriteSheet;
private SpriteSheet transformationEffectSpriteSheet;
private SpriteSheet invincibilityEffectSpriteSheet;
private SpriteSheet powerEffectSpriteSheet;

MessageHandler messageHandler;

int clientId = (int)random(2, 255);
String ipAdress = "127.0.0."+clientId;

int globalPlayerNumber = 0;
boolean playerNumberAssigned = false;

float pixelResolutionStripSize;
float cameraResolutionOffsetX;
float cameraResolutionOffsetY;

boolean sawsManagedByNetwork = true;

static WhereWolf globalEnv;

void setup(){
  
  //Init Programme
  //size(displayWidth/2, (displayWidth/2)*(4/3), P2D); // Test display with 4/3
  size(displayWidth/2,displayHeight/2, P2D);
  //size(displayWidth,displayHeight, P2D);
  frameRate(120);
  noSmooth(); //To prevent antialiasing
  ((PGraphicsOpenGL)g).textureSampling(3);
  textSize(textSize);   
 
  ImageManager.start(this);
  Input.start(this);
  messageHandler = new MessageHandler(this);
 
  scene = SceneState.Title;
 
  launchButton = new Rect(width/2, height/2, 1.5f*textWidth(launchString), 1.5f*textSize);

  frame.setResizable(true);
  
  frame.addComponentListener(new ComponentAdapter() { 
    public void componentResized(ComponentEvent e) { 
      if(e.getSource()==frame) { 
        adaptDisplayVariablesToResolution();
      } 
    } 
  });

  //scene = SceneState.MainMenu;


  mouse = new Rect(mouseX, mouseY, 32, 32); // To represent the mouse on the screen

  // Defines inputs
  Input.addAxis("Horizontal", "Q", "D");
  Input.addAxis("Horizontal", "joystick Axe X");
  Input.addAxis("Vertical", "Z", "S");
  Input.addAxis("Vertical", "joystick Axe Y");
  Input.addButton("Jump", "ESPACE"); // Warning : not working on mac... so I also add K button to jump
  //Input.addButton("Jump","K");
  Input.addButton("Jump", "joystick Bouton 0");
  Input.addButton("Fire", "A");
  Input.addButton("Fire", "joystick Bouton 1");
  Input.addButton("ShowHideMiniMap", "M");
  Input.addButton("Special", "joystick Bouton 2");
  Input.addButton("Special", "E");

  Input.addAxis("Horizontal2", "J", "L");
  Input.addAxis("Vertical2", "I", "K");
  Input.addButton("Jump2", "ENTREE");
  Input.addButton("Fire2", "U");
  Input.addButton("Special2", "O");

  Input.addAxis("Horizontal3", "4", "6");
  Input.addAxis("Vertical3", "8", "5");
  Input.addButton("Jump3", "0");
  Input.addButton("Fire3", "7");
  Input.addButton("Special3", "9");
  
  mouse = new Rect(mouseX, mouseY, 32, 32); // To represent the mouse on the screen
 
  titleBackground = ImageManager.getImage("Misc/title_WhereWolf.png");
  //titleBackground.resize(0,displayHeight);
  titleScale = height* 1.0f /titleBackground.height;
  title = ImageManager.getImage("Misc/title.png");

  // Load game sprite sheets  
  tilesSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "tilesSpriteSheet.png", 24, 20);
  torchSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "torchSpriteSheet.png", 4, 1);
  lavaSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "lavaSpriteSheet.png", 4, 1);
  trapSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "trapSpriteSheet.png", 3, 1);
  sawSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "fullSawSpriteSheet.png", 2, 1);
  transformationEffectSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "transformationEffectSpriteSheet.png", 9, 1);
  invincibilityEffectSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "invincibilityEffectSpriteSheet.png", 6, 1);
  powerEffectSpriteSheet = new SpriteSheet(mapTilesSpriteSheetPath + "powerEffectSpriteSheet.png", 3, 1);

  globalEnv = this;
  
  //Updatables.start();
  GUI.start(this);
  
  
  
}



void draw() {

  background(100);

  Input.update();
  Updatables.update();
  
  messageHandler.update();

  fill(255);
  text(ipAdress, width - textWidth(ipAdress), 32);

  switch(scene) {

    case Title :
      pushMatrix();
      scale(titleScale);
      image(titleBackground,titleBackgroudOffset-titleBackground.width,0);
      image(titleBackground,titleBackgroudOffset,0);
      image(titleBackground,titleBackgroudOffset+titleBackground.width,0);
     
      titleBackgroudOffset += Time.unscaledDeltaTime() * titleBackground.width * 0.3f;
     
      if(titleBackgroudOffset > titleBackground.width){
        titleBackgroudOffset -= titleBackground.width;
      }
      if(Input.getButtonDown("Jump")){
        scene = SceneState.MainMenu;
      }
     
      popMatrix();
      
      image(title,width/2-title.width/2,title.height/2);
      
      if(displayPressA){
        fill(255);
        GUI.labelCenter(new PVector(width/2,height/3.0f*2),"Press A ...");
        fill(0);
      }
     
      displayPressATimer += Time.unscaledDeltaTime()*1.5;
      
      if(displayPressATimer > 1){
        displayPressA = ! displayPressA;
        displayPressATimer -= 1;
      }
      
    break;
   
    case MainMenu :
    
      pushMatrix();
      scale(titleScale);
      image(titleBackground,titleBackgroudOffset-titleBackground.width,0);
      image(titleBackground,titleBackgroudOffset,0);
      image(titleBackground,titleBackgroudOffset+titleBackground.width,0);
     
      titleBackgroudOffset += Time.unscaledDeltaTime() * titleBackground.width * 0.3f;
     
      if(titleBackgroudOffset > titleBackground.width){
        titleBackgroudOffset -= titleBackground.width;
      }
      
      popMatrix();
      
      image(title,width/2-title.width/2,title.height/2);
    
      fill(255);
      launchButton.draw();   

      fill(0);
      text(launchString, launchButton.position.x - textWidth(launchString)/2, launchButton.position.y + textSize/4);
  
      if (Input.getButtonDown("Jump")) {
        connectToServer();
      } else {
        if (mouse.intersect(launchButton)) {
          fill(255, 0, 0);
          if (mousePressed) {
            connectToServer();
          }
        } else {
          fill(0);
        }
      }

  
      //rect(mouse.position.x, mouse.position.y, 2*mouse.halfDimension.x, 2*mouse.halfDimension.y);
      break;

    case ServerWaitingForLaunch :
      fill(255);
      playButton.draw();
      fill(0);
      text(waitingPlayerString, width/2-textWidth(playString), height/2-textSize);
      text(playString, playButton.position.x - textWidth(playString)/2, playButton.position.y + textSize/4);
    
      if (Input.getButtonDown("Jump")) {          
        Scene.startScene(new GameObject("Scene", new PVector(), null));
        map = new MapManager(8, ""); 
        launchGame();
      } else {  
        if (mouse.intersect(playButton)) {
          fill(255, 0, 0);
          if (mousePressed) {
            Scene.startScene(new GameObject("Scene", new PVector(), null));
            map = new MapManager(8, ""); 
            launchGame();
          }
        } else {
          fill(0);
        }
      }

    break;

    case ClientWaitingForLaunch :
      fill(0);
      if (!playerNumberAssigned) {
        if (globalPlayerNumber > 0) {
          waitingPlayerString = "You are the client number " + globalPlayerNumber +".\nWaiting for player connexion...";
          playerNumberAssigned = true;
        }
      }
      text(waitingPlayerString, width/2-textWidth(playString), height/2-textSize);
  
      messageHandler.update();
      break;
  
    case Loading :
      text("Loading...", width/2-textWidth(playString), height/2-textSize);
      break;
  
    case Game :
      gameDraw();
      break;
  
    default :
      println("ERROR ERROR CASE NOT MANAGED");
      break;
  }
  
  if (scene != SceneState.Game) {
    mouse.position.x = mouseX;
    mouse.position.y = mouseY;
    mouse.draw();
  }
}

boolean sketchFullScreen() {
  if (Constants.DEBUG_MODE)
    return false;

  //return true;
  return false;
}

public void connectToServer() {
  if (!Network.connectClient(this, "127.0.0.1", 12345, ipAdress)) {
    Network.connectServer(this, 12345); 
    waitingPlayerString = "You are the host.\nWaiting for player connexion...";
    scene = SceneState.ServerWaitingForLaunch;
    globalPlayerNumber = 0;
    playerNumberAssigned = true;
  } else {
    println("Client ip = " + ipAdress);
    Network.write("ClientAskHisClientNumber " + ipAdress + "#");
    waitingPlayerString = "You are the client number ?\nWaiting for player connexion...";
    scene = SceneState.ClientWaitingForLaunch;
  }

  playButton = new Rect(width/2, height/2 + 3*textSize, 1.5f*textWidth(playString), 1.5f*textSize);
}

public void launchGame() {
  scene = SceneState.Loading;
  thread("initGame");
  fill(0);
}

public void adaptDisplayVariablesToResolution(){
  globalScale = ((height < width)?height:width)/128;// 128 => Taille de la room (Tile = 16x16 pixels ; block = 8x8 tiles) donc affichage = 8*16 = 128 pixels
  resolutionStripSize = ((width - (4*height)/3)/2)/globalScale;
  if(resolutionStripSize < 0) resolutionStripSize = 0;
  pixelResolutionStripSize = resolutionStripSize * globalScale;
  
  cameraWidth = (width - (2*resolutionStripSize)) / globalScale;
  cameraHeight = height / globalScale;
  cameraResolutionOffsetX = width/(2*globalScale);
  cameraResolutionOffsetY = height/(2*globalScale);
  if(map != null) map.DefineMiniMapSize();
}

public void startGame(){
  Time.timeScale = 1;
  scene = SceneState.Game;  
}

