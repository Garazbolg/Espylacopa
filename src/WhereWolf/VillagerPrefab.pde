public class VillagerPrefab extends GameObject {
  
  VillagerPrefab(String name, PVector position){
    super(name, position);
    Villager villagerComponent = new Villager();
    this.addComponent(villagerComponent);
    
    Rigidbody rigid = new Rigidbody();
    this.addComponent(rigid);
    villagerComponent.setRigid(rigid);
    
    Collider characterCollider = new Collider(new Rect(0,0,villagerComponent.getWalkAndIdle().getSpriteWidth(),villagerComponent.getWalkAndIdle().getSpriteHeight()));
    characterCollider.layer = CollisionLayer.CharacterBody;
    characterCollider.passablePlatform = true;
    //characterCollider.forceDebugDraw = true;
    
    this.addComponent(characterCollider);
    villagerComponent.setCharacterCollider(characterCollider);
    
    this.addComponent(villagerComponent.getAnimator());
    
    GameObject leftShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), this);
    leftShotAttack.addComponent(new Collider(new Rect(-29, 0, 82, 10)));
    Collider leftShotAttackCollider = (Collider)leftShotAttack.getComponent(Collider.class);
    leftShotAttackCollider.isTrigger = true;
    
    villagerComponent.setLeftShotAttack(leftShotAttack);
    villagerComponent.setLeftShotAttackCollider(leftShotAttackCollider);
    
    GameObject rightShotAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), this);
    rightShotAttack.addComponent(new Collider(new Rect(53, 0, 88, 10)));
    Collider rightShotAttackCollider = (Collider)rightShotAttack.getComponent(Collider.class);
    rightShotAttackCollider.isTrigger = true;
    
    villagerComponent.setRightShotAttack(rightShotAttack);
    villagerComponent.setRightShotAttackCollider(rightShotAttackCollider);
    

    
  }
  
}
