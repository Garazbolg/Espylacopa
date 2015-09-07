


enum TileType{
  Closed, Opened;

  public static TileType fromInteger(int x) {
        switch(x) {
        case 0:
            return Opened;
        case 1:
            return Closed;
        }
        return null;
    }
    
};
