/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 30/06/2015 
        Last Modified : 30/06/2015
*/

import processing.net.*;

/*
  Static class to handle Networking
*/
public static class Network{
 
  public static boolean isServer = false;
  public static boolean isConnected = false;
  public static boolean lastSocketFailed = false;
  public static String localIP = "";
  public static Server server;
  public static Client client;
  
  
  public static int sendRate = 15;
  
 
 public static boolean connectServer(processing.core.PApplet env,int port){
   if(isConnected) return false;
   try{
   server = new Server(env,port);
   isConnected = true;
    isServer = true;
    client = null;
    return true;
   }
   catch(RuntimeException e){
     server = null;
    lastSocketFailed = true;
    isConnected = false; 
    return false;
   }
   
 }

 public static boolean connectClient(processing.core.PApplet env,String serverIP,int port){
   if(isConnected) return false;
   client = new Client(env,serverIP,port);
   
   if(!client.active()){
    client = null;
    lastSocketFailed = true;
   isConnected = false; 
   return false;
   }
   else{
    isConnected = true;
    isServer = false;
    server = null;
    return true;
   }
 }
 
 
 public static boolean write(String message){
   if(!isConnected) return false;
   if(isServer){
     server.write(message);
     return true; 
   }
   
   if(!isServer && client.active()){
     client.write(message);
     return true; 
   }
   
   return false;
 }
 
 public static String read(){
   if(!isConnected) return null;
   if(isServer ){
     client = server.available();
     if(client != null)
       return client.readString();
   }
   
   if(!isServer && client.active() && client.available()>0){
     return client.readString();
   }
   return null;
 }
 
 public void Instantiate(){
   
 }
 
 
 
 
 
 
 
 
}

/*
CloseConnection  Close the connection to another system.
Destroy  Destroy the object associated with this view ID across the network.
DestroyPlayerObjects  Destroy all the objects based on view IDs belonging to this player.
Disconnect  Close all open connections and shuts down the network interface.
GetAveragePing  The last average ping time to the given player in milliseconds.
GetLastPing  The last ping time to the given player in milliseconds.
HavePublicAddress  Check if this machine has a public IP address.
InitializeSecurity  Initializes security layer.
InitializeServer  Initialize the server.
Instantiate  Network instantiate a prefab.
//SetLevelPrefix  Set the level prefix which will then be prefixed to all network ViewID numbers.
SetReceivingEnabled  //Enable or disables the reception of messages in a specific group number from a specific player.
SetSendingEnabled  //Enables or disables transmission of messages and RPC calls on a specific network group number.
TestConnection  //Test this machines network connection.
Messages

OnConnectedToServer  Called on the client when you have successfully connected to a server.
OnDisconnectedFromServer  Called on client during disconnection from server, but also on the server when the connection has disconnected.
OnFailedToConnect  Called on the client when a connection attempt fails for some reason.
OnNetworkInstantiate  Called on objects which have been network instantiated with Network.Instantiate.
OnPlayerConnected  Called on the server whenever a new player has successfully connected.
OnPlayerDisconnected  Called on the server whenever a player is disconnected from the server.
OnSerializeNetworkView  Used to customize synchronization of variables in a script watched by a network view.
OnServerInitialized*/
