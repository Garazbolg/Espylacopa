GameObject player;
GameCharacter playerCharacterComponent;
 
float globalScale = 1.0;

MapManager map;
int xBlock = 2;
int yBlock = 3;
int previousYblock = 2;
int previousXblock = 3;

GameObject trapsContainer;
GameObject sawsContainer;
GameObject sawsTrailContainer;

//enum Camera{Canvas,CenteredScroll,ForwardOffsetScroll};
private boolean cameraScroll = true;
private boolean cameradCentered = false;
private float maxCameraForwardOffset = 20;
private float cameraForwardOffset;

private float cameraLerpSpeed;

private PVector playerColliderHalfDimensions;

private float resolutionStripSize; // taille des bandes noires

private PVector spawnPosition;
private int spawnXblock;
private int spawnYblock;

private float orientCameraDelay = 400;
private float orientCameraChrono;
private boolean playerImmobileAndLookUp;
private boolean playerImmobileAndLookDown;

private float cameraOrientation = 0;
private float maxCameraOrientation = 50;

public boolean showMiniMap = true;

void initGame() {
  

  globalScale = ((displayHeight < displayWidth)?displayHeight:displayWidth)/128;// 128 => Taille de la room (Tile = 16x16 pixels ; block = 8x8 tiles) donc affichage = 8*16 = 128 pixels
 

  
  resolutionStripSize = (width - (globalScale*128))/14;
  
  
  delay(2000); // Wait the end of the map generation to avoid low frame rate at start
  
  
  /*
  player = new WerewolfPrefab("One", GetSpawnPosition());
  playerCharacterComponent = (GameCharacter)(player.getComponent(Werewolf.class));
  */
  
  /*
  sawsTrailsContainer = new GameObject("SawsTrailsContainer", new PVector());
  Scene.addChildren(sawsTrailsContainer);
  */
  
  sawsContainer = new GameObject("SawsContainer", new PVector());
  Scene.addChildren(sawsContainer);
  
  map.AddSawsToGoodDisplayLayer();
  
  trapsContainer = new GameObject("TrapsContainer", new PVector());
  Scene.addChildren(trapsContainer);
  
  // Player = villager
  
  player = new VillagerPrefab("One", GetSpawnPosition());
  playerCharacterComponent = (GameCharacter)(player.getComponent(Villager.class));
  
  new VillagerPrefab("Two",  PVector.add(GetSpawnPosition(), new PVector(20,0)));
  spawnPosition = new PVector(player.position.x, player.position.y);
  
  // Player = werewolf
  /*
  player = new WerewolfPrefab("One", GetSpawnPosition());
  playerCharacterComponent = (GameCharacter)(player.getComponent(Werewolf.class));
  */
  
  
    

  playerColliderHalfDimensions = ((Rect)(((Collider)player.getComponent(Collider.class)).area)).halfDimension;

  cameraPosition = new PVector(player.getPosition().x-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);

  cameraWidth = (displayWidth - (2*resolutionStripSize)) / globalScale;
  cameraHeight = displayHeight / globalScale;
  
  Updatables.start();

  scene = SceneState.Game;
  


}

void gameDraw() {

  Updatables.update();
  
//Move
// Done in Villager class
  //((Rigidbody) player.getComponent(Rigidbody.class)).setVelocity(new PVector(Input.getAxisRaw("Horizontal")*70.0f,((Rigidbody) player.getComponent(Rigidbody.class)).getVelocity().y));
  
  
  // DEBUG
  if(Input.getButtonDown("DebugGetDamage")) playerCharacterComponent.DecreaseLife(1, player.position);

  if(! Constants.DEBUG_MODE)
  //Draw
  scale(globalScale); //Mise à l'échelle par rapport à la taille de l'écran (faudra penser à mettre les bords en noirs)

  //fill(255);
  //rect(resolutionStripSize, 0, 128, 128); // fond blanc central en attendant le design des niveaux


 // pushMatrix();
 if(! Constants.DEBUG_MODE){
  if(cameraScroll) translate(-cameraPosition.x, -cameraPosition.y);
  else translate(-xBlock*map.GetBlockPixelSizeX(),-yBlock*map.GetBlockPixelSizeY());
 }
 
 manageCameraOrientation();
  Scene.draw();
 // popMatrix();


  

  //Debug Draw
  if (!Constants.DEBUG_MODE){
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
  
  playerCharacterComponent.drawLife();


  //TODO : display a proper minimap
  
  if(Input.getButtonDown("ShowHideMiniMap")){
    showMiniMap = !showMiniMap; 
  }
  
  if(showMiniMap) map.DrawMiniMap(xBlock, yBlock);
  

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
  
  if(map.BlockOutOfMap(xBlock, yBlock)){
     ResetToSpawnPosition();
  }
}


private void CameraManagement() {
  if(player.getPosition().x - map.GetTilePixelSize()/2 + playerColliderHalfDimensions.x < (map.GetBlockPixelSizeX()*xBlock)+resolutionStripSize){
    previousXblock = xBlock;
    previousYblock = yBlock;
    xBlock--;
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  else if(player.getPosition().x - map.GetTilePixelSize()/2 + playerColliderHalfDimensions.x  > resolutionStripSize+(map.GetBlockPixelSizeX()*(xBlock+1))){
    previousXblock = xBlock;
    previousYblock = yBlock;
    xBlock++;
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  if(player.getPosition().y + playerColliderHalfDimensions.y - map.tilePixelSize/2 < (map.GetBlockPixelSizeY()*yBlock)){
    previousXblock = xBlock;
    previousYblock = yBlock;
    yBlock--; 
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  else if(player.getPosition().y + playerColliderHalfDimensions.y - map.tilePixelSize/2 > (map.GetBlockPixelSizeY()*(yBlock+1))){
    previousXblock = xBlock;
    previousYblock = yBlock;
    yBlock++; 
    
    map.UpdateMap(xBlock, yBlock, previousXblock, previousYblock);
  }
  
  if(cameraScroll) {
    if(cameradCentered){
      cameraPosition = new PVector(player.getPosition().x-map.GetBlockPixelSizeX()+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y);
    }
    
    else{
      
      if(playerCharacterComponent.isFacingRight()){
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
  
  spawnXblock = xBlock;
  spawnYblock = yBlock;
  
  
  map.UpdateMap(xBlock, yBlock, xBlock, yBlock);
  
  return map.GetSpawnPosition();
}

public void ResetToSpawnPosition(){
  xBlock = spawnXblock;
  yBlock = spawnYblock;  
  
  map.UpdateMap(xBlock, yBlock, xBlock, yBlock);
  
  player.position = new PVector(spawnPosition.x, spawnPosition.y);
  
  cameraPosition = new PVector(player.getPosition().x-128+1.5*playerColliderHalfDimensions.x, player.getPosition().y-64+playerColliderHalfDimensions.y); 
}

public void manageCameraOrientation(){
  
  float AxisValue = Input.getAxisRaw("Vertical");
    
  if(!playerCharacterComponent.isImmobile() || AxisValue == 0){
    playerImmobileAndLookUp = false;
    playerImmobileAndLookDown = false;
      
    if(cameraOrientation > 0) cameraOrientation--;
    else if(cameraOrientation < 0) cameraOrientation++;
  }
  else if(AxisValue < 0){
    if(!playerImmobileAndLookDown){
      playerImmobileAndLookDown = true;
      if(cameraOrientation == 0){
        orientCameraChrono = Time.getTime();
      }
    }
    
    if(Time.getTime() - orientCameraChrono > orientCameraDelay){
      cameraOrientation++;
      if(cameraOrientation > maxCameraOrientation) cameraOrientation =  maxCameraOrientation;
    }
    
  } else if(AxisValue > 0){
    if(!playerImmobileAndLookDown){
      playerImmobileAndLookDown = true;
      if(cameraOrientation == 0){
        orientCameraChrono = Time.getTime();
      }
    }
    
    if(Time.getTime() - orientCameraChrono > orientCameraDelay){
      cameraOrientation--;
      if(cameraOrientation < -maxCameraOrientation) cameraOrientation =  -maxCameraOrientation;        
    }
    
  }
   
  translate(0,cameraOrientation); 

}

public float getCameraOrientation(){
  return cameraOrientation; 
}



    


