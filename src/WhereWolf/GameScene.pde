GameCharacter player;
Rigidbody rig;
 
float globalScale = 1.0;

MapManager map;
int xBlock = 2;
int yBlock = 3;
int previousYblock = 2;
int previousXblock = 3;

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

  map = new MapManager(3);

  GameObject two, three, four, five;
  
  //player = new GameCharacter("One", "Villageois", GetSpawnPosition());
  //player = new Villager("One", GetSpawnPosition());
  player = new Werewolf("One", GetSpawnPosition());
    
  player.SetLife(5);
  player.SetArmorLife(3);
  playerColliderHalfDimensions = ((Rect)(((Collider)player.getComponent(Collider.class)).area)).halfDimension;

  resolutionStripSize = (width - (globalScale*128))/14;
  cameraPosition = new PVector(player.getPosition().x-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);

  /*player.addComponent(new Rigidbody());
   player.addComponent(new StaticAnimation(new Animation(new SpriteSheet("VillageoisSpriteSheet.png",8,4),0,true),6));
   player.addComponent(new Collider(new Rect(0,0,16,32)));*/
   
  /*
  two = new GameObject("Two", new PVector(500, 400));
  two.addComponent(new Collider(new Rect(0, 0, 50, 100)));
  */
  
  /*five = new GameObject("Two", new PVector(600, 400));
  five.addComponent(new Collider(new Rect(0, 0, 50, 100)));
  three = new GameObject("Three", new PVector(400, -400)/*,one*///);
  /*
  three.addComponent(new Collider(new Circle(0, 0, 100)));
  three.addComponent(new Rigidbody());
  four = new GameObject("Four", new PVector(500, 600));
  four.addComponent(new Collider(new Rect(0, 0, 700, 150)));

  ((Collider)three.getComponent(Collider.class)).isTrigger = true;
  */
  
  Updatables.start();
  rig = ((Rigidbody) player.getComponent(Rigidbody.class));

}

void gameDraw() {

  Updatables.update();

//Move
// Done in Villager class
  //((Rigidbody) player.getComponent(Rigidbody.class)).setVelocity(new PVector(Input.getAxisRaw("Horizontal")*70.0f,((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().y));
  
// TODO : prevent to jump while in the air
  if(Input.getButtonDown("Jump") && rig.grounded) rig.setVelocity(new PVector(rig.getVelocity().x,-100.0f));
  

  if(! Constants.DEBUG_MODE)
  //Draw
  scale(globalScale); //Mise à l'échelle par rapport à la taille de l'écran (faudra penser à mettre les bords en noirs)

  //fill(255);
  //rect(resolutionStripSize, 0, 128, 128); // fond blanc central en attendant le design des niveaux


 // pushMatrix();
 if(! Constants.DEBUG_MODE){
  if(cameraScroll) translate(-cameraPosition.x, -cameraPosition.y);
  else translate(-xBlock*map.GetBlockPixelSize(),-yBlock*map.GetBlockPixelSize());
 }

  fill(0, 255, 0);
  rect(256+resolutionStripSize, 460, 64, 10);
  fill(255, 0, 0);
  rect(256+resolutionStripSize+64, 460+64, 64, 10);

  Scene.draw();
 // popMatrix();


  

  //Debug Draw
  if (Constants.DEBUG_MODE){
    cameraDrawDebug();
    Scene.debugDraw();
  }


  // TODO : activate this line to have the draw of the map
  //map.DrawMap(xBlock, yBlock);

  //GUI
  resetMatrix();    
  //TODO : GUI part
  if(! Constants.DEBUG_MODE){
    fill(0);
    rect(0, 0, globalScale*resolutionStripSize, height); // bande noire gauche
    rect(globalScale*(resolutionStripSize+128), 0, globalScale*resolutionStripSize, height); // bande noire droite
  }
  
  player.drawLife();


  //TODO : display a proper minimap
  map.DrawMiniMap(xBlock, yBlock);
  

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
  if(player.getPosition().x < (map.GetBlockPixelSize()*xBlock)+resolutionStripSize){
    previousXblock = xBlock;
    previousYblock = yBlock;
    xBlock--;
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  else if(player.getPosition().x > resolutionStripSize+(map.GetBlockPixelSize()*(xBlock+1))){
    previousXblock = xBlock;
    previousYblock = yBlock;
    xBlock++; 
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  if(player.getPosition().y < (map.GetBlockPixelSize()*yBlock)){
    previousXblock = xBlock;
    previousYblock = yBlock;
    yBlock--; 
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  else if(player.getPosition().y > (map.GetBlockPixelSize()*(yBlock+1))){
    previousXblock = xBlock;
    previousYblock = yBlock;
    yBlock++; 
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  if(cameraScroll) {
    if(cameradCentered){
      cameraPosition = new PVector(player.getPosition().x-map.GetBlockPixelSize()+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);
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

public PVector GetSpawnPosition(){
  xBlock = map.GetSpawnIndexX();
  yBlock = map.GetSpawnIndexY();
  
  map.UpdateMap(xBlock, yBlock, xBlock, yBlock);
  
  return map.GetSpawnPosition();
}


    


