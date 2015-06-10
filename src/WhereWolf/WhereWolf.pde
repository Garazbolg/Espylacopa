
SceneState scene;

enum SceneState{MainMenu, Game};

String playString = "Play";
Rect mouse;
Rect playButton;
int textSize = 32;

boolean skipMainMenu = true;

void setup(){
  
  size(displayWidth,displayHeight);
  frameRate(120);
  noSmooth(); //To prevent antialiasing

  Constants.DEBUG_MODE = false;
  Constants.SHOW_FPS = true;
  
  scene = SceneState.MainMenu;
  textSize(textSize);   
  playButton = new Rect(width/2-textWidth(playString), height/2-textSize, textWidth(playString), 32);
  mouse = new Rect(mouseX, mouseY, 32,32);
 
  if(skipMainMenu) {
    scene = SceneState.Game;
    initGame();
  }
}

void draw(){  
  background(255);
  
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
  }
  
  else if(scene==SceneState.Game){
    gameDraw();
  }
  
  else{
    println("ERROR ERROR CASE NOT MANAGED");  
  }  
  
  
}


boolean sketchFullScreen() {
  return false;
}
