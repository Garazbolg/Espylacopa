public class WerewolfPrefab extends GameObject {
  
  WerewolfPrefab(String name, PVector position){
    super(name, position);
    Werewolf werewolfComponent = new Werewolf();
    this.addComponent(werewolfComponent);
    
    Rigidbody rigid = new Rigidbody();
    this.addComponent(rigid);
    werewolfComponent.setRigid(rigid);
    
    
    Collider characterCollider = new Collider(new Rect(0, 4, 6, 24));
    this.addComponent(characterCollider);
    werewolfComponent.setCharacterCollider(characterCollider);
    
    GameObject leftHumanAttack = new GameObject("LeftHumanAttack", new PVector(-10,2), this);
    leftHumanAttack.addComponent(new Collider(new Rect(3, 0, 15, 20)));
    Collider leftHumanAttackCollider = (Collider)leftHumanAttack.getComponent(Collider.class);
    leftHumanAttackCollider.isTrigger = true;
    
    werewolfComponent.setLeftHumanAttack(leftHumanAttack);
    werewolfComponent.setLeftHumanAttackCollider(leftHumanAttackCollider);
    
    GameObject rightHumanAttack = new GameObject("RigtHumanAttack", new PVector(-10,2), this);
    rightHumanAttack.addComponent(new Collider(new Rect(15, 0, 15, 20)));
    Collider rightHumanAttackCollider = (Collider)rightHumanAttack.getComponent(Collider.class);
    rightHumanAttackCollider.isTrigger = true;
    
    werewolfComponent.setRightHumanAttack(leftHumanAttack);
    werewolfComponent.setRightHumanAttackCollider(leftHumanAttackCollider);
        
    GameObject leftWerewolfAttack = new GameObject("LeftWerewolfAttack", new PVector(-10,2), this);
    leftWerewolfAttack.addComponent(new Collider(new Rect(0, 5, 22, 30)));
    Collider leftWerewolfAttackCollider = (Collider)leftWerewolfAttack.getComponent(Collider.class);
    leftWerewolfAttackCollider.isTrigger = true;
        
    werewolfComponent.setLeftWerewolfAttack(leftHumanAttack);
    werewolfComponent.setLeftWerewolfAttackCollider(leftHumanAttackCollider);
    
    GameObject rightWerewolfAttack = new GameObject("RigtWerewolfAttack", new PVector(-10,2), this);
    rightWerewolfAttack.addComponent(new Collider(new Rect(22, 5, 22, 30)));
    Collider rightWerewolfAttackCollider = (Collider)rightWerewolfAttack.getComponent(Collider.class);
    rightWerewolfAttackCollider.isTrigger = true;

    werewolfComponent.setRightWerewolfAttack(leftHumanAttack);
    werewolfComponent.setRightWerewolfAttackCollider(leftHumanAttackCollider);
    
    this.addComponent(werewolfComponent.getAnimator());
    
    
  }
  
}
