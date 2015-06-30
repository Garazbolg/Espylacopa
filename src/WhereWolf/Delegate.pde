/*
        Made By LE GALL Joseph ( Garazbolg )
        Created : 30/06/2015 
        Last Modified : 30/06/2015
*/


/*
  Interface for callbacks functions
*/
public abstract class Delegate{
  Delegate(Component ref){
   thisComponent = ref; 
  }
  public Component thisComponent;
  
 public abstract void call(String [] argv);
}


