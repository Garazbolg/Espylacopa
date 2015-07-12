GameCharacter player;
 
float globalScale = 1.0;

MapManager map;
int xBlock = 2;
int yBlock = 3;

//enum Camera{Canvas,CenteredScroll,ForwardOffsetScroll};
private boolean cameraScroll = true;
private boolean cameradCentered = false;
private float maxCameraForwardOffset = 20;
private float cameraForwardOffset;
private PVector cameraPosition;
private float cameraLerpSpeed;

private PVector playerColliderHalfDimensions;

private float resolutionStripSize; // taille des bandes noires

void initGame() {
  
  globalScale = ((displayHeight < displayWidth)?displayHeight:displayWidth)/128;// 128 => Taille de la room (Tile = 16x16 pixels ; block = 8x8 tiles) donc affichage = 8*16 = 128 pixels
 

  Scene.startScene(new GameObject("Scene", new PVector(), null));



  GameObject two, three, four, five;
  player = new GameCharacter("One", "Villageois", new PVector(350, 100));
  //player = new GameCharacter("One","Villageois",new PVector(0,0));
  player.SetLife(5);
  player.SetArmorLife(3);
  playerColliderHalfDimensions = ((Rect)(((Collider)player.getComponent(Collider.class)).area)).halfDimension;

  resolutionStripSize = (width - (globalScale*128))/14;
  cameraPosition = new PVector(player.getPosition().x-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);

  /*player.addComponent(new Rigidbody());
   player.addComponent(new StaticAnimation(new Animation(new SpriteSheet("VillageoisSpriteSheet.png",8,4),0,true),6));
   player.addComponent(new Collider(new Rect(0,0,16,32)));*/
  two = new GameObject("Two", new PVector(500, 400));
  two.addComponent(new Collider(new Rect(0, 0, 50, 100)));
  five = new GameObject("Two", new PVector(600, 400));
  five.addComponent(new Collider(new Rect(0, 0, 50, 100)));
  three = new GameObject("Three", new PVector(400, -400)/*,one*/);
  three.addComponent(new Collider(new Circle(0, 0, 100)));
  three.addComponent(new Rigidbody());
  four = new GameObject("Four", new PVector(500, 600));
  four.addComponent(new Collider(new Rect(0, 0, 700, 150)));

  ((Collider)three.getComponent(Collider.class)).isTrigger = true;
  Updatables.start();
  //((Rigidbody) player.getComponent(Rigidbody.class)).setVelocity(new PVector(10,0));

  map = new MapManager(3);
}

void gameDraw() {

  Updatables.update();
/*
  if (mousePressed)
    Time.setTimeScale(0.5f);*/


  //Input

  //TODO
  /*
  ((Rigidbody) player.getComponent(Rigidbody.class)).setVelocity(new PVector(Input.getAxis("Horizontal")*70.0f,((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().y));
  if(Input.getButtonDown("Jump"))  
      ((Rigidbody) player.getComponent(Rigidbody.class)).setVelocity(new PVector(((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().x,-70.0f));
  */
  
  int leftMoove = 0;
  if(keyPressed){
    if(keyCode == LEFT) leftMoove = -1;
    if(keyCode == RIGHT) leftMoove = 1;
  }
  ((Rigidbody) player.getComponent(Rigidbody.class)).setVelocity(new PVector(leftMoove*70.0f,((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().y));
  
  if(keyPressed && key == ' ') ((Rigidbody) player.getComponent(Rigidbody.class)).setVelocity(new PVector(((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().x,-70.0f));
  

  //Draw
  scale(globalScale); //Mise à l'échelle par rapport à la taille de l'écran (faudra penser à mettre les bords en noirs)

  //fill(255);
  //rect(resolutionStripSize, 0, 128, 128); // fond blanc central en attendant le design des niveaux


 // pushMatrix();
  if(cameraScroll) translate(-cameraPosition.x, -cameraPosition.y);
  else translate(-xBlock*128,-yBlock*128);

  fill(0, 255, 0);
  rect(256+resolutionStripSize, 384, 64, 10);
  fill(255, 0, 0);
  rect(256+resolutionStripSize+64, 384+64, 64, 10);

  Scene.draw();
 // popMatrix();


  cameraDrawDebug();

  //Debug Draw
  if (Constants.DEBUG_MODE)
    Scene.debugDraw();


  // TODO : activate this line to have the draw of the map
  //map.DrawMap(xBlock, yBlock);

  //GUI
  resetMatrix();    
  //TODO : GUI part
  
  fill(0);
  rect(0, 0, globalScale*resolutionStripSize, height); // bande noire gauche
  rect(globalScale*(resolutionStripSize+128), 0, globalScale*resolutionStripSize, height); // bande noire droite
  
  player.drawLife();



  //TODO : display a proper minimap
  map.DrawMiniMap();
  

  // Matrix to manage the

  if (!cameraScroll) {
    pushMatrix();
    CameraManagement();
    popMatrix();
  } else {
    CameraManagement();
  }
  
  if (Constants.SHOW_FPS) {
    fill(255, 0, 0);
    text(Time.getFPS(), 0, textAscent());
  }
}


private void CameraManagement() {
  if(player.getPosition().x < (128*xBlock)+resolutionStripSize){
    xBlock--; 
  }
  
  else if(player.getPosition().x > resolutionStripSize+(128*(xBlock+1))){
    xBlock++; 
  }
  
  if(player.getPosition().y < (128*yBlock)){
    yBlock--; 
  }
  
  else if(player.getPosition().y > (128*(yBlock+1))){
    yBlock++; 
  }
  
  if(cameraScroll) {
    if(cameradCentered){
      cameraPosition = new PVector(player.getPosition().x-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);
    }
    
    else{
      
      if(player.isFacingRight()){
        if(cameraForwardOffset < 0) cameraLerpSpeed = 0.03; 
        else cameraLerpSpeed = 0.05;
        cameraForwardOffset = lerp(cameraForwardOffset, maxCameraForwardOffset, cameraLerpSpeed);
        cameraPosition = new PVector(player.getPosition().x+cameraForwardOffset-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);
      }
      
      else{
        if(cameraForwardOffset > 0) cameraLerpSpeed = 0.03; 
        else cameraLerpSpeed = 0.05;
        cameraForwardOffset = lerp(cameraForwardOffset, -maxCameraForwardOffset, cameraLerpSpeed);
        cameraPosition = new PVector(player.getPosition().x+cameraForwardOffset-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);
      }
    }
  }
}

public void cameraDrawDebug(){
  fill(0,0,255);
  noStroke();
  rect(player.getPosition().x+cameraForwardOffset, player.getPosition().y, 1, 100); 
}


    


