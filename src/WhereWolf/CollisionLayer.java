


enum CollisionLayer{
  None, Environment;

  public static CollisionLayer fromInteger(int x) {
        switch(x) {
          case 0 : return None;
          case 1 : return Environment;
        }
        
        return null;
    }
    
};
