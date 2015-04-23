public class MapManager{
  
  private byte[][] mapBlocks; // each Block is stocked as a byte, the four least significant bits defines the connections with neighboring Blocks, the 4 most significant bits are for used to get the specific type of brick to use
  private int mapSize; // the max bounds of the map
  private int numberOfBlocks; // the number of Blocks that the map will contain
  
  // where the map generartion will start
  private int generationOriginX;
  private int generationOriginY;
  
  // constructor, the size of the map depends of the number of players
  MapManager(int playerNumber){
    if(playerNumber < 4) {
      mapSize = 6;
      numberOfBlocks = 7;
    }
    else if(playerNumber < 8) {
      mapSize = 10;
      numberOfBlocks = 20;
    }
    else {
      mapSize = 15;
      numberOfBlocks = 30;
    }
    
    mapBlocks = new byte[mapSize][mapSize];
    MapGeneration();
  }
  
  public void MapGeneration(){
   
    // initialization, get a empty map
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         mapBlocks[i][j] = 0;
      }
    }
    
    generationOriginX = mapSize/2;
    generationOriginY = mapSize/2;
    
    while(numberOfBlocks>0){
       if(mapBlocks[generationOriginX][generationOriginY] != 15){ // 15 = (0000 1111)2 if the origin of map generation doesn't already have 4 neighbors
         createBlock(generationOriginX, generationOriginY);
       }
       
       // else, we have to change the origin 
       else {
         if(generationOriginX<mapSize-1) generationOriginX++;
         else if(generationOriginY<mapSize-1) generationOriginY++;
         else {
           numberOfBlocks=0; // critical case
           println("WARNING : map generator can't generate the required number of Blocks"); 
         }
       }
    }

  }
  
  public void createBlock(int x, int y){
    int neighborNumber = (int)random(1,5); // random number to define how many neighbors the Blocks have
    for(int i=0 ; i<neighborNumber ; i++){
      int neighborSelected = (int)random(0,4); // the type of neighbor is also random, 0 = left, 1 = up, 2 = right, 3 = down;
      
      if(numberOfBlocks>0){
        switch(neighborSelected){
        
          case 0 : if(x>0 && mapBlocks[x-1][y]==0){ // check if the neighbor is in the bounds of the map
                    numberOfBlocks--;
                    mapBlocks[x][y]|=(1<<3); // update fourth bit of the Block to indicate that it has a left neighbor 
                    mapBlocks[x-1][y]=(1<<1); // update first bit of the new neighbor Block to indicate that the neighbor has a right neighbor
                    createBlock(x-1, y); // continue the generation in that neighbor (recursive call)
                    }    
          break;
          
          case 1 : if(y>0 && mapBlocks[x][y-1]==0){
                      numberOfBlocks--;
                      mapBlocks[x][y]|=(1<<2);
                      mapBlocks[x][y-1]=1;
                      createBlock(x, y-1); 
                    }
          break;
          
          case 2 : if(x+1<mapSize && mapBlocks[x+1][y]==0){
                      numberOfBlocks--;
                      mapBlocks[x][y]|=(1<<1);
                      mapBlocks[x+1][y]=(1<<3);
                      createBlock(x+1, y); 
                    }
          break;
          
          case 3 : if(y+1<mapSize && mapBlocks[x][y+1]==0){
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
  
  public void DrawMap(){
    
   stroke(255);
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         if(mapBlocks[i][j]>0) {
           fill(255);
           
           if(i==mapSize/2 && j==mapSize/2) fill(255,0,0); // just to indicate which Block was using as origin
           rect(30+60*i, 20+60*j, 60, 60);
           fill(0);
           text(mapBlocks[i][j], 50+60*i, 55+60*j);
         }
      }
    }
    
    
    // this code will draw the borders of each Blocks, no border = link door, border = wall
    stroke(0);
    for(int i=0 ; i<mapSize ; i++){
      for(int j=0 ; j<mapSize ; j++){
         if(mapBlocks[i][j]>0) {

           if((mapBlocks[i][j] & 1)==0) {
             line(30+60*i, 20+60*j+60, 30+60*i+60, 20+60*j+60);
           }
           
           if((mapBlocks[i][j] & (1<<1))==0) {
             line(30+60*i+60, 20+60*j, 30+60*i+60, 20+60*j+60);
           }
           
           if((mapBlocks[i][j] & (1<<2))==0) {
             line(30+60*i, 20+60*j, 30+60*i+60, 20+60*j);
           }
           
           if((mapBlocks[i][j] & (1<<3))==0) {
             line(30+60*i, 20+60*j, 30+60*i, 20+60*j+60);
           }
         }
      }
    }
  }
  
}
