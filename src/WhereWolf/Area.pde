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
  
  public abstract PVector getExtremePoint(Orientation o);
 
}

public class Rect extends Area{
 public PVector halfDimension;
 
 Rect(float x,float y, float w, float h){
  super(x,y);
  halfDimension = new PVector(w/2,h/2); 
 }
 
 public boolean inBounds(float x,float y){
  return (x < position.x+halfDimension.x && x >= position.x-halfDimension.x && y < position.y+halfDimension.y && y >= position.y-halfDimension.y);
 }

 public boolean inBounds(PVector pos){
  return inBounds(pos.x,pos.y);
 }
 
 public boolean intersect(Area other){
  if(other instanceof Rect){
    Rect o = (Rect)other;
    return (position.x-halfDimension.x < o.position.x+o.halfDimension.x && position.x+halfDimension.x > o.position.x-o.halfDimension.x &&
            position.y-halfDimension.y < o.position.y+o.halfDimension.y && position.y+halfDimension.y > o.position.y-o.halfDimension.y);
  }
  if(other instanceof Circle){
    Circle o = (Circle)other;
    
    
    //Check the four corners of the rectangle, if either one of them is in the circle then they intersect
    if(o.inBounds(PVector.sub(position,halfDimension)) || o.inBounds(position.x-halfDimension.y,position.y+halfDimension.y) || o.inBounds(position.x+halfDimension.x,position.y-halfDimension.y) || o.inBounds(PVector.add(position,halfDimension)))
      return true;
    
    //else check if the points of the circles (Noth/South/East/West and center) are in the rectangle
    if(inBounds(o.position) || inBounds(o.position.x+o.halfRay,o.position.y) || inBounds(o.position.x,o.position.y+o.halfRay) || inBounds(o.position.x-o.halfRay,o.position.y) || inBounds(o.position.x,o.position.y-o.halfRay))
      return true;
      
    return false;
  }
  
  return false;
 }
 
 public void draw(){
    rect(position.x-halfDimension.x,position.y-halfDimension.y,halfDimension.x*2,halfDimension.y*2); 
 }
 
 public Object clone() {
    Rect o = null;
      o = (Rect)super.clone();
    
    o.halfDimension = halfDimension.get();
    // on renvoie le clone
    return o;
  }
  
  public PVector getExtremePoint(Orientation o){
   switch(o){
    case North : return new PVector(position.x,position.y-halfDimension.y);
    case South :return new PVector(position.x,position.y+halfDimension.y);
    case East :return new PVector(position.x+halfDimension.x,position.y);
    case West :return new PVector(position.x-halfDimension.x,position.y);
    default :
      return new PVector();
   } 
  }
}

public class Circle extends Area{
 public float halfRay;

  Circle(float x, float y, float r){
    super(x,y);
    halfRay = r/2;
  }

 public boolean inBounds(PVector pos){
  return PVector.dist(pos,position)<=halfRay;
 }
 
 public boolean inBounds(float x, float y){
  return sqrt(sq(x-position.x)+sq(y-position.y)) <= halfRay;
 }
 
 public boolean intersect(Area other){
  if(other instanceof Rect)
    return other.intersect(this);
    
  return false;
 }
 
 public void draw(){
   ellipse(position.x,position.y,halfRay*2,halfRay*2); 
 }
 
 public Object clone() {
    Circle o = null;
      o = (Circle)super.clone();
    
    o.halfRay = halfRay;
    // on renvoie le clone
    return o;
  }
  
  public PVector getExtremePoint(Orientation o){
   switch(o){
    case North : return new PVector(position.x,position.y-halfRay);
    case South :return new PVector(position.x,position.y+halfRay);
    case East :return new PVector(position.x+halfRay,position.y);
    case West :return new PVector(position.x-halfRay,position.y);
    default :
      return new PVector();
   } 
  }
}
