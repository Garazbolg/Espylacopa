GameObject one, two, three, four;
boolean DEBUG_MODE = true;
boolean SHOW_FPS = true;


void setup(){
 size(1000,800);
 
 one = new GameObject("One",new PVector(200,500));
 one.addComponent(new Collider(new Rect(0,0,100,120)));
 one.addComponent(new Rigidbody());
 two = new GameObject("Two",new PVector(200,200));
 two.addComponent(new Collider(new Rect(0,0,50,60)));
 three = new GameObject("Three",new PVector(500,200));
 three.addComponent(new Collider(new Circle(0,0,100)));
 four = new GameObject("Four",new PVector(500,600));
 four.addComponent(new Collider(new Rect(0,0,700,150)));
 
 ((Collider)three.getComponent(Collider.class)).isTrigger = true;
  
 ((Rigidbody) one.getComponent(Rigidbody.class)).setVelocity(new PVector(50,-400));
}

void draw(){
  background(255);
  
  if(mousePressed)
    Time.setTimeScale(0.5f);
    
    
    
    one.draw();
    two.draw();
    three.draw();
    four.draw();
    
    if(DEBUG_MODE){
       one.debugDraw();
       two.debugDraw();
       three.debugDraw();
       four.debugDraw();
    }
    
    fill(255,0,0);
    text(Time.getFPS(),0,textAscent());
    
  Updatables.update();
  
  
}
