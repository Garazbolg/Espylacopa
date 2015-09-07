


enum Direction{
  Left, Up, Right, Down;

  public static Direction fromInteger(int x) {
        switch(x) {
        case 0:
            return Left;
        case 1:
            return Up;
        case 2 :
            return Right;
        case 3 : return Down;
        }
        return null;
    }
    
};
