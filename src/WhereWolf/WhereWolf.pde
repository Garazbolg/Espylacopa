
import java.awt.event.*;

SceneState scene;

String launchString = "Launch a game";
String playString = "Play";
String waitingPlayerString;

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

static WhereWolf globalEnv;

void setup() {

  //Init Programme
  //size(displayWidth/2, (displayWidth/2)*(4/3), P2D); // Test display with 4/3
  size(displayWidth/2,displayHeight/2, P2D);
  //size(displayWidth,displayHeight, P2D);
 
  frameRate(120);
  noSmooth(); //To prevent antialiasing
  ((PGraphicsOpenGL)g).textureSampling(3);
  textSize(textSize);   

  globalScale = ((height < width)?height:width)/128;// 128 => Taille de la room (Tile = 16x16 pixels ; block = 8x8 tiles) donc affichage = 8*16 = 128 pixels
  resolutionStripSize = ((width - (4*height)/3)/2)/globalScale;
  if(resolutionStripSize < 0) resolutionStripSize = 0;
  pixelResolutionStripSize = resolutionStripSize * globalScale;
  
  cameraWidth = (width - (2*resolutionStripSize)) / globalScale;
  cameraHeight = height / globalScale;
  cameraResolutionOffsetX = width/(2*globalScale);
  cameraResolutionOffsetY = height/(2*globalScale);
  //cameraResolutionOffset = cameraWidth/2;

  frame.setResizable(true);
  
  frame.addComponentListener(new ComponentAdapter() { 
    public void componentResized(ComponentEvent e) { 
      if(e.getSource()==frame) { 
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
    } 
  });


  ImageManager.start(this);
  Input.start(this);
  messageHandler = new MessageHandler(this);

  scene = SceneState.MainMenu;

  launchButton = new Rect(width/2, height/2, 1.5f*textWidth(launchString), 1.5f*textSize);


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
  Input.addButton("DebugGetDamage", "P");
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
  //Time.setTimeScale(0);
}



void draw() {

  background(100);

  Input.update();

  messageHandler.update();

  fill(0);
  text(ipAdress, width - textWidth(ipAdress), 32);

  switch(scene) {

  case MainMenu :



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

