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
       
       /*
         RPC
       */
       if(typeOfMessage[0].compareTo("RPC") == 0){
         String[] rpcParams = typeOfMessage[1].split(" ",5);
         RPCMode target = RPCMode.valueOf(rpcParams[0]);
         
         if((target == RPCMode.Others || target == RPCMode.OtherClients) && (Network.localIP.compareTo(rpcParams[1]) == 0))
           continue;
         
         int nvID = Integer.parseInt(rpcParams[2]);
         
         NetworkViews.get(nvID).gameObject.rpcHolder.callback(rpcParams[3],rpcParams[4].split(" "));
         
       }
       
       /*
         Instantiate
       */
       if(typeOfMessage[0].compareTo("Instantiate") == 0){
         
         if(Network.isServer){
           String[] instantiateParams = typeOfMessage[1].split(" ",3);
           
           try{
             Class<?> clazz = Class.forName(instantiateParams[0]);
             java.lang.reflect.Constructor constructor = clazz.getConstructor(String.class, PVector.class);
             GameObject instance = (GameObject)constructor.newInstance(instantiateParams[0], new PVector(Float.parseFloat(instantiateParams[1]),Float.parseFloat(instantiateParams[2])));
             Network.write(message + " " + ((NetworkView)instance.getComponent(NetworkView.class)).id);
           }
           catch (Exception e){
             //TODO Error message for class not found and other exceptions 
           }
         }
         else{
           String[] instantiateParams = typeOfMessage[1].split(" ",4);
           
           try{
             Class<?> clazz = Class.forName(instantiateParams[0]);
             java.lang.reflect.Constructor constructor = clazz.getConstructor(String.class, PVector.class);
             GameObject instance = (GameObject)constructor.newInstance(instantiateParams[0], new PVector(Float.parseFloat(instantiateParams[1]),Float.parseFloat(instantiateParams[2])));
             ((NetworkView)instance.getComponent(NetworkView.class)).id = Integer.parseInt(instantiateParams[3]);
           }
           catch (Exception e){
             //TODO Error message for class not found and other exceptions 
           }
         }
       }
       
       
       
     }
   }
  
}
