import java.io.*;
import java.io.FilenameFilter;

public class MapManager {

  private byte[][] mapBlocks; // each Block is stocked as a byte, the four least significant bits defines the connections with neighboring Blocks, the 4 most significant bits are for used to get the specific type of brick to use
  private int[][] selectedBlocks; // .txt file selected to define tiles in each blocks, must be sent by serer to copy map
  private GameObject[][] mapBlocksGameObjects;
  private TileType[][][] mapTiles; // [xBlock][yBlock][tileNumber] = tileType

  private int mapSize; // the max bounds of the map
  private int numberOfBlocks; // the number of Blocks that the map will contain

  // where the map generartion will start
  private int generationOriginX;
  private int generationOriginY;

  private int[] xSpawnPoints;
  private int[] ySpawnPoints;
  private int playerSpawnPointIterator;
  private int spawnpointDelay;
  private int nextSpawnPoint;

  private int tilePixelSize = 16;
  
  // Block = 10 x 8 tiles
  private int blockTileSizeX = 10; 
  private int blockTileSizeY = 8;
 
  private int blockPixelSizeX = blockTileSizeX*tilePixelSize;
  private int blockPixelSizeY = blockTileSizeY*tilePixelSize;
  
  private ArrayList<GameObject> sawsList;  
  private ArrayList<GameObject> sawsTrailsList;
  
  private float miniMapBlockSize = 60;
  private int minBlockX = -1;
  private int minBlockY = -1;
  private int maxBlockX = -1;
  private int maxBlockY = -1;
  
  private float miniMapTranslatePositionX;
  private float miniMapTranslatePositionY;
  
  private boolean fogOfWar = false;
  private boolean[][] visitedBlocks;
  
  private int brokeProbability = 50;
  
  public boolean lowPerf = false;
  
  public MapManager(){
     
  }
  // constructor, the size of the map depends of the number of players
  MapManager(int playerNumber, String mapModel) {
    if (playerNumber < 4) {
      mapSize = 6;
      numberOfBlocks = 7;
    } else if (playerNumber < 8) {
      mapSize = 10;
      numberOfBlocks = 20;
    } else {
      mapSize = 15;
      numberOfBlocks = 30;
    }

    mapBlocks = new byte[mapSize][mapSize];
    selectedBlocks = new int[mapSize][mapSize];
    mapBlocksGameObjects = new GameObject[mapSize][mapSize];
    mapTiles = new TileType[mapSize][mapSize][blockTileSizeX*blockTileSizeY];
    xSpawnPoints = new int[playerNumber];
    ySpawnPoints = new int[playerNumber];
    
    if(fogOfWar){
      visitedBlocks = new boolean[mapSize][mapSize];
      for(int i=0 ; i<mapSize ; i++){
        for(int j=0 ; j<mapSize ; j++){
          visitedBlocks[i][j] = false;
        } 
      }
    }

    sawsList = new ArrayList<GameObject>();
    sawsTrailsList = new ArrayList<GameObject>();
    
    playerSpawnPointIterator = 0;
    spawnpointDelay = numberOfBlocks / playerNumber;
    nextSpawnPoint = numberOfBlocks;
    

    
    if(Network.isServer){
      MapGeneration();
    } else{
      GenerateMapFromModel(mapModel);
    }
    
      
    if(Network.isServer){
      writeMapOnServer(playerNumber); 
      writeSelectedBlocksOnServer();
      writeSpawnPositionsOnServer();
      CreateMap();
    }

    


  }

  public void MapGeneration() {
    // initialization, get a empty map
    for (int i=0; i<mapSize; i++) {
      for (int j=0; j<mapSize; j++) {
        mapBlocks[i][j] = 0;
      }
    }

    generationOriginX = mapSize/2;
    generationOriginY = mapSize/2;

    while (numberOfBlocks>0) {
      if (mapBlocks[generationOriginX][generationOriginY] != 15 && canHaveNewNeighbor(generationOriginX, generationOriginY)) { // 15 = (0000 1111)2 if the origin of map generation doesn't already have 4 neighbors
        createBlock(generationOriginX, generationOriginY);
      }

      // else, we have to change the origin 
      else {
        if (generationOriginX<mapSize-1) generationOriginX++;
        else if (generationOriginY<mapSize-1) generationOriginY++;
        else {
          numberOfBlocks=0; // critical case
          println("WARNING : map generator can't generate the required number of Blocks");
        }
      }
    }
    
    BreakWalls();
    
    DefineTilesForAllBlock();
    //DefineMiniMapSize();
  }
  
  public boolean canHaveNewNeighbor(int x, int y){
    return( (x > 0 && mapBlocks[x-1][y] == 0) || (y > 0 && mapBlocks[x][y-1] == 0) || (x+1 < mapSize && mapBlocks[x+1][y] == 0) || (y+1 < mapSize && mapBlocks[x][y+1] == 0) ); 
  }

  public void createBlock(int x, int y) {

    // Spawn point creation:
    if (numberOfBlocks == nextSpawnPoint && playerSpawnPointIterator<xSpawnPoints.length) {
      nextSpawnPoint = nextSpawnPoint - spawnpointDelay;
      xSpawnPoints[playerSpawnPointIterator] = x;
      ySpawnPoints[playerSpawnPointIterator] = y;
      playerSpawnPointIterator++;
    }

    // Neighbor creation :
    int neighborNumber = (int)random(1, 5); // random number to define how many neighbors the Blocks have
    for (int i=0; i<neighborNumber; i++) {
      int neighborSelected = (int)random(0, 4); // the type of neighbor is also random, 0 = left, 1 = up, 2 = right, 3 = down;

      if (numberOfBlocks>0) {
        switch(neighborSelected) {

        case 0 : 
          if (x>0 && mapBlocks[x-1][y]==0) { // check if the neighbor is in the bounds of the map
            numberOfBlocks--;
            mapBlocks[x][y]|=(1<<3); // update fourth bit of the Block to indicate that it has a left neighbor 
            mapBlocks[x-1][y]=(1<<1); // update second bit of the new neighbor Block to indicate that the left neighbor has a right neighbor
            createBlock(x-1, y); // continue the generation in that neighbor (recursive call)
          }    
          break;

        case 1 : 
          if (y>0 && mapBlocks[x][y-1]==0) {
            numberOfBlocks--;
            mapBlocks[x][y]|=(1<<2);
            mapBlocks[x][y-1]=1;
            createBlock(x, y-1);
          }
          break;

        case 2 : 
          if (x+1<mapSize && mapBlocks[x+1][y]==0) {
            numberOfBlocks--;
            mapBlocks[x][y]|=(1<<1);
            mapBlocks[x+1][y]=(1<<3);
            createBlock(x+1, y);
          }
          break;

        case 3 : 
          if (y+1<mapSize && mapBlocks[x][y+1]==0) {
            numberOfBlocks--;
            mapBlocks[x][y]|=1;
            mapBlocks[x][y+1]=(1<<2);
            createBlock(x, y+1);
          }
          break;
        }
      }
    }
  }

  private void BreakWalls(){
    
    // Determine the numbers of breakable walls on the generated map
    int breakableWalls = 0;
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
        if(mapBlocks[i][j] != 0){
          if((i+1) < mapSize && mapBlocks[i+1][j]!=0 && !HaveNeighborInDirection(i, j, Direction.Right)) breakableWalls++;
          if((j+1) < mapSize && mapBlocks[i][j+1]!=0 && !HaveNeighborInDirection(i, j, Direction.Down)) breakableWalls++;
        }
      }
    }
    
    // We will break a percent of these walls to aerate the map
    breakableWalls /= 3;
    
    int brokenWalls = 0;
    
    while(brokenWalls < breakableWalls){

      int xBlock = (int)random(0, mapSize-2);
      int yBlock = (int)random(0, mapSize-2);
      boolean broke = false;
      
      while(!broke && xBlock < mapSize){
         while(!broke && yBlock < mapSize){
           
           if(mapBlocks[xBlock][yBlock] != 0){
             if((xBlock-1)>0 && mapBlocks[xBlock-1][yBlock]!=0 && !HaveNeighborInDirection(xBlock, yBlock, Direction.Left)){
               if(random(0,100) > brokeProbability){
                 mapBlocks[xBlock][yBlock]|=(1<<3); // update fourth bit of the Block to indicate that it has a left neighbor 
                 mapBlocks[xBlock-1][yBlock]|=(1<<1); // update second bit of the left neighbor to indicate that it has a right neighbor
                 broke = true;
                 brokenWalls++;
               }
             }
             
             if((yBlock-1) > 0 && mapBlocks[xBlock][yBlock-1]!=0 && !HaveNeighborInDirection(xBlock, yBlock, Direction.Up)){
               if(random(0,100) > brokeProbability){
                 mapBlocks[xBlock][yBlock]|=(1<<2); // update third bit of the Block to indicate that it has a up neighbor 
                 mapBlocks[xBlock][yBlock-1]|=1; // update first bit of the up neighbor to indicate that it has a down neighbor
                 broke = true;
                 brokenWalls++;
               }
             }
             
             if((xBlock+1) < mapSize && mapBlocks[xBlock+1][yBlock]!=0 && !HaveNeighborInDirection(xBlock, yBlock, Direction.Right)){
               if(random(0,100) > brokeProbability){
                 mapBlocks[xBlock][yBlock]|=(1<<1); // update second bit of the Block to indicate that it has a right neighbor 
                 mapBlocks[xBlock+1][yBlock]|=(1<<3); // update fourth bit of the right neighbor to indicate that it has a left neighbor
                 broke = true;
                 brokenWalls++;
               }
             }
             
             if((yBlock+1)<mapSize && mapBlocks[xBlock][yBlock+1]!=0 && !HaveNeighborInDirection(xBlock, yBlock, Direction.Down)){
               if(random(0,100) > brokeProbability){
                 mapBlocks[xBlock][yBlock]|=1; // update first bit of the Block to indicate that it has a down neihbor
                 mapBlocks[xBlock][yBlock+1]|=(1<<2); // update third bit of the down neighbor to indicate that it has a up neighbor
                 broke = true;
                 brokenWalls++;
               }
               
             }
           }
           
           yBlock++;
         }
         
         xBlock++;
      } 
       
    }
  }

  public int GetSpawnIndexX() {
    return xSpawnPoints[0];
  }

  public int GetSpawnIndexY() {
    return ySpawnPoints[0];
  }

  public PVector GetSpawnPosition() {

    // TODO : manage returned spawn position index
    return(new PVector(xSpawnPoints[0]*blockPixelSizeX+ blockPixelSizeX, ySpawnPoints[0]*blockPixelSizeY + blockPixelSizeY/2));
  }

  public void DrawMiniMap(int playerPositionX, int playerPositionY) {
    
    pushMatrix();
    translate(miniMapTranslatePositionX, miniMapTranslatePositionY);
    
    stroke(255);
    for (int i=0; i<mapSize; i++) {
      for (int j=0; j<mapSize; j++) {
        if (mapBlocks[i][j]>0) {
          if(!fogOfWar || visitedBlocks[i][j]){ 
            fill(255);
  
            if (i==playerPositionX && j==playerPositionY) fill(255, 0, 0); // just to indicate where the player is
            rect(30+miniMapBlockSize*i, 20+miniMapBlockSize*j, miniMapBlockSize, miniMapBlockSize);
            fill(0);
            text(mapBlocks[i][j], 50+miniMapBlockSize*i, 55+miniMapBlockSize*j);
            //text(i+" "+j, 50+60*i, 55+60*j);
          }
        }
      }
    }


    // this code will draw the borders of each Blocks, no border = link door, border = wall
    strokeWeight(3);
    stroke(122);
    for (int i=0; i<mapSize; i++) {
      for (int j=0; j<mapSize; j++) {
        if (mapBlocks[i][j]>0) {
          if(!fogOfWar || visitedBlocks[i][j]){ 

            // bottom border
            if ((mapBlocks[i][j] & 1)==0) { 
              line(30+miniMapBlockSize*i, 20+miniMapBlockSize*j+miniMapBlockSize, 30+miniMapBlockSize*i+miniMapBlockSize, 20+miniMapBlockSize*j+miniMapBlockSize);
            }
  
            // right border
            if ((mapBlocks[i][j] & (1<<1))==0) {
              line(30+miniMapBlockSize*i+miniMapBlockSize, 20+miniMapBlockSize*j, 30+miniMapBlockSize*i+miniMapBlockSize, 20+miniMapBlockSize*j+miniMapBlockSize);
            }
  
            // above border
            if ((mapBlocks[i][j] & (1<<2))==0) {
              line(30+miniMapBlockSize*i, 20+miniMapBlockSize*j, 30+miniMapBlockSize*i+miniMapBlockSize, 20+miniMapBlockSize*j);
            }
  
            // left border
            if ((mapBlocks[i][j] & (1<<3))==0) {
              line(30+miniMapBlockSize*i, 20+miniMapBlockSize*j, 30+miniMapBlockSize*i, 20+miniMapBlockSize*j+miniMapBlockSize);
            }
          }
        }
      }
    }
    
    popMatrix();
    strokeWeight(1); // Important to reset strokeWeight
  }

  // Tile = 16x16 pixels 
  public void DrawTile(int posX, int posY, TileType type) {
    switch(type) {
    case Closed :     
      fill(0, 0, 255);
      break;

    case Opened : 
      fill(255, 0, 0);
      break;
    } 

    //fill(0,0,255);
    rect(posX, posY, tilePixelSize, tilePixelSize);
  }

  // Block = 8x8 tiles
  public void DrawBlock(int xBlock, int yBlock) {
    for (int i=0; i<blockTileSizeY; i++) {
      for (int j=0; j<blockTileSizeX; j++) {
        DrawTile((xBlock*blockPixelSizeX + (i+4)*tilePixelSize), (yBlock*blockPixelSizeY + j*tilePixelSize), mapTiles[xBlock][yBlock][(i*blockTileSizeX)+j]);
      }
    }
  }

  // OBSOLETE METHOD
  public void DrawMap(int xCurrentBlock, int yCurrentBlock) {

    if (xCurrentBlock < 0 || xCurrentBlock >= mapSize || yCurrentBlock < 0 || yCurrentBlock >= mapSize) {
      //println("ERROR ERROR - Character out of map bounds !");
      return;
    }

    if (mapBlocks[xCurrentBlock][yCurrentBlock]==0) {
      //println("ERROR ERROR - Character in null/empty block !");
      return;
    }

    println("Player is in " + xCurrentBlock + " " + yCurrentBlock);

    DrawBlock(xCurrentBlock, yCurrentBlock);

    // Such the player is in (xCurrentBlock, yCurrentBlock) block, we have to draw the neighbors blocks to manage camera scrool
    // Doors inside current block are used to know which neighbors we have to draw

    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Left)) DrawBlock(xCurrentBlock-1, yCurrentBlock);
    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Up)) DrawBlock(xCurrentBlock, yCurrentBlock-1);
    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Right)) DrawBlock(xCurrentBlock+1, yCurrentBlock);
    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Down)) DrawBlock(xCurrentBlock, yCurrentBlock+1);
  }

  public boolean HaveNeighborInDirection(int abscissa, int ordinate, Direction dir) {

    if (abscissa < 0 || abscissa >= mapSize || ordinate < 0 || ordinate >= mapSize) return false;
    switch(dir) {
    case Left :
      return((mapBlocks[abscissa][ordinate] & (1<<3))==8);
    case Up :
      return((mapBlocks[abscissa][ordinate] & (1<<2))==4);
    case Right :
      return((mapBlocks[abscissa][ordinate] & (1<<1))==2);
    case Down :
      return((mapBlocks[abscissa][ordinate] & 1)==1);
    }

    return false;
  }

  public void UpdateMap(int xCurrentBlock, int yCurrentBlock, int xPreviousBlock, int yPreviousBlock) {
    if (xCurrentBlock < 0 || xCurrentBlock >= mapSize || yCurrentBlock < 0 || yCurrentBlock >= mapSize) {
      //println("ERROR ERROR - Character out of map bounds !");
      return;
    }

    if (mapBlocks[xCurrentBlock][yCurrentBlock]==0) {
      //println("ERROR ERROR - Character in null/empty block !");
      return;
    }

    if(fogOfWar){
      visitedBlocks[xCurrentBlock][yCurrentBlock] = true; 
    }
    // TODO : optimization please

    if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Left)) {
      mapBlocksGameObjects[xPreviousBlock-1][yPreviousBlock].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock-1, yPreviousBlock, Direction.Up)) mapBlocksGameObjects[xPreviousBlock-1][yPreviousBlock-1].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock-1, yPreviousBlock, Direction.Down)) mapBlocksGameObjects[xPreviousBlock-1][yPreviousBlock+1].setActive(false);
    }

    if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Up)) {
      mapBlocksGameObjects[xPreviousBlock][yPreviousBlock-1].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock-1, Direction.Left)) mapBlocksGameObjects[xPreviousBlock-1][yPreviousBlock-1].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock-1, Direction.Right)) mapBlocksGameObjects[xPreviousBlock+1][yPreviousBlock-1].setActive(false);
    }
    if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Right)) {
      mapBlocksGameObjects[xPreviousBlock+1][yPreviousBlock].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock+1, yPreviousBlock, Direction.Up)) mapBlocksGameObjects[xPreviousBlock+1][yPreviousBlock-1].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock+1, yPreviousBlock, Direction.Down)) mapBlocksGameObjects[xPreviousBlock+1][yPreviousBlock+1].setActive(false);
    }
    if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock, Direction.Down)) {
      mapBlocksGameObjects[xPreviousBlock][yPreviousBlock+1].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock+1, Direction.Left)) mapBlocksGameObjects[xPreviousBlock-1][yPreviousBlock+1].setActive(false);
      if (HaveNeighborInDirection(xPreviousBlock, yPreviousBlock+1, Direction.Right)) mapBlocksGameObjects[xPreviousBlock+1][yPreviousBlock+1].setActive(false);
    }

    mapBlocksGameObjects[xCurrentBlock][yCurrentBlock].setActive(true);

    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Left)) {
      mapBlocksGameObjects[xCurrentBlock-1][yCurrentBlock].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock-1, yCurrentBlock, Direction.Up)) mapBlocksGameObjects[xCurrentBlock-1][yCurrentBlock-1].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock-1, yCurrentBlock, Direction.Down)) mapBlocksGameObjects[xCurrentBlock-1][yCurrentBlock+1].setActive(true);
    }
    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Up)) {
      mapBlocksGameObjects[xCurrentBlock][yCurrentBlock-1].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock-1, Direction.Left)) mapBlocksGameObjects[xCurrentBlock-1][yCurrentBlock-1].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock-1, Direction.Right)) mapBlocksGameObjects[xCurrentBlock+1][yCurrentBlock-1].setActive(true);
    }
    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Right)) {
      mapBlocksGameObjects[xCurrentBlock+1][yCurrentBlock].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock+1, yCurrentBlock, Direction.Up)) mapBlocksGameObjects[xCurrentBlock+1][yCurrentBlock-1].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock+1, yCurrentBlock, Direction.Down)) mapBlocksGameObjects[xCurrentBlock+1][yCurrentBlock+1].setActive(true);
    }
    if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock, Direction.Down)) {
      mapBlocksGameObjects[xCurrentBlock][yCurrentBlock+1].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock+1, Direction.Left)) mapBlocksGameObjects[xCurrentBlock-1][yCurrentBlock+1].setActive(true);
      if (HaveNeighborInDirection(xCurrentBlock, yCurrentBlock+1, Direction.Right)) mapBlocksGameObjects[xCurrentBlock+1][yCurrentBlock+1].setActive(true);
    }
  }
  
  public boolean BlockOutOfMap(int xBlock, int yBlock){
    return(xBlock < 0 || xBlock >= mapSize || yBlock < 0 || yBlock >= mapSize || mapBlocks[xBlock][yBlock]==0);
  }

  public void DefineTilesForAllBlock() {

    int debug = 0;
    for (int i=0; i<mapSize; i++) {
      for (int j=0; j<mapSize; j++) {
        if (mapBlocks[i][j] != 0) {
          
          String folderPath = "";

          if ((mapBlocks[i][j] & (1<<3))==8) folderPath += '1';
          else folderPath += '0';

          if ((mapBlocks[i][j] & (1<<2))==4) folderPath += '1';
          else folderPath += '0';

          if ((mapBlocks[i][j] & (1<<1))==2) folderPath += '1';
          else folderPath += '0';

          if ((mapBlocks[i][j] & 1)==1) folderPath += '1';
          else folderPath += '0';

          folderPath = "Blocks/" + folderPath;

          String path = sketchPath + "/data" + "/" + folderPath; 

          File dataFolder = new File(path); 
          
          int choosenBlock;
          
          if(Network.isServer){
            int numberOfBlocksPossibilities = dataFolder.list().length-1; // -1 to not take the Void.txt file, which represent an empty template used to create new blocks
            choosenBlock = (int)random(0, numberOfBlocksPossibilities);
            selectedBlocks[i][j] = choosenBlock;
          }
          
          else choosenBlock =  selectedBlocks[i][j];
          
          
          //choosenBlock = numberOfBlocksPossibilities-1; // WARNING : line of code used to facilitate tests of level design, don't forget to comment this
          
          folderPath += "/"; // WARNING : this line must be done before the loadStrings

          String[] data=loadStrings(folderPath + char(choosenBlock+48) + ".txt");

          for (int k=0; k<blockTileSizeY; k++) {
            for (int l=0; l<blockTileSizeX; l++) {
              int tileType = 10*(data[k].charAt(3*l)-48) + (data[k].charAt((3*l)+1))-48;
              mapTiles[i][j][k*blockTileSizeX + l] = TileType.fromInteger(tileType); // WARNING : Do not forget to define new values in TileType.java
            }
          }

        }
      }
    }
  }



  public void CreateMap() {

    for (int i=0; i<mapSize; i++) {
      for (int j=0; j<mapSize; j++) {
        if (mapBlocks[i][j]!=0) {
          CreateBlock(i, j);
        }
      }
    }
  }

  // Block = 8x8 tiles
  public void CreateBlock(int xBlock, int yBlock) {

    mapBlocksGameObjects[xBlock][yBlock] = new GameObject("Block"+str(xBlock)+str(yBlock), new PVector(0, 0));
    for (int i=0; i<blockTileSizeY; i++) {
      for (int j=0; j<blockTileSizeX; j++) {
        CreateTile((xBlock*blockPixelSizeX + (j+4)*tilePixelSize), (yBlock*blockPixelSizeY + i*tilePixelSize), mapTiles[xBlock][yBlock][(i*blockTileSizeX)+j], mapBlocksGameObjects[xBlock][yBlock]);
      }
    }

    mapBlocksGameObjects[xBlock][yBlock].setActive(false);
    
    
    for(int i=0 ; i<sawsTrailsList.size() ; i++){
      sawsTrailsList.get(i).addComponent(new SawTrail()); 
      ((SawTrail)(sawsTrailsList.get(i).getComponent(SawTrail.class))).init(sawsTrailsList, tilePixelSize); 
    }
    
    sawsTrailsList.clear();
    
    
  }

  // Tile = 16x16 pixels 
  public void CreateTile(int posX, int posY, TileType type, GameObject blockGameObject) {
    
    if (type != TileType.Empty) {
      GameObject tile = new GameObject("tile" + str(posX)+str(posY), new PVector(posX, posY), blockGameObject);
      tile.isTile = true;

      switch(type) {

      case Opened :  
        //tile.addComponent(new Sprite(tilesSpriteSheet, 17,15));
        if(!lowPerf) tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        break;

      case Closed :     
        tile.addComponent(new Collider(new Rect(0, 0, tilePixelSize, tilePixelSize)));
        //((Collider)(tile.getComponent(Collider.class))).isTrigger = true;
        //tile.addComponent(new Sprite(tilesSpriteSheet, 1,0));
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "wall.png"));
        break;

      case EmptyPot :
        GameObject emptyPot = new GameObject("emptyPot", new PVector(0, 0 ), tile);
        emptyPot.isChildTile = true;
        emptyPot.addComponent(new Sprite(mapTilesSpriteSheetPath + "pot.png"));
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        
        emptyPot.addComponent(new Collider(new Rect(0, 2, tilePixelSize-4, tilePixelSize-2)));
        ((Collider)(emptyPot.getComponent(Collider.class))).passablePlatform = true;
        
        break;

      case FirePot :

        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

        GameObject fireBackground = new GameObject("fireBackground", new PVector(0, -tilePixelSize), tile);
        fireBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        fireBackground.isChildTile = true;

        GameObject firePot = new GameObject("firePot", new PVector(0, -8 ), tile);
        firePot.isChildTile = true;

        Parameters fireParameters = new Parameters();
        State fireState =  new State(new Animation(torchSpriteSheet, 0, true), 9);
        AnimatorController fireAnimator = new AnimatorController(fireState, fireParameters);

        firePot.addComponent(fireAnimator);

        break;

      case FlowerPot :
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

        GameObject flowerBackground = new GameObject("flowerBackground", new PVector(0, -tilePixelSize), tile);
        flowerBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        flowerBackground.isChildTile = true;

        GameObject flowerPot = new GameObject("flowerPot", new PVector(0, -8 ), tile);
        flowerPot.isChildTile = true;
        flowerPot.addComponent(new Sprite(mapTilesSpriteSheetPath + "flowerPot.png"));
        
        // TODO : change sprite with crushed flowers when someone walk on them
        tile.addComponent(new Collider(new Rect(0, 2, tilePixelSize-4, tilePixelSize-2)));
        ((Collider)(tile.getComponent(Collider.class))).passablePlatform = true;
        
        break;

      case Bookcase :
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

        GameObject bookcaseBackground = new GameObject("bookcaseBackground", new PVector(0, -tilePixelSize), tile);
        bookcaseBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        bookcaseBackground.isChildTile = true;
        
        GameObject bookcaseBackground2 = new GameObject("bookcaseBackground2", new PVector(tilePixelSize, 0), tile);
        bookcaseBackground2.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        bookcaseBackground2.isChildTile = true;

        GameObject bookcaseBackground3 = new GameObject("bookcaseBackground3", new PVector(tilePixelSize, -tilePixelSize), tile);
        bookcaseBackground3.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        bookcaseBackground3.isChildTile = true;

        GameObject bookcase = new GameObject("bookcase", new PVector(8, -8 ), tile);
        bookcase.isChildTile = true;
        bookcase.addComponent(new Sprite(mapTilesSpriteSheetPath + "bookcase.png"));
        
        bookcase.addComponent(new Collider(new Rect(0, 0, 28, 32)));
        ((Collider)(bookcase.getComponent(Collider.class))).passablePlatform = true;
        
        break;

      case Chest :
      
        GameObject chest = new GameObject("chest", new PVector(0, 4), tile);
        chest.isChildTile = true;
        chest.addComponent(new Sprite(mapTilesSpriteSheetPath + "chest.png"));
        chest.addComponent(new Chest());
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        
        chest.addComponent(new Collider(new Rect(0, 4, 8, 16)));
        ((Collider)chest.getComponent(Collider.class)).layer = CollisionLayer.CharacterBody;
        ((Collider)chest.getComponent(Collider.class)).layerManagement = LayerManagement.OnlyMyLayer;
        ((Collider)(chest.getComponent(Collider.class))).passablePlatform = true;

        break;

      case Lava :
        //tile.addComponent(new Sprite(tilesSpriteSheet, 15, 15));
        
        State lavaState =  new State(new Animation(lavaSpriteSheet, 0, true), 6);
        AnimatorController lavaAnimator = new AnimatorController(lavaState, new Parameters());
        
        GameObject lava = new GameObject("lava", new PVector(0, 0), tile);
        lava.isChildTile = true;
        lava.addComponent(lavaAnimator);
        
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));     
        tile.addComponent(new DamageCollider(new Rect(0, 1, tilePixelSize, tilePixelSize-2), 1));
        break;
        
      case PlatformLeft :     
      
        GameObject platformLeft = new GameObject("platformLeft", new PVector(0, 0), tile);
        platformLeft.isChildTile = true;
        platformLeft.addComponent(new Collider(new Rect(0, -6, tilePixelSize, 4)));
        ((Collider)(platformLeft.getComponent(Collider.class))).passablePlatform = true;
        platformLeft.addComponent(new Sprite(mapTilesSpriteSheetPath + "platformLeft.png"));
        
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));     

        
        break;   
              
      case PlatformMid :     
        
        GameObject platformMid = new GameObject("platformMid", new PVector(0, 0), tile);
        platformMid.isChildTile = true;
        platformMid.addComponent(new Collider(new Rect(0, -6, tilePixelSize, 4)));
        ((Collider)(platformMid.getComponent(Collider.class))).passablePlatform = true;
        //((Collider)(platformMid.getComponent(Collider.class))).forceDebugDraw = true;
        platformMid.addComponent(new Sprite(mapTilesSpriteSheetPath + "platformMid.png"));
        
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));    
        
        break;  
        
                
      case PlatformRight :     
        
        GameObject platformRight = new GameObject("platformRight", new PVector(0, 0), tile);
        platformRight.isChildTile = true;
        platformRight.addComponent(new Collider(new Rect(0, -6, tilePixelSize, 4)));
        ((Collider)(platformRight.getComponent(Collider.class))).passablePlatform = true;
        platformRight.addComponent(new Sprite(mapTilesSpriteSheetPath + "platformRight.png"));
        
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));    
        
        break;  
        
      case Canvas :
        
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

        GameObject canvasBackground = new GameObject("canvasBackground", new PVector(0, -tilePixelSize), tile);
        canvasBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        canvasBackground.isChildTile = true;
        
        GameObject canvasBackground2 = new GameObject("canvasBackground2", new PVector(tilePixelSize, 0), tile);
        canvasBackground2.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        canvasBackground2.isChildTile = true;

        GameObject canvasBackground3 = new GameObject("canvasBackground3", new PVector(tilePixelSize, -tilePixelSize), tile);
        canvasBackground3.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
        canvasBackground3.isChildTile = true;

        GameObject canvas = new GameObject("canvas", new PVector(tilePixelSize/2, -5), tile);
        canvas.isChildTile = true;
        canvas.addComponent(new Sprite(mapTilesSpriteSheetPath + "canvas.png", 0.66f));        
                
        break;
        
      case Saw :
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));    
        
        GameObject sawTrailForSaw = new GameObject("sawTrailForSaw" + str(posX)+str(posY), tile.position, blockGameObject);
        sawsTrailsList.add(sawTrailForSaw);
        
        GameObject saw = new GameObject("saw" + str(posX)+str(posY), tile.position);
        saw.addComponent(new Saw(sawTrailForSaw));
        
        sawsList.add(saw);
        
        State sawState =  new State(new Animation(sawSpriteSheet, 0, true), 12);
        sawState.setScale(0.25f, 0.25f);
        AnimatorController sawAnimator = new AnimatorController(sawState, new Parameters());
        
        saw.addComponent(sawAnimator);
        
        ((Saw)saw.getComponent(Saw.class)).setBlockLocation(blockGameObject);

           
        //saw.addComponent(new DamageCollider(new Rect(0, 1, tilePixelSize, tilePixelSize-2), 1));
       
        break;
        
      case SawTrail :
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png")); 
        
        GameObject sawTrail = new GameObject("sawTrail" + str(posX)+str(posY), tile.position, blockGameObject);
        sawsTrailsList.add(sawTrail);
        
        break;
      
      case Chair :
          tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

          GameObject chairBackground = new GameObject("chairBackground", new PVector(0, -tilePixelSize), tile);
          chairBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
          chairBackground.isChildTile = true;
  
          GameObject chair = new GameObject("chair", new PVector(0, -4 ), tile);
          chair.isChildTile = true;
          chair.addComponent(new Sprite(mapTilesSpriteSheetPath + "chair.png"));
          ((Sprite)(chair.getComponent(Sprite.class))).setScale(0.8f);
          
          tile.addComponent(new Collider(new Rect(0, 6, tilePixelSize-4, tilePixelSize-2)));
          ((Collider)(tile.getComponent(Collider.class))).passablePlatform = true;
        break;
      
      case Couch :
      
          tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

          GameObject couchBackground = new GameObject("couchBackground", new PVector(tilePixelSize, 0), tile);
          couchBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
          couchBackground.isChildTile = true;
          
          GameObject couchBackground2 = new GameObject("couchBackground2", new PVector(2*tilePixelSize, 0), tile);
          couchBackground2.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
          couchBackground2.isChildTile = true;
          
          couchBackground2.addComponent(new Collider(new Rect(-14, 0, (tilePixelSize/2)+4, tilePixelSize)));
          ((Collider)(couchBackground2.getComponent(Collider.class))).passablePlatform = true;
  
          GameObject couch = new GameObject("couch", new PVector((tilePixelSize/2)+2, 0), tile);
          couch.isChildTile = true;
          couch.addComponent(new Sprite(mapTilesSpriteSheetPath + "couch.png"));
          ((Sprite)(couch.getComponent(Sprite.class))).setScale(0.5f);
          
          tile.addComponent(new Collider(new Rect(7, 4, 22, 4)));
          ((Collider)(tile.getComponent(Collider.class))).passablePlatform = true;
        break;
      
      case Furniture :
      
          tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

          GameObject furnitureBackground = new GameObject("furnitureBackground", new PVector(tilePixelSize, 0), tile);
          furnitureBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
          furnitureBackground.isChildTile = true;
          
          GameObject furnitureBackground2 = new GameObject("furnitureBackground2", new PVector(2*tilePixelSize, 0), tile);
          furnitureBackground2.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
          furnitureBackground2.isChildTile = true;
  
          GameObject furniture = new GameObject("furniture", new PVector(12, 0), tile);
          furniture.isChildTile = true;
          furniture.addComponent(new Sprite(mapTilesSpriteSheetPath + "furniture.png"));
          ((Sprite)(furniture.getComponent(Sprite.class))).setScale(0.8f);
          
          tile.addComponent(new Collider(new Rect(12, 0, 32, 16)));
          ((Collider)(tile.getComponent(Collider.class))).passablePlatform = true;
        break;
      
      case Statue :
      
          tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));

          GameObject statueBackground = new GameObject("statueBackground", new PVector(tilePixelSize, 0), tile);
          statueBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
          statueBackground.isChildTile = true;
  
          GameObject statue = new GameObject("statue", new PVector(8, 0), tile);
          statue.isChildTile = true;
          statue.addComponent(new Sprite(mapTilesSpriteSheetPath + "statue.png"));
          
          tile.addComponent(new Collider(new Rect(8, 0, 32, 16)));
          ((Collider)(tile.getComponent(Collider.class))).passablePlatform = true;
        break; 
      
      case Vase :
      
          tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
  
          GameObject vaseBackground = new GameObject("vaseBackground", new PVector(0, -tilePixelSize), tile);
          vaseBackground.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
          vaseBackground.isChildTile = true;
  
          GameObject vase = new GameObject("flowerPot", new PVector(0, -4 ), tile);
          vase.isChildTile = true;
          vase.addComponent(new Sprite(mapTilesSpriteSheetPath + "vase.png"));
          ((Sprite)(vase.getComponent(Sprite.class))).setScale(0.8f);
          
          // TODO : change sprite with crushed flowers when someone walk on them
          tile.addComponent(new Collider(new Rect(0, 3, tilePixelSize-8, tilePixelSize-2)));
          ((Collider)(tile.getComponent(Collider.class))).passablePlatform = true;
        break;
      
      case UpSpikes :
      
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
              
        GameObject upSpikes = new GameObject("upSpikes", new PVector(0, 4), tile);
        upSpikes.isChildTile = true;
        upSpikes.addComponent(new Sprite(mapTilesSpriteSheetPath + "horizontalSpikes.png"));
        ((Sprite)(upSpikes.getComponent(Sprite.class))).setScale(0.5f, 0.5f);
              
        tile.addComponent(new DamageCollider(new Rect(0, 4, (tilePixelSize - 3), (tilePixelSize/2 - 1)), 1));
        ((DamageCollider)(tile.getComponent(DamageCollider.class))).forceDebugDraw = true;
        
        break;
      
      case DownSpikes :
            
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
              
        GameObject downSpikes = new GameObject("upSpikes", new PVector(0, -4), tile);
        downSpikes.isChildTile = true;
        downSpikes.addComponent(new Sprite(mapTilesSpriteSheetPath + "horizontalSpikes.png"));
        ((Sprite)(downSpikes.getComponent(Sprite.class))).setScale(0.5f, -0.5f);
              
        tile.addComponent(new DamageCollider(new Rect(0, -4, (tilePixelSize - 3), (tilePixelSize/2 - 1)), 1));
        ((DamageCollider)(tile.getComponent(DamageCollider.class))).forceDebugDraw = true;
        
        break;
        
      case LeftSpikes :
            
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
              
        GameObject leftSpikes = new GameObject("leftSpikes", new PVector(4, 0), tile);
        leftSpikes.isChildTile = true;
        leftSpikes.addComponent(new Sprite(mapTilesSpriteSheetPath + "verticalSpikes.png"));
        ((Sprite)(leftSpikes.getComponent(Sprite.class))).setScale(-0.5f, 0.5f);
              
        tile.addComponent(new DamageCollider(new Rect(4, 0, (tilePixelSize/2 - 1), (tilePixelSize -3)), 1));
        ((DamageCollider)(tile.getComponent(DamageCollider.class))).forceDebugDraw = true;
        
        break;
           
      case RightSpikes :
            
        tile.addComponent(new Sprite(mapTilesSpriteSheetPath + "brick.png"));
              
        GameObject rightSpikes = new GameObject("leftSpikes", new PVector(-4, 0), tile);
        rightSpikes.isChildTile = true;
        rightSpikes.addComponent(new Sprite(mapTilesSpriteSheetPath + "verticalSpikes.png"));
        ((Sprite)(rightSpikes.getComponent(Sprite.class))).setScale(0.5f, 0.5f);
              
        tile.addComponent(new DamageCollider(new Rect(-4, 0, (tilePixelSize/2 - 1), (tilePixelSize -3)), 1));
        //((DamageCollider)(tile.getComponent(DamageCollider.class))).forceDebugDraw = true;
        
        break;
      
      
      }
    }
  }



  // Debug function
  public void PrintTilesFile(String textPath) {

    String[] data=loadStrings("Blocks/OneRightDoor/0.txt"); 

    for (int i=0; i<8; i++) {
      for (int j=0; j<8; j++) {
        print(data[i].charAt(3*j));
        print(data[i].charAt((3*j)+1));
        print(" ");
      }
      print("\n");
    }
  }

  public float GetBlockPixelSizeX() {
    return blockPixelSizeX;
  }
  
  public float GetBlockPixelSizeY() {
    return blockPixelSizeY;
  }
  
  public float GetTilePixelSize() {
    return tilePixelSize;
  }
  
  public void AddSawsToGoodDisplayLayer(){
    for(int i=0 ; i<sawsList.size() ; i++){
      sawsContainer.addChildren(sawsList.get(i)); 
      ((Saw)sawsList.get(i).getComponent(Saw.class)).init();
    } 
  }
  
  public void DefineMiniMapSize(){
    
    int absIterator = 0;
    int ordIterator = 0;
    
    while(minBlockX == -1 && absIterator<mapSize){
      ordIterator = 0;
      while(minBlockX == -1 && ordIterator<mapSize){
        if(mapBlocks[absIterator][ordIterator]>0){
          minBlockX = absIterator;
        }
        ordIterator++;
      }
      absIterator++;
    }
    
    
    absIterator = mapSize-1;
    
    
    while(maxBlockX == -1 && absIterator>=0){
      ordIterator = mapSize-1;
      while(maxBlockX == -1 && ordIterator>=0){
        if(mapBlocks[absIterator][ordIterator]>0){
          maxBlockX = absIterator;
        }
        ordIterator--;
      }
      absIterator--;
    }
    
        
    absIterator = 0;
    ordIterator = 0;

    while(minBlockY == -1 && ordIterator<mapSize){
      absIterator = 0;
      while(minBlockY == -1 && absIterator<mapSize){
        if(mapBlocks[absIterator][ordIterator]>0){
          minBlockY = ordIterator;
        }
        absIterator++;
      }
      ordIterator++;
    }    
    
    absIterator = mapSize-1;
    ordIterator = mapSize-1;
    
    while(maxBlockY == -1 && ordIterator>=0){
      absIterator = mapSize-1;
      while(maxBlockY == -1 && absIterator>=0){
        if(mapBlocks[absIterator][ordIterator]>0){
          maxBlockY = ordIterator;
        }
        absIterator--;
      }
      ordIterator--;
    }
    
    int mapWidth = maxBlockX + 1 - minBlockX;
    int mapHeight = maxBlockY + 1 -  minBlockY;
    
    
    float pixelResolutionStripSize = resolutionStripSize * globalScale;
    miniMapBlockSize = min(height/(2*mapHeight), (pixelResolutionStripSize-(pixelResolutionStripSize/8))/mapWidth);
    
    miniMapTranslatePositionX = -minBlockX*miniMapBlockSize;
    miniMapTranslatePositionY = height - ((mapHeight+minBlockY+2)*miniMapBlockSize);
    
  }
  
  public GameObject getCurrentBlock(){
    return mapBlocksGameObjects[xBlock][yBlock]; 
  }
  
  public void DebugPrintMap(){
    println("Print map :");
    for(int j=0 ; j<mapSize ; j++){
      for(int i=0 ; i<mapSize ; i++){
        if(mapBlocks[i][j] == 0) print("   ");
        else if(mapBlocks[i][j] < 10) print("0" + mapBlocks[i][j] + " ");
        else print(mapBlocks[i][j] + " ");
      }
      println("");
    } 
  }
  
  // TODO : use one method to remplace three methods used to write arrays on server (use argument)
  public void writeMapOnServer(int playerNumber){
    String mapComposition = "GeneratedMap " + playerNumber + " ";
    
    for(int j = 0 ; j<mapSize ; j++){
      for(int i = 0 ; i<mapSize ; i++){
        if(mapBlocks[i][j] == 0) mapComposition += "   ";
        else if(mapBlocks[i][j] < 10) mapComposition += "0" + mapBlocks[i][j] + " ";
        else mapComposition += mapBlocks[i][j] + " ";
      } 
      
      mapComposition += " \n";
    }
    
    Network.write(mapComposition+"endMessage");
  }
  
  public void writeSelectedBlocksOnServer(){
    
      String mapComposition = "SelectedBlocks ";
    
      for(int i = 0 ; i<mapSize ; i++){
        for(int j = 0 ; j<mapSize ; j++){
          if(selectedBlocks[i][j] == 0) mapComposition += "   ";
          else if(selectedBlocks[i][j] < 10) mapComposition += "0" + selectedBlocks[i][j] + " ";
          else mapComposition += selectedBlocks[i][j] + " ";
        } 
        
        mapComposition += " \n";
      }
      
      Network.write(mapComposition+"endMessage");
  }
 
 public void writeSpawnPositionsOnServer(){
     String mapComposition = "SpawnPositions ";
    
      for(int i = 0 ; i<xSpawnPoints.length ; i++){
        mapComposition += xSpawnPoints[i] + " " + ySpawnPoints[i] + " ";
      }
      
      Network.write(mapComposition+"endMessage");
 }
 
 public void CopySpawnPositionsFromModel(String dataString){
   int data[] = int(split(dataString, ' ')); // Split values into an array
   for(int i=0 ; i<data.length/2 ; i++){
     xSpawnPoints[i] = data[2*i];
     ySpawnPoints[i] = data[(2*i)+1];
   }  
 }
  
  private void GenerateMapFromModel(String mapModel){
    
    String[] mapLines = mapModel.split("\n",mapSize);
    for(int i=0 ; i<mapSize ; i++){
      println(mapLines[i]);
      for(int j=0 ; j<mapSize ; j++){
        
        //String blockValue = "";  
        int blockValue = 0;
        
        blockValue = 10 * Character.getNumericValue(mapLines[i].charAt(3*j));
        if(blockValue < 0) blockValue = 0;
        blockValue += Character.getNumericValue(mapLines[i].charAt((3*j)+1));
        if(blockValue < 0) blockValue = 0;
        
        /*
        if(mapLines[i].charAt(3*j) != ' ' && mapLines[i].charAt(3*j) != '0'){
          //blockValue += mapLines[i].charAt(3*j);
          blockValue = 10 * Character.getNumericValue(mapLines[i].charAt(3*j));
        }
        if(mapLines[i].charAt((3*j)+1) != ' ' && mapLines[i].charAt(3*j)){
          //blockValue += mapLines[i].charAt((3*j)+1);
          blockValue += Character.getNumericValue(mapLines[i].charAt((3*j)+1));
        } else {
          //blockValue = "0"; 
        }
        */
        
        println("blockValue = " + blockValue);
        //println("int blockValue = " + Integer.parseInt(blockValue));
        //mapBlocks[j][i] = (byte)(Integer.parseInt(blockValue));
        mapBlocks[j][i] = (byte)blockValue;
        println("byte blockValue = " + mapBlocks[j][i]);
      }
    }
    
    println("end of GenerateMapFromModel");
  }
  
  public void CopySelectedBlocksFromModel(String model){
    
    String[] mapLines = model.split("\n",mapSize);
    
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
        
          String blockValue = "";  
          
          if(mapLines[i].charAt(3*j) != ' '){
            blockValue += mapLines[i].charAt(3*j);
          }
          
          if(mapLines[i].charAt((3*j)+1) != ' '){
            blockValue += mapLines[i].charAt((3*j)+1);
          } else {
            blockValue = "0"; 
          }
          
          selectedBlocks[i][j] = (byte)(Integer.parseInt(blockValue));
      }
    }
  }

}

