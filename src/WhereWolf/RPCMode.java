/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 30/06/2015 
        Last Modified : 30/06/2015
*/


/*
  Use to define who's the target to 
*/

public enum RPCMode{

Server,	//Sends to the server only.
Others,	//Sends to everyone except the sender.
OtherClients, //Sends to every clients except the sender.
All	//Sends to everyone.
}