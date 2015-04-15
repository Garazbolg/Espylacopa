public interface Collider{
 public boolean inBounds(PVector pos);
 
 public boolean intersect(Collider other);

 public void onCollisionEnter(Collider other);

 public GameObject getGameObject();
}
