


enum ChestContent{
  ArmorHeart;

  public static ChestContent fromInteger(int x) {
        switch(x) {
          case 0 : return ArmorHeart;
        }
        
        return null;
    }
    
};
