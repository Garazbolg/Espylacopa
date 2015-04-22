GameObject one, two, three, four;

MapManager map;


void setup(){
 size(1000,800);
 
 one = new GameObject("One",new PVector(350,200));
 one.addComponent(new Collider(new Rect(0,0,100,200)));
 one.addComponent(new Rigidbody());
 two = new GameObject("Two",new PVector(500,400));
 two.addComponent(new Collider(new Rect(0,0,50,100)));
 three = new GameObject("Three",new PVector(400,-400));
 three.addComponent(new Collider(new Circle(0,0,100)));
 three.addComponent(new Rigidbody());
 four = new GameObject("Four",new PVector(500,600));
 four.addComponent(new Collider(new Rect(0,0,700,150)));
 
 one.addChildren(three);
 
 //((Collider)three.getComponent(Collider.class)).isTrigger = true;
 Updatables.start(); 
 ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(10,0));
 
 
 map = new MapManager(3);
 
 
}

void draw(){
  /*
  background(255);
  Updatables.update();
  
  if(mousePressed)
    Time.setTimeScale(0.5f);
    
  if(keyPressed){
     if(key == 'd')
       ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(100,0));
     if(key == 'q')
       ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(-100,0));
     if(key == 'z')
       ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(0,-100));
  }
    one.draw();
    two.draw();
    //three.draw();
    four.draw();
    
    if(Constants.DEBUG_MODE){
       one.debugDraw();
       two.debugDraw();
       //three.debugDraw();
       four.debugDraw();
    }
    
    if(Constants.SHOW_FPS){
      fill(255,0,0);
      text(Time.getFPS(),0,textAscent());
    }
    */
    
    map.DrawMap();
    
  
  
  
}
