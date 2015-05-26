GameObject one;

float globalScale = 1.0;

//MapManager map;


void setup(){
 size(displayWidth,displayHeight);
 frameRate(60);
 noSmooth();                        //To prevent antialiasing
 
 Constants.DEBUG_MODE = true;
 Constants.SHOW_FPS = true;
 
 globalScale = ((displayHeight < displayWidth)?displayHeight:displayWidth)/128;// 128 => Taille de la room (Tile = 16x16 pixels ; block = 8x8 tiles) donc affichage = 8*16 = 128 pixels
 
 Scene.startScene(new GameObject("Scene",new PVector(),null));
 ImageManager.start(this);
 
 
 GameObject two, three, four,five;
 one = new GameCharacter("One","Villageois",new PVector(350,200));
 /*one.addComponent(new Rigidbody());
 one.addComponent(new StaticAnimation(new Animation(new SpriteSheet("VillageoisSpriteSheet.png",8,4),0,true),6));
 one.addComponent(new Collider(new Rect(0,0,16,32)));*/
 two = new GameObject("Two",new PVector(500,400));
 two.addComponent(new Collider(new Rect(0,0,50,100)));
 five = new GameObject("Two",new PVector(600,400));
 five.addComponent(new Collider(new Rect(0,0,50,100)));
 three = new GameObject("Three",new PVector(400,-400)/*,one*/);
 three.addComponent(new Collider(new Circle(0,0,100)));
 three.addComponent(new Rigidbody());
 four = new GameObject("Four",new PVector(500,600));
 four.addComponent(new Collider(new Rect(0,0,700,150)));
 
 //((Collider)three.getComponent(Collider.class)).isTrigger = true;
 Updatables.start(); 
 //((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(10,0));
 
 
 //map = new MapManager(3);
 
 
}

void draw(){
  
  background(255);
  Updatables.update();
   
  if(mousePressed)
    Time.setTimeScale(0.5f);
    
    
 //Input
 
 //TODO
  /*if(keyPressed){
     if(key == 'd')
       ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(70,0));
     if(key == 'q')
       ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(-70,0));
     if(key == 'z')
       ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(0,-100));
  }*/
  
  
  //Draw
    scale(globalScale); //Mise à l'échelle par rapport à la taille de l'écran (faudra penser à mettre les bords en noirs)
    translate(-200,-400); // translate de (-Camera.position) à faire;
    Scene.draw();
    
  //Debug Draw
    if(Constants.DEBUG_MODE)
       Scene.debugDraw();
    
  //GUI
    resetMatrix();
    
    //TODO : GUI part
    
    
    if(Constants.SHOW_FPS){
      fill(255,0,0);
      text(Time.getFPS(),0,textAscent());
    }
    
    //TODO : display a proper minimap
    //map.DrawMap();
    
}

boolean sketchFullScreen() {
  return true;
}
