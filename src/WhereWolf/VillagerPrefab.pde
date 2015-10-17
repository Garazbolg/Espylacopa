public class VillagerPrefab extends GameObject {
  

  public VillagerPrefab(String name, PVector position){
    super(name, position);
    
    Scene.addChildren(this);
    
    Villager villagerComponent = new Villager();
    this.addComponent(villagerComponent);
    villagerComponent.init();
  }
  
}
