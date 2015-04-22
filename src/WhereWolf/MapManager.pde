public class MapManager{
  
  private byte[][] mapTiles; // each tile is stocked as a byte, the four least significant bits defines the connections with neighboring tiles, the 4 most significant bits are for used to get the specific type of brick to use
  private int mapSize; // the max bounds of the map
  private int numberOfTiles; // the number of tiles that the map will contain
  
  // where the map generartion will start
  private int generationOriginX;
  private int generationOriginY;
  
  // constructor, the size of the map depends of the number of players
  MapManager(int playerNumber){
    if(playerNumber < 4) {
      mapSize = 6;
      numberOfTiles = 7;
    }
    else if(playerNumber < 8) {
      mapSize = 10;
      numberOfTiles = 20;
    }
    else {
      mapSize = 15;
      numberOfTiles = 30;
    }
    
    mapTiles = new byte[mapSize][mapSize];
    MapGeneration();
  }
  
  public void MapGeneration(){
   
    // initialization, get a empty map
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         mapTiles[i][j] = 0;
      }
    }
    
    generationOriginX = mapSize/2;
    generationOriginY = mapSize/2;
    
    while(numberOfTiles>0){
       if(mapTiles[generationOriginX][generationOriginY] != 15){ // 15 = (0000 1111)2 if the origin of map generation doesn't already have 4 neighbors
         createTile(generationOriginX, generationOriginY);
       }
       
       // else, we have to change the origin 
       else {
         if(generationOriginX<mapSize-1) generationOriginX++;
         else if(generationOriginY<mapSize-1) generationOriginY++;
         else {
           numberOfTiles=0; // critical case
           println("WARNING : map generator can't generate the required number of tiles"); 
         }
       }
    }

  }
  
  public void createTile(int x, int y){
    int neighborNumber = (int)random(1,5); // random number to define how many neighbors the tiles have
    for(int i=0 ; i<neighborNumber ; i++){
      int neighborSelected = (int)random(0,4); // the type of neighbor is also random, 0 = left, 1 = up, 2 = right, 3 = down;
      
      if(numberOfTiles>0){
        switch(neighborSelected){
        
          case 0 : if(x>0 && mapTiles[x-1][y]==0){ // check if the neighbor is in the bounds of the map
                    numberOfTiles--;
                    mapTiles[x][y]|=(1<<3); // update fourth bit of the tile to indicate that it has a left neighbor 
                    mapTiles[x-1][y]=(1<<1); // update first bit of the new neighbor tile to indicate that the neighbor has a right neighbor
                    createTile(x-1, y); // continue the generation in that neighbor (recursive call)
                    }    
          break;
          
          case 1 : if(y>0 && mapTiles[x][y-1]==0){
                      numberOfTiles--;
                      mapTiles[x][y]|=(1<<2);
                      mapTiles[x][y-1]=1;
                      createTile(x, y-1); 
                    }
          break;
          
          case 2 : if(x+1<mapSize && mapTiles[x+1][y]==0){
                      numberOfTiles--;
                      mapTiles[x][y]|=(1<<1);
                      mapTiles[x+1][y]=(1<<3);
                      createTile(x+1, y); 
                    }
          break;
          
          case 3 : if(y+1<mapSize && mapTiles[x][y+1]==0){
                      numberOfTiles--;
                      mapTiles[x][y]|=1;
                      mapTiles[x][y+1]=(1<<2);
                      createTile(x, y+1); 
                    }
          break;
        }
      }

    }
    
  }
  
  public void DrawMap(){
    
   stroke(255);
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         if(mapTiles[i][j]>0) {
           fill(255);
           
           if(i==mapSize/2 && j==mapSize/2) fill(255,0,0); // just to indicate which tile was using as origin
           rect(30+60*i, 20+60*j, 60, 60);
           fill(0);
           text(mapTiles[i][j], 50+60*i, 55+60*j);
         }
      }
    }
    
    
    // this code will draw the borders of each tiles, no border = link door, border = wall
    stroke(0);
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         if(mapTiles[i][j]>0) {

           if((mapTiles[i][j] & 1)==0) {
             line(30+60*i, 20+60*j+60, 30+60*i+60, 20+60*j+60);
           }
           
           if((mapTiles[i][j] & (1<<1))==0) {
             line(30+60*i+60, 20+60*j, 30+60*i+60, 20+60*j+60);
           }
           
           if((mapTiles[i][j] & (1<<2))==0) {
             line(30+60*i, 20+60*j, 30+60*i+60, 20+60*j);
           }
           
           if((mapTiles[i][j] & (1<<3))==0) {
             line(30+60*i, 20+60*j, 30+60*i, 20+60*j+60);
           }
         }
      }
    }
  }
  
}
