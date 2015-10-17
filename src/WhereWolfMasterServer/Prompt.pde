public class Prompt{
  private int MAX_COLUMN = 65;
  private ArrayList<String> lines;
 
  public Prompt(){
    lines = new ArrayList<String>();
  }
  
  public void printLine(String s){
    lines.add(0,s);
  }
  
  public void draw(){
    int nbLines = 0;
    String line;
      for(int i = 0; i < lines.size() ; i ++){
        line = lines.get(i);
       fill(255);
       int index = 0, lastIndex = line.length(), nextEnd;
       while(index != lastIndex){
         nextEnd = (lastIndex > index+MAX_COLUMN)?index+MAX_COLUMN:lastIndex;
         text(line.substring(index,nextEnd),0, 15+nbLines * (textAscent()+5)); 
         index = nextEnd;
         nbLines++;
       }
      }
  }
  
}