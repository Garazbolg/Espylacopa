
public class TrapPrefab extends GameObject {
  
  TrapPrefab(PVector position){
    
    super("trap" + position, new PVector(position.x,position.y + 8)); // Warning : must create a new pvector else use reference and follow character position
    Scene.addChildren(this);
    this.addComponent(new Trap()); 
    ((Trap)this.getComponent(Trap.class)).init();
  }
}
