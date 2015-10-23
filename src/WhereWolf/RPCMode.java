/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 30/06/2015 
        Last Modified : 30/06/2015
*/


/*
  Use to define who's the target to 
*/

public enum RPCMode{

Server,	//Send to the server only.
Others,	//Send to everyone except the sender.
OtherClients, //Send to every clients except the sender.
All, //Send to everyone.
Specific // Send to only one ip
}
