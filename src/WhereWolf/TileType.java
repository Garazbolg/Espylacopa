


enum TileType{
  Closed, Opened;

  public static TileType fromInteger(int x) {
        switch(x) {
        case 0:
            return Closed;
        case 1:
            return Opened;
        }
        return null;
    }
    
};
