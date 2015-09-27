


enum CollisionLayer{
  None, Environment, CharacterBody;

  public static CollisionLayer fromInteger(int x) {
        switch(x) {
          case 0 : return None;
          case 1 : return Environment;
          case 2 : return CharacterBody;
        }
        
        return null;
    }
    
};
