Rect one, two;
Circle three;

void setup(){
 size(800,600);
 
 one = new Rect(0,0,100,120);
 two = new Rect(200,200,50,60);
 three = new Circle(500,200,100);
  
}

void draw(){
  background(255);
  Updatables.update();
  one.position.x = mouseX;
  one.position.y = mouseY;
  
  fill(0,255,0);
  rect(two.position.x-two.dimension.x/2,two.position.y-two.dimension.y/2,two.dimension.x,two.dimension.y);
  
  fill(0,0,255);
  ellipse(three.position.x,three.position.y,three.ray,three.ray);
  
  fill(0,255,255);
  if(one.intersect(two) || one.intersect(three)){
   fill(255,0,0); 
  }
  rect(one.position.x-one.dimension.x/2,one.position.y- one.dimension.y/2,one.dimension.x,one.dimension.y);
  //println(three.getClass().getClass());
}
