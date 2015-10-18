/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 21/04/2015 
        Last Modified : 22/04/2015
*/


public static class NetworkViews{
  
  private static ArrayList<NetworkView> items = new ArrayList<NetworkView>();
  public static int nbMaxIds = 20000; //TODO : Precise this number (currently arbitrary)
  
  
  public static NetworkView get(int index){
    for(NetworkView nv : items)
      if(nv.id == index)
        return nv;
        
    return null;
  }
  
  public static int add(NetworkView nv){
    
    for(int i = 0; i<items.size() ; i++){
     if(items.get(i) == null)
       return(add(nv, i));
       //return i;
    }
    
    items.add(nv);
    return items.size()-1;
    
    //return -1;
    
  }
  
  public static int add(NetworkView nv, int index){
    if(index < items.size() && items.get(index) == null){
       items.add(nv); 
       return index;
    }
    else{
      return add(nv);
    }
      
  }
}

/*
  Component for Objects that should be synchronize over the network
*/
public class NetworkView extends Component{

    protected int id; 
    
    public boolean isClientAuthority = false;
    
    
    NetworkView(int index){
      id = NetworkViews.add(this,index); 
    }
    
    NetworkView(){
      id = NetworkViews.add(this); 
    }
    
    public int getId(){
      return id; 
    }
    
 /*
   Use to call a RPC function on a remote computer
 */
 protected void RPC(String callbackName,RPCMode target, String [] arg){
   if(id < 0){
    println("Error : GameObject :\"" + gameObject.name + "\" NetworkView.id is negative"); 
   }
   String buffer = "";
   for(int i = 0; i< arg.length ; i++)
     buffer += " "+ arg[i];
   Network.write("RPC "+ target.name() + " " + Network.localIP + " " + id + " " + callbackName + buffer + "#");
 }
 
}

/*
  nv.RPC("RPCMyfunction",RPCMode.Others,"Papa Maman 5 Faim");
*/
