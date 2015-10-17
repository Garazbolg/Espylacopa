/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 30/06/2015 
        Last Modified : 30/06/2015
*/

import processing.net.*;

/*

the format of the messages are either :
client updateList\n
server create "Server Name"\n
server destroy\n
*/

Server server;
Client currentClient;
Prompt prompt;


int port = 45678;
String input;
String[] inputs;
String[] commands;
String serverList = "";
boolean needUpdate = true;

public class ServerID{
 String ip;
 String name;
}

ArrayList<ServerID> servers;

void setup(){
  size(400,600);
  
  frameRate(5);
  server = new Server(this,port);
  servers = new ArrayList<ServerID>();
  prompt = new Prompt();
  
  prompt.printLine("Server started on port " + port);
}

void draw(){
  background(0);
  if(!server.active()){
   return; 
  }
  while((currentClient = server.available()) != null){
    input = currentClient.readString();
    inputs = split(input,'\n');
    
    for(int i = 0; i< inputs.length - 1;i++ ){ //length -1 because the last will either be empty or wrong
      prompt.printLine(currentClient.ip() + " : " + inputs[i] );
      commands = inputs[i].split(" ",2);
      if(commands.length < 2)
        continue;
        
        
      if(commands[0].compareTo("server") == 0){
        commands = commands[1].split(" ",2);
        
        
        if(commands[0].compareTo("create")==0){
          if(commands.length != 2)
            continue;
          ServerID newServer = new ServerID();
          newServer.name = commands[1];
          newServer.ip = currentClient.ip();
          servers.add(newServer);
        }
        
        
        if(commands[0].compareTo("destroy")==0){
          for(int j = servers.size()-1; j >= 0  ; j--){
            if(servers.get(j).ip.compareTo(currentClient.ip()) == 0)
               servers.remove(j);
          }
        }
      }
      
      
      
      
      else if (commands[0].compareTo("client") == 0){
        commands = commands[1].split(" ",2);
        
        
        if(commands[0].compareTo("update")==0){
          needUpdate = true;
        }          
      }
    }
  }
  
  if(needUpdate){
    serverList = "masterServer update " + servers.size()+ " ";
    
    for(ServerID sid : servers){
      serverList += ";" + sid.ip + ":" + sid.name;
    }
    prompt.printLine(serverList);
    server.write(serverList);
    
    needUpdate = false;
  }
  prompt.draw();
  
}