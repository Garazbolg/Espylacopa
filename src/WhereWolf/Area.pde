public abstract class Area{
 public PVector position;
 
 Area(float x,float y){
  position = new PVector(x,y); 
 }

 public abstract boolean inBounds(PVector pos);
 
 public abstract boolean inBounds(float x, float y);
 
 public abstract boolean intersect(Area other); 
 
}

public class Rect extends Area{
 public PVector dimension;
 
 Rect(float x,float y, float w, float h){
  super(x,y);
  dimension = new PVector(w,h); 
 }
 
 public boolean inBounds(float x,float y){
  return (x < position.x+dimension.x && x >= position.x && y < position.y+dimension.y && y >= position.y);
 }

 public boolean inBounds(PVector pos){
  return inBounds(pos.x,pos.y);
 }
 
 public boolean intersect(Area other){
  if(other instanceof Rect){
    Rect o = (Rect)other;
    return (position.x < o.position.x+o.dimension.x && position.x+dimension.x > o.position.x &&
            position.y < o.position.y+o.dimension.y && position.y+dimension.y > o.position.y);
  }
  if(other instanceof Circle){
    Circle o = (Circle)other;
    
    
    //Check the four corners of the rectangl, if either one of them is in the circle then they intersect
    if(o.inBounds(position) || o.inBounds(position.x,position.y+dimension.y) || o.inBounds(position.x+dimension.x,position.y) || o.inBounds(PVector.add(position,dimension)))
      return true;
    
    //else check if the points of the circles (Noth/South/East/West and center) are in the rectangle
    if(inBounds(o.position) || inBounds(o.position.x+o.ray/2,o.position.y) || inBounds(o.position.x,o.position.y+o.ray/2) || inBounds(o.position.x-o.ray/2,o.position.y) || inBounds(o.position.x,o.position.y-o.ray/2))
      return true;
      
    return false;
  }
  
  return false;
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
}
