
public class DamageCollider extends Collider{
  
  public int damage = 1;
  
  DamageCollider(Area zone){
    super(zone);
  }
  
  DamageCollider(Area zone, int affectedDamage){
    super(zone);
    damage = affectedDamage;
  }
  
  public void onCollisionStay(Collider other){
    if(other.gameObject != null){
      
      GameCharacter gameCharacter = (GameCharacter)other.gameObject.getComponentIncludingSubclasses(GameCharacter.class);
      //println(this.gameObject.getComponentIncludingSubclasses(GameCharacter.class));
      if(gameCharacter != null){
        gameCharacter.DecreaseLife(damage, gameObject.position);   
      }
    }
  }
  
  
}
