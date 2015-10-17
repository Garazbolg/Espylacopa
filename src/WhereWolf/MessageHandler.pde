/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 07/09/2015 
        Last Modified : 07/09/2015
*/

public class MessageHandler{
  
  private WhereWolf env;
  
  // Message format : 
  // RPC target(RCPMode) ip networkViewId methodName methodArguments
  // Instantiate className position.x poisition.y id
  
  
  
  MessageHandler(WhereWolf newEnv){
    env = newEnv;
  }
  
   public void update(){
     String message = "";
     String readBuffer = "";
     while(readBuffer != null){
        readBuffer = Network.read();
        if(readBuffer != null){
          message+=readBuffer;
        }
     }
     
     /*
     while((message += Network.read()) != null){
     }
     */

       if(message.contains("null")){
         println("STOPSTOPSTOP"); 
         println("STOPSTOPSTOP"); 
         println(message);
         println("STOPSTOPSTOP"); 
         println("STOPSTOPSTOP"); 
       }
       
       String[] messages = message.split("endMessage");
       for(int i=0 ; i<messages.length ; i++){
         String[] typeOfMessage = messages[i].split(" ",2);
         
         /*
           RPC
         */
         //if(typeOfMessage[0] != "null") println("Read " + typeOfMessage[0]);
         //              RPCMode.Specific + " " + ipAdress + " " + "newObjectId" +  + " initPlayer"
         if(typeOfMessage[0].compareTo("RPC") == 0){
           println("read RPC message, typeOfMessage[1] = " + typeOfMessage[1]);
           String[] rpcParams = typeOfMessage[1].split(" ",5);
           RPCMode target = RPCMode.valueOf(rpcParams[0]);
           
           println("read RPC - isServer = " + Network.isServer + " target = " + target + " rpcParams[1] = " + rpcParams[1] + " myIp = " + Network.localIP );
           int indexOfCallbackName = 2;
           switch(target){
             case Server :
               if(!Network.isServer) continue;
               break;
             case Others :
               if(Network.localIP.compareTo(rpcParams[1]) == 0) continue;
               indexOfCallbackName = 3;
               break;
             case OtherClients :
               if(Network.isServer || (Network.localIP.compareTo(rpcParams[1]) == 0)) continue;
               indexOfCallbackName = 3;
             case Specific :
               if(Network.localIP.compareTo(rpcParams[1]) != 0) continue;
               indexOfCallbackName = 3;
           }
           
           int nvID = Integer.parseInt(rpcParams[2]);
           
           println("RPC message readen - indexOfCallbackName = " + indexOfCallbackName);
           println("RPC message readen - rpcParams.length = " + rpcParams.length);
           
           String[] callBackParams = new String[rpcParams.length - 1 - indexOfCallbackName];
           println("RPC message readen - callBackParams.length = " + callBackParams.length);
           for(int paramsIterator=0 ; paramsIterator<callBackParams.length ; paramsIterator++){
             callBackParams[paramsIterator] = rpcParams[indexOfCallbackName + 1 + paramsIterator];
           }
           
           println("read RPC, go to call !");
           println("id = " + nvID);
           println("component : " + NetworkViews.get(nvID));
           println("GO : " + NetworkViews.get(nvID).gameObject);
           println("RPC holder : " + NetworkViews.get(nvID).gameObject.rpcHolder);
           NetworkViews.get(nvID).gameObject.rpcHolder.callback(rpcParams[indexOfCallbackName],callBackParams);
           

         }
         
         else if(typeOfMessage[0].compareTo("InstantiateOnServer") == 0){
           if(Network.isServer){
             String[] instantiateParams = typeOfMessage[1].split(" ",4);
             println("Server read message InstantiateOnServer and call Instantiate with these parameters : " + instantiateParams[0] + " " + instantiateParams[1] + " " + instantiateParams[2] + " " + instantiateParams[3]);
             Network.Instantiate(env, instantiateParams[0], new PVector(Float.parseFloat(instantiateParams[1]),Float.parseFloat(instantiateParams[2])), instantiateParams[3]);
           } 
         }
         
         else if(typeOfMessage[0].compareTo("InstantiateOnClients") == 0){
           if(!Network.isServer){
             println("Server read message InstantiateOnClients");
             String[] instantiateParams = typeOfMessage[1].split(" ",4);
             println("Server read message InstantiateOnClients and use Instantiate code with these parameters : " + instantiateParams[0] + " " + instantiateParams[1] + " " + instantiateParams[2] + " " + instantiateParams[3]);
             
             try{
               
               println("Instantiate from MessageHandler");
               Class<?> clazz = Class.forName(instantiateParams[0]);
               java.lang.reflect.Constructor constructor = clazz.getConstructor(WhereWolf.class, String.class, PVector.class);
  
               println("Client Going to create intance");
               GameObject instance = (GameObject)constructor.newInstance(globalEnv, instantiateParams[0], new PVector(Float.parseFloat(instantiateParams[1]), Float.parseFloat(instantiateParams[2])));
               println("Client created intance");
               instance.setActive(false);
               println("Client instance set active to false");
               
                println("goind to parse string id to int");
               int newObjectId = Integer.parseInt(instantiateParams[3]);
               println("newObjectId = " + newObjectId);
               
               //Network.write("InstantiateOnClients " + classToInstantiate + " " + position.x + " " + position.y + " " + newObjectId + "endMessage");
               //Network.write("RPC " + RPCMode.Specific + " " + ipAdress + " " + newObjectId + " " + "InitPlayer" + "endMessage");                          

             }
             catch(Exception e){
               println("Client side, Instantiate exception ; " + e);
             }
           }
         }
         
         /*
           Instantiate
         */
         else if(typeOfMessage[0].compareTo("Instantiate") == 0){
           println("Instantiate message catched");
           
           /*
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
           }*/
         }
         
         else if(typeOfMessage[0].compareTo("GeneratedMap") == 0){
           if(!Network.isServer){
             String[] instantiateParams = typeOfMessage[1].split(" ",2);
             Scene.startScene(new GameObject("Scene", new PVector(), null));
             map = new MapManager(Integer.parseInt(instantiateParams[0]), instantiateParams[1]); 
           }
         } 
         
         else if(typeOfMessage[0].compareTo("SelectedBlocks") == 0){
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
         
         // SetCharacterPosition playerId gameObject.position.x gameObject.position.y
         else if(typeOfMessage[0].compareTo("SetCharacterPosition") == 0){
            String[] messageParams = typeOfMessage[1].split(" ", 3);
            NetworkViews.get(Integer.parseInt(messageParams[0])).gameObject.setPosition(new PVector(Float.parseFloat(messageParams[1]),Float.parseFloat(messageParams[2])));
         }

         
       }
       
       
       
       
       
       
       
     //}
   }
  
}
