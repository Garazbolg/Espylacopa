


enum ChestContent{
  ArmorHeart, Invincibility, SpeedBoost, Empty, PowerBoost;

  public static ChestContent fromInteger(int x) {
        switch(x) {
          case 0 : return ArmorHeart;
          case 1 : return Invincibility;
          case 2 : return SpeedBoost;
          case 3 : return Empty;
          case 4 : return PowerBoost;
        }
        
        return null;
    }
    
};
