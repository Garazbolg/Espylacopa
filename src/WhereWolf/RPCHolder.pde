/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 30/06/2015 
        Last Modified : 30/06/2015
*/


/*
  Holder for the callbacks of the components in a GameObject
*/

public class RPCHolder{
  private HashMap<String,Delegate> delegates;
  private boolean isInit = false;
  
  RPCHolder(){
   isInit = false; 
  }
  
  private void init(){
    if(!isInit){
       delegates = new HashMap<String,Delegate>(); 
       isInit = true;
    }
  }
  
  public void addRPC(String s,Delegate r){
    if(!isInit)
      init();
    delegates.put(s,r);
  }
  
  public void callback(String name,String [] argv){
    println("RPCHolder - Callback with name = " + name + " and argv = " + argv); 
    Delegate func = delegates.get(name);
    println("RPCHolder - Callback, func = " + func);
    if(func != null)
      func.call(argv);
  }
}
/*
RPC.addRPC("RPCMyRPCFunction",new Delegate(){public void call(String [] argv){

}});

*/
