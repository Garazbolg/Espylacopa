/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 30/06/2015 
        Last Modified : 30/06/2015
*/


// Process to create new RCP :
// 1) Create new Delegate class which Extends from Delegate and define his specific call method (which converts string args to good type)
// 2) Add RPC to the component which contains the method, example : this.addRPC("decreaseLife", new DelegateDecreaseLife(this));
// 3) Write the RPC call to network, message format : RPCMode.? + " " + ipAdress (only if useful for RPCMode specified) + " " + objectNetworkId (object on which the method will be called) + " " + name of delegate + #
// Don't forget all messages must finish with # symbol !

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
    if(!isInit){
      init();
    }
    delegates.put(s,r);
  }
  
  public void callback(String name,String [] argv){
    Delegate func = delegates.get(name);
    if(func != null)
      func.call(argv);
  }
}
