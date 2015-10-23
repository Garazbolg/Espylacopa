/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 07/09/2015 
        Last Modified : 07/09/2015
*/

public class MessageHandler{
  
  private WhereWolf env;
  
  private String buffer = "";
  private String message;
  
  // Message format : 
  // RPC target(RCPMode) ip networkViewId methodName methodArguments
  // Instantiate className position.x poisition.y id
  
  
  
  MessageHandler(WhereWolf newEnv){
    env = newEnv;
  }
  
   public void update(){
     
     if(!Network.isConnected) return;
     
     if(Network.isServer){
       if(Network.server == null) return;
       Network.client = Network.server.available();
       if (Network.client != null) {
        buffer += Network.client.readString();
        int lastEndMessageIndex = buffer.lastIndexOf("#");
        if(lastEndMessageIndex == -1) return;
        message = buffer.substring(0, lastEndMessageIndex);
        buffer = buffer.substring(lastEndMessageIndex+1, buffer.length());
       } else return;
     } else{
       if (Network.client.available() > 0) {
         buffer += Network.client.readString();    
         int lastEndMessageIndex = buffer.lastIndexOf("#");
         if(lastEndMessageIndex == -1) return;
         message = buffer.substring(0, lastEndMessageIndex);
         buffer = buffer.substring(lastEndMessageIndex+1, buffer.length());
       } else {
         int lastEndMessageIndex = buffer.lastIndexOf("#");
         if(lastEndMessageIndex == -1) return;
         message = buffer.substring(0, lastEndMessageIndex);
         buffer = buffer.substring(lastEndMessageIndex+1, buffer.length());
       }
     }
     
       String[] messages = message.split("#");
       for(int messageIterator=0 ; messageIterator<messages.length ; messageIterator++){
         String[] typeOfMessage = messages[messageIterator].split(" ",2);
         
         
         //RPC
         // RPCMode.Specific + " " + ipAdress + " " + "newObjectId" +  + " initPlayer"
         // RPC " + RPCMode.Others + " " + ipAdress + " " + playerId + " setXvelocity 
         if(typeOfMessage[0].compareTo("RPC") == 0){
           
           // Server receive messages from all client and rewrite them to allow communication from client to client
           if(Network.isServer){
             Network.write(messages[messageIterator]+"#"); 
           }
          
           String[] rpcParams = typeOfMessage[1].split(" ");
           RPCMode target = RPCMode.valueOf(rpcParams[0]);
           
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
          
             
           String[] callBackParams = new String[rpcParams.length - 1 - indexOfCallbackName];
           
           for(int paramsIterator=0 ; paramsIterator<callBackParams.length ; paramsIterator++){
             callBackParams[paramsIterator] = rpcParams[indexOfCallbackName + 1 + paramsIterator];
           }
          
           NetworkViews.get(nvID).gameObject.rpcHolder.callback(rpcParams[indexOfCallbackName],callBackParams);

         }
         
         // SetFogOfWar + fogOfWar
         else if(typeOfMessage[0].compareTo("SetFogOfWar") == 0){
           if(!Network.isServer){
             String[] messageParams = typeOfMessage[1].split(" ");
             fogOfWar =  boolean(messageParams[0]);
           }
         }
         
         // ClientAskHisClientNumber + clientIp
         else if(typeOfMessage[0].compareTo("ClientAskHisClientNumber") == 0){
           if(Network.isServer){
             String[] messageParams = typeOfMessage[1].split(" ");
             Network.write("AssignClientNumber " + messageParams[0] + " " + Network.getClientNumber() + "#");
           }
         }
         
         // ClientAskHisClientNumber + clientIp
         else if(typeOfMessage[0].compareTo("ClientReady") == 0){
           if(Network.isServer){
             Network.numberOfInitializedClients++;
             if(Network.numberOfInitializedClients == Network.numberOfClients){
               if(!sawsManagedByNetwork){
                 Network.write("StartGame#");
                 startGame();
               } else{
                 Network.write("AddSawsOnNetwork#");
                 map.addSawsOnNetwork();
                 startGame();
               }
             }
           }
         }
         
         else if(typeOfMessage[0].compareTo("AddSawsOnNetwork") == 0){
           if(!Network.isServer){
             map.addSawsOnNetwork();
             startGame();
           }
         }
         
         else if(typeOfMessage[0].compareTo("StartGame") == 0){
           if(!Network.isServer){
             startGame();
           }
         }
         
         // AssignClientNumber + clientIp + playerNumber
         else if(typeOfMessage[0].compareTo("AssignClientNumber") == 0){
           if(!Network.isServer){
             String[] messageParams = typeOfMessage[1].split(" ");
             if(Network.localIP.compareTo(messageParams[0]) != 0) continue;
             globalPlayerNumber = Integer.parseInt(messageParams[1]);
           }
         }
         
         else if(typeOfMessage[0].compareTo("InstantiateOnServer") == 0){
           if(Network.isServer){
             String[] instantiateParams = typeOfMessage[1].split(" ",4);
             Network.Instantiate(env, instantiateParams[0], new PVector(Float.parseFloat(instantiateParams[1]),Float.parseFloat(instantiateParams[2])), instantiateParams[3]);
           } 
         }
         
         else if(typeOfMessage[0].compareTo("InstantiateOnClients") == 0){
           if(!Network.isServer){
             String[] instantiateParams = typeOfMessage[1].split(" ",4);
             
             try{
               
               Class<?> clazz = Class.forName(instantiateParams[0]);
               java.lang.reflect.Constructor constructor = clazz.getConstructor(WhereWolf.class, String.class, PVector.class);
  
               GameObject instance = (GameObject)constructor.newInstance(globalEnv, instantiateParams[0], new PVector(Float.parseFloat(instantiateParams[1]), Float.parseFloat(instantiateParams[2])));
               
               int newObjectId = Integer.parseInt(instantiateParams[3]);
                                    
             }
             catch(Exception e){
               println("Client side, Instantiate exception ; " + e);
             }
           }
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
         
         // SetPosition playerId gameObject.position.x gameObject.position.y
         else if(typeOfMessage[0].compareTo("SetPosition") == 0){
           
           if(Network.isServer){
             Network.write(messages[messageIterator] + "#"); 
           }
           
            String[] messageParams = typeOfMessage[1].split(" ", 3);
            if(playerId != Integer.parseInt(messageParams[0])){
              NetworkViews.get(Integer.parseInt(messageParams[0])).gameObject.setPosition(new PVector(Float.parseFloat(messageParams[1]),Float.parseFloat(messageParams[2])));
            }
         }
       }

         
       //}

       
       
       
       
       
     //}
   }
  
}
