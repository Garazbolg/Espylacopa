/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 07/09/2015 
        Last Modified : 07/09/2015
*/

public class MessageHandler{
  
  // Message format : 
  // RPC target(RCPMode) ip networkViewId methodName methodArguments
  // Instantiate className position.x poisition.y id
  
   public void update(){
     String message = "";
     String readBuffer = "";
     while(readBuffer != null){
        readBuffer = Network.read();
        message+=readBuffer;
     }
     
     /*
     while((message += Network.read()) != null){
     }
     */

       
       String[] messages = message.split("endMessage");
       for(int i=0 ; i<messages.length ; i++){
         String[] typeOfMessage = messages[i].split(" ",2);
         
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
               Network.write(message + " " + ((NetworkView)instance.getComponent(NetworkView.class)).id +"endMessage");
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
         
         if(typeOfMessage[0].compareTo("GeneratedMap") == 0){
           if(!Network.isServer){
             String[] instantiateParams = typeOfMessage[1].split(" ",2);
             Scene.startScene(new GameObject("Scene", new PVector(), null));
             map = new MapManager(Integer.parseInt(instantiateParams[0]), instantiateParams[1]); 
           }
         } 
         
         if(typeOfMessage[0].compareTo("SelectedBlocks") == 0){
           if(!Network.isServer){
             map.CopySelectedBlocksFromModel(typeOfMessage[1]);
             map.DefineTilesForAllBlock();
           }
         }
                
         else if(typeOfMessage[0].compareTo("SpawnPositions") == 0){
           if(!Network.isServer){
             String[] instantiateParams = typeOfMessage[1].split(" ",2);
             map.CopySpawnPositionsFromModel(typeOfMessage[1]);
             map.CreateMap();
             launchGame();
           }
         }
       }
       
       
       
       
       
       
       
     //}
   }
  
}
