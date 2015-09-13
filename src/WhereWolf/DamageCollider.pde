
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
    //if(Constants.DEBUG_MODE)println(gameObject.name + " Enter Collision with " + other.gameObject.name);
    if(other.gameObject != null && other.gameObject.getClass().getSuperclass() == GameCharacter.class){
      ((GameCharacter)(other.gameObject)).DecreaseLife(damage, gameObject.position);   
    }
  }
}
