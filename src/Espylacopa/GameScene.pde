Rect player;
Player newPlayer;

int xTile = 0;
int yTile = 0;

void initGame(){
  player = new Rect(100,100,64,128);
  newPlayer = new Player();
} 

void gameDraw(){
  
    // Matrix to manage the
    pushMatrix();
    translate(-xTile*width,-yTile*height);
    background(255);
    newPlayer.update();
    CameraManagement();
    rect(player.position.x, player.position.y, player.dimension.x, player.dimension.y);
    
    rect(100,300,500,50);
    
    popMatrix();
    
    newPlayer.drawUI();
}

private void CameraManagement(){
  if(player.position.x+player.dimension.x/2 > width + width*xTile) {
    xTile++;
    player.position.x = width*xTile - player.dimension.x/2 + 1;
  }
  
  else if(player.position.x+player.dimension.x/2 < width*xTile) {
    xTile--; 
    player.position.x = width*xTile + width - player.dimension.x/2 - 1;
  }
  
  if(player.position.y+player.dimension.y/2 > height + height*yTile) {
    yTile++;
    player.position.y = height*yTile - player.dimension.y/2 + 1;
  }
  
  
  else if(player.position.y+player.dimension.y/2 < height*yTile) {
    yTile--; 
    player.position.y = height*yTile + height - player.dimension.y/2 - 1;
  }
}
