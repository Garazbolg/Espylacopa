public class WerewolfPrefab extends GameObject {
  
  WerewolfPrefab(String name, PVector position){
    super(name, position);
    Scene.addChildren(this);
    
    Werewolf werewolfComponent = new Werewolf();
    this.addComponent(werewolfComponent);
    werewolfComponent.init();
    
    
    

    
    
  }
  
}
