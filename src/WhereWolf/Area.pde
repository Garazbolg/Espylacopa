public abstract class Area implements Cloneable,Drawable{
 public PVector position;
 
 Area(float x,float y){
  position = new PVector(x,y); 
 }

 public abstract boolean inBounds(PVector pos);
 
 public abstract boolean inBounds(float x, float y);
 
 public abstract boolean intersect(Area other); 
 
 public abstract void draw();
 
 public Object clone() {
    Area o = null;
    try {
      o = (Area)super.clone();
    } catch(CloneNotSupportedException cnse) {
      cnse.printStackTrace(System.err);
    }
    
    o.position = position.get();
    // on renvoie le clone
    return o;
  }
 
}

public class Rect extends Area{
 public PVector dimension;
 
 Rect(float x,float y, float w, float h){
  super(x,y);
  dimension = new PVector(w,h); 
 }
 
 public boolean inBounds(float x,float y){
  return (x < position.x+dimension.x/2 && x >= position.x-dimension.x/2 && y < position.y+dimension.y/2 && y >= position.y-dimension.y/2);
 }

 public boolean inBounds(PVector pos){
  return inBounds(pos.x,pos.y);
 }
 
 public boolean intersect(Area other){
  if(other instanceof Rect){
    Rect o = (Rect)other;
    return (position.x-dimension.x/2 < o.position.x+o.dimension.x/2 && position.x+dimension.x/2 > o.position.x-o.dimension.x/2 &&
            position.y-dimension.y/2 < o.position.y+o.dimension.y/2 && position.y+dimension.y/2 > o.position.y-o.dimension.y/2);
  }
  if(other instanceof Circle){
    Circle o = (Circle)other;
    
    
    //Check the four corners of the rectangle, if either one of them is in the circle then they intersect
    if(o.inBounds(PVector.sub(position,PVector.div(dimension,2))) || o.inBounds(position.x-dimension.x/2,position.y+dimension.y/2) || o.inBounds(position.x+dimension.x/2,position.y-dimension.y/2) || o.inBounds(PVector.add(position,PVector.div(dimension,2))))
      return true;
    
    //else check if the points of the circles (Noth/South/East/West and center) are in the rectangle
    if(inBounds(o.position) || inBounds(o.position.x+o.ray/2,o.position.y) || inBounds(o.position.x,o.position.y+o.ray/2) || inBounds(o.position.x-o.ray/2,o.position.y) || inBounds(o.position.x,o.position.y-o.ray/2))
      return true;
      
    return false;
  }
  
  return false;
 }
 
 public void draw(){
    rect(position.x-dimension.x/2,position.y-dimension.y/2,dimension.x,dimension.y); 
 }
 
 public Object clone() {
    Rect o = null;
      o = (Rect)super.clone();
    
    o.dimension = dimension.get();
    // on renvoie le clone
    return o;
  }
}

public class Circle extends Area{
 public float ray;

  Circle(float x, float y, float r){
    super(x,y);
    ray = r;
  }

 public boolean inBounds(PVector pos){
  return PVector.dist(pos,position)<=ray/2;
 }
 
 public boolean inBounds(float x, float y){
  return sqrt(sq(x-position.x)+sq(y-position.y)) <= ray/2;
 }
 
 public boolean intersect(Area other){
  if(other instanceof Rect)
    return other.intersect(this);
    
  return false;
 }
 
 public void draw(){
   ellipse(position.x,position.y,ray,ray); 
 }
 
 public Object clone() {
    Circle o = null;
      o = (Circle)super.clone();
    
    o.ray = ray;
    // on renvoie le clone
    return o;
  }
}
