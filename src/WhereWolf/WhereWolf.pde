
/* KNOWN BUGS :
- Player can't play if his spawn position is inside a collider
- Game broken if client deconnecting before game launch
- Sometimes, host player animations not working
*/

import java.awt.event.*;

SceneState scene; // Enum used to  determine what to display on the screen

// UI String dislayed on screen
String launchString = "Launch a game";
String playString = "Play";

String waitingPlayerString; // Runtime determination (depands if player is host or not and this string will contains his client number)

// String game options
String fogOfWarString = "Fog of War";
String lowPerfString =  "Low Performances";

String labelMapSizeString = "Map Size :";

String autoMapSizeString = "Auto";
String smallMapSizeString = "Small";
String mediumMapSizeString = "Medium";
String bigMapSizeString = "Big";

String chooseClassString = "Choose you're class : ";
String hunterString = "Hunter";
String werewolfString = "Wherewolf";

// Title variables
PImage titleBackground;
PImage title;
float titleBackgroudOffset = 0;
float titleScale = 1;


boolean displayPressA = false;
float displayPressATimer = 0;


Rect mouse; // Used to display mouse position feedback, manly useful in fullscreen

// Buttons variables
Rect launchButton;
Rect playButton;

Rect fogOfWarButton;
Rect lowPerfButton;
Rect autoMapSizeButton;
Rect smallMapSizeButton;
Rect mediumMapSizeButton;
Rect bigMapSizeButton;

Rect hunterButton;
Rect werewolfButton;


int textSize = 32;
int optionsTextSize = 25;

boolean playGameWithOneComptuer = true; // Used to attributes differents inputs for each player using same keyboard
int maxPlayerNumberOnOneComputer = 3; // Depands of the number of differents inputs established

// Camera variables
PVector cameraPosition;
float cameraWidth;
float cameraHeight;

// Data paths
String characterSpriteSheetPath = "data/Characters/";
String mapTilesSpriteSheetPath = "data/Sprites/";
String spritesPath = "data/Sprites/";

// Spritesheet variables
private SpriteSheet tilesSpriteSheet;
private SpriteSheet torchSpriteSheet;
private SpriteSheet lavaSpriteSheet;
private SpriteSheet trapSpriteSheet;
private SpriteSheet sawSpriteSheet;
private SpriteSheet transformationEffectSpriteSheet;
private SpriteSheet invincibilityEffectSpriteSheet;
private SpriteSheet powerEffectSpriteSheet;


MessageHandler messageHandler;

// Like all tests have been realized with only one computer, we simulate differents clients by assigning a random ip
// Note : ip for host is useless because all code will identify him using static variable Network.isServer
// WARNING : game would be broken if random return similar number for two differents clients, be careful
int clientId = (int)random(2, 255);
String ipAdress = "127.0.0."+clientId;

// Attribuated by server
int globalPlayerNumber = 0;
boolean playerNumberAssigned = false;

float pixelResolutionStripSize;
float cameraResolutionOffsetX;
float cameraResolutionOffsetY;

// If false, saws movements are realized on each client and, despite a message from the server indicating the start signal, clients are not really synchronized, so it's really more safer to let the network synchronize the saws positions
boolean sawsManagedByNetwork = true;

// Options variables
boolean fogOfWar = false; // fog of war reduces the vision of the minimap to the rooms already visited
boolean lowPerf = false; // due to very bad optimizations from processing concerning the image display, it can be interesting to activate this option which suppresses the display of background tiles 

int mapSizeOption = 0; // affect the size of the map (0 = auto, 1 = small, 2 = mediuem, 3 = big)
int choosenClass = 0; // (0 = hunter,  1 = werewolf)

boolean gameLaunched = false; // used to filter unwanted clicks on the button which is launching the game 

static WhereWolf globalEnv; // usef for reflection in network instantiate methods (it is a specific constraint from processing)

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
 
  frame.setResizable(true); // Allow the window to be resized
  
  // Listener which is activate when window is resized
  frame.addComponentListener(new ComponentAdapter() { 
    public void componentResized(ComponentEvent e) { 
      if(e.getSource()==frame) { 
        adaptDisplayVariablesToResolution(); // some variables affecting game display are depandant of the window size
      } 
    } 
  });

  // Defines inputs
  Input.addAxis("Horizontal", "Q", "D");
  Input.addAxis("Horizontal", "joystick Axe X");
  Input.addAxis("Vertical", "Z", "S");
  Input.addAxis("Vertical", "joystick Axe Y");
  Input.addButton("Jump", "ESPACE"); 
  Input.addButton("Jump", "joystick Bouton 0");
  
  //Input.addButton("Jump","K"); // Warning : not working on mac... so I also add K button to jump
  
  Input.addButton("Fire", "A");
  Input.addButton("Fire", "joystick Bouton 1");
  Input.addButton("ShowHideMiniMap", "M");
  Input.addButton("Special", "joystick Bouton 2");
  Input.addButton("Special", "E");

  // Inputs for player 2 on keyboard
  Input.addAxis("Horizontal2", "J", "L");
  Input.addAxis("Vertical2", "I", "K");
  Input.addButton("Jump2", "ENTREE");
  Input.addButton("Fire2", "U");
  Input.addButton("Special2", "O");

  // Inputs for player 3 on keyboard
  Input.addAxis("Horizontal3", "4", "6");
  Input.addAxis("Vertical3", "8", "5");
  Input.addButton("Jump3", "0");
  Input.addButton("Fire3", "7");
  Input.addButton("Special3", "9");
  
  mouse = new Rect(mouseX, mouseY, 32, 32); // To represent the mouse on the screen
 
  // Title variables initialization
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
  
  launchButton = new Rect(width/2, height/2 + title.height/2, 1.5f*textWidth(launchString), 1.5f*textSize);
  
}



void draw() {

  background(100); // Be careful, very CPU intensive method

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
     
      titleBackgroudOffset += Time.unscaledDeltaTime() * titleBackground.width * 0.03f;
     
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
     
      titleBackgroudOffset += Time.unscaledDeltaTime() * titleBackground.width * 0.03f;
     
      if(titleBackgroudOffset > titleBackground.width){
        titleBackgroudOffset -= titleBackground.width;
      }
      
      popMatrix();
      
      image(title,width/2-title.width/2,title.height/2);
    
      fill(255);
      launchButton.draw();   

      fill(0);
      text(launchString, launchButton.position.x - textWidth(launchString)/2, launchButton.position.y + textSize/4);
  
      if (mouse.intersect(launchButton)) {
        fill(255, 0, 0);
      } else {
        fill(0);
      }

  
      break;

    case ServerWaitingForLaunch :
      fill(255);
      playButton.draw();
      drawOptions();
      
      fill(0);
      text(waitingPlayerString, width/2-(textWidth(waitingPlayerString)/2), height/2-textSize);
      text(playString, playButton.position.x - textWidth(playString)/2, playButton.position.y + textSize/4);
      if (mouse.intersect(playButton)) {
          fill(255, 0, 0);
      } else {
          fill(0);
      }
      
      if (!gameLaunched && mouse.intersect(playButton) && mousePressed) {
        gameLaunched = true;
        
        Network.write("SetFogOfWar " + fogOfWar + "#");        
        Scene.startScene(new GameObject("Scene", new PVector(), null));
        switch(mapSizeOption){
          case 0 : // Auto
            map = new MapManager(Network.numberOfClients+1, ""); 
            break;
          case 1 : // Small
            if(Network.numberOfClients+1 < 3){
              map = new MapManager(3, ""); 
            } else{
              map = new MapManager(Network.numberOfClients+1, ""); 
            }
            break;
          case 2 : // Medium
            if(Network.numberOfClients+1 < 7){
              map = new MapManager(7, ""); 
            } else{
              map = new MapManager(Network.numberOfClients+1, ""); 
            }
            break;
          case 3 : // BIg
            if(Network.numberOfClients+1 < 11){
              map = new MapManager(11, ""); 
            } else{
              map = new MapManager(Network.numberOfClients+1, ""); 
            }
            break;
        }
        
        launchGame();
      }

    break;

    case ClientWaitingForLaunch :
    
      drawOptions();
      fill(0);
      if (!playerNumberAssigned) {
        if (globalPlayerNumber > 0) {
          waitingPlayerString = "You are the client number " + globalPlayerNumber +".\nWaiting for player connexion...";
          playerNumberAssigned = true;
        }
      }
      text(waitingPlayerString, width/2-(textWidth(waitingPlayerString)/2), height/2-textSize);
  
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
  
  
  // Buttons options initialization
  lowPerfButton = new Rect(1.5f*textWidth(fogOfWarString)/2, 3*optionsTextSize + 4*optionsTextSize, 0.65f*textWidth(lowPerfString), 1.5f*optionsTextSize);
    
  float maxClassTextWidth = max(textWidth(hunterString), textWidth(werewolfString));
  hunterButton = new Rect(width - 1.5f*maxClassTextWidth/2, (2*height)/3 + 1.5f*optionsTextSize, maxClassTextWidth, 1.5f*optionsTextSize);
  werewolfButton = new Rect(width - 1.5f*maxClassTextWidth/2, (2*height)/3 + 3.2f*optionsTextSize, maxClassTextWidth, 1.5f*optionsTextSize);
    
  // Try to connect as a client, if it is ossible, server is not accessible so you become host
  if (!Network.connectClient(this, "127.0.0.1", 12345, ipAdress)) {
    Network.connectServer(this, 12345); 
    waitingPlayerString = "You are the host.\nWaiting for player connexion...";
    scene = SceneState.ServerWaitingForLaunch;
    globalPlayerNumber = 0;
    playerNumberAssigned = true;
    
    // Host buttons options initialization
    playButton = new Rect(width/2, height/2 + 3*textSize, 1.5f*textWidth(playString), 1.5f*textSize);
    fogOfWarButton = new Rect(1.5f*textWidth(fogOfWarString)/2, lowPerfButton.position.y - 4*optionsTextSize, 0.65f*textWidth(fogOfWarString), 1.5f*optionsTextSize);
    lowPerfButton = new Rect(1.5f*textWidth(fogOfWarString)/2, fogOfWarButton.position.y + 2*fogOfWarButton.halfDimension.y + optionsTextSize, 0.65f*textWidth(lowPerfString), 1.5f*optionsTextSize);
    autoMapSizeButton = new Rect(lowPerfButton.position.x + textWidth(labelMapSizeString)/2, height - optionsTextSize*2 - (1.5f*optionsTextSize)/4, 0.85f*textWidth(autoMapSizeString), 1.5f*optionsTextSize);
    smallMapSizeButton = new Rect(autoMapSizeButton.position.x + (textWidth(smallMapSizeString) - textWidth(autoMapSizeString))/2 + 2*autoMapSizeButton.halfDimension.x + 20, height - optionsTextSize*2 - (1.5f*optionsTextSize)/4, 0.85f*textWidth(smallMapSizeString), 1.5f*optionsTextSize);
    mediumMapSizeButton = new Rect(smallMapSizeButton.position.x + (textWidth(mediumMapSizeString) - textWidth(smallMapSizeString))/2 + 2*smallMapSizeButton.halfDimension.x + 20, height - optionsTextSize*2 - (1.5f*optionsTextSize)/4, 0.85f*textWidth(mediumMapSizeString), 1.5f*optionsTextSize);
    bigMapSizeButton = new Rect(mediumMapSizeButton.position.x + (textWidth(bigMapSizeString) - textWidth(mediumMapSizeString))/2 + 2*mediumMapSizeButton.halfDimension.x + 26, height - optionsTextSize*2 - (1.5f*optionsTextSize)/4, 0.85f*textWidth(bigMapSizeString), 1.5f*optionsTextSize);

  } else {
    Network.write("ClientAskHisClientNumber " + ipAdress + "#");
    waitingPlayerString = "You are the client number ?\nWaiting for player connexion...";
    scene = SceneState.ClientWaitingForLaunch;
  }

}

public void launchGame() {
  scene = SceneState.Loading;
  thread("initGame");
  fill(0);
}

// Set or update variables influencing display of the game. These variables depend of the window size.
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

// Method called from a message written by the server after all the clients had terminiated game initialization
public void startGame(){
  Time.timeScale = 1;
  scene = SceneState.Game;  
}

// Draw host and clients options
public void drawOptions(){
  textSize(optionsTextSize);
  if(Network.isServer){
    if(fogOfWar) fill(0,255,0); 
    else fill(255,0,0); 
    fogOfWarButton.draw();
    
    if(mapSizeOption == 0) fill(0,255,0); 
    else fill(255,0,0); 
    autoMapSizeButton.draw();
    
    if(mapSizeOption == 1) fill(0,255,0); 
    else fill(255,0,0); 
    smallMapSizeButton.draw();
    
    if(mapSizeOption == 2) fill(0,255,0); 
    else fill(255,0,0); 
    mediumMapSizeButton.draw();
    
    if(mapSizeOption == 3) fill(0,255,0); 
    else fill(255,0,0); 
    bigMapSizeButton.draw();
    
    fill(0);
    text(fogOfWarString, fogOfWarButton.position.x - textWidth(fogOfWarString)/2, fogOfWarButton.position.y + optionsTextSize/4);
    text(labelMapSizeString, lowPerfButton.position.x - textWidth(labelMapSizeString)/2, height - optionsTextSize*2);
    text(autoMapSizeString, autoMapSizeButton.position.x - textWidth(autoMapSizeString)/2, autoMapSizeButton.position.y + optionsTextSize/4);
    text(smallMapSizeString, smallMapSizeButton.position.x - textWidth(smallMapSizeString)/2, smallMapSizeButton.position.y + optionsTextSize/4);
    text(mediumMapSizeString, mediumMapSizeButton.position.x - textWidth(mediumMapSizeString)/2, mediumMapSizeButton.position.y + optionsTextSize/4);
    text(bigMapSizeString, bigMapSizeButton.position.x - textWidth(bigMapSizeString)/2, bigMapSizeButton.position.y + optionsTextSize/4);
  }
  
  if(lowPerf) fill(0,255,0); 
  else fill(255,0,0); 
  lowPerfButton.draw();
  
  if(choosenClass == 0) fill(0,255,0); 
  else fill(255,0,0); 
  hunterButton.draw();
  
  if(choosenClass == 1) fill(0,255,0); 
  else fill(255,0,0); 
  werewolfButton.draw();
  
  fill(0);
  text(lowPerfString, lowPerfButton.position.x - textWidth(lowPerfString)/2, lowPerfButton.position.y + optionsTextSize/4);
  text(chooseClassString, width - 1.2f*textWidth(chooseClassString), (2*height)/3);

  text(hunterString, hunterButton.position.x - textWidth(hunterString)/2, hunterButton.position.y + optionsTextSize/4);
  text(werewolfString, werewolfButton.position.x - textWidth(werewolfString)/2, werewolfButton.position.y + optionsTextSize/4);
  
  
  textSize(textSize);
}

void mouseClicked() {
  if (mouse.intersect(fogOfWarButton)) fogOfWar = !fogOfWar;
  if (mouse.intersect(lowPerfButton)) lowPerf = !lowPerf;
  
  if (mouse.intersect(autoMapSizeButton)) mapSizeOption = 0;
  if (mouse.intersect(smallMapSizeButton)) mapSizeOption = 1;
  if (mouse.intersect(mediumMapSizeButton)) mapSizeOption = 2;
  if (mouse.intersect(bigMapSizeButton)) mapSizeOption = 3;
  
  if (mouse.intersect(hunterButton)) choosenClass = 0;
  if (mouse.intersect(werewolfButton)) choosenClass = 1;
  
  if(scene == SceneState.MainMenu && mouse.intersect(launchButton)) connectToServer();
}

