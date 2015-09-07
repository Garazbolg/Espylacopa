/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 07/09/2015 
        Last Modified : 07/09/2015
*/

public static class MessageHandler{
  
   public static void update(){
     String message;
     while((message = Network.read()) != null){
       String[] typeOfMessage = message.split(" ",2);
       
       if(typeOfMessage[0].compareTo("RPC") == 0){
         String[] rpcParams = typeOfMessage[1].split(" ",5);
         RPCMode target = RPCMode.valueOf(rpcParams[0]);
         
         if((target == RPCMode.Others || target == RPCMode.OtherClients) && (Network.localIP.compareTo(rpcParams[1]) == 0))
           continue;
         
         int nvID = Integer.parseInt(rpcParams[2]);
         
         NetworkViews.get(nvID).gameObject.rpcHolder.callback(rpcParams[3],rpcParams[4].split(" "));
         
       }
       
     }
   }
  
}
