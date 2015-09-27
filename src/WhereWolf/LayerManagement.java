


enum LayerManagement{
  All, AllExceptMyLayer, OnlyMyLayer;

  public static LayerManagement fromInteger(int x) {
        switch(x) {
          case 0 : return All;
          case 1 : return AllExceptMyLayer;
          case 2 : return OnlyMyLayer;
        }
        
        return null;
    }
    
};
