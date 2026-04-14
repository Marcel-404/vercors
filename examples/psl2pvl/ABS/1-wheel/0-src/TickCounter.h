#include <systemc.h>
#include <cstdlib>
#include <ctime>
#include "settings.h"

#ifndef TICK_COUNTER_H
#define TICK_COUNTER_H
//#define DEBUG

/*psl
vunit TickCounter{
  assert always out.data_read_event().triggered() -> ...;
}
psl*/
SC_MODULE ( TickCounter ) {

//-*-*-*-*-*-*-*-*-*-*-*-*  INTERFACE  *-*-*-*-*-*-*-*-*-*-*-*-

  sc_fifo_out<int> out; 

//-*-*-*-*-*-*-*-*-*-*-*-* LOCAL VARIABLES *-*-*-*-*-*-*-*-*-*-*-*-
  int ticks;       // Counter

//-*-*-*-*-*-*-*-*-*-*-*-*-* COUNTER *-*-*-*-*-*-*-*-*-*-*-*-*-
  
  /* void count(){
    if (reset.read())
      ticks = 0;
    else
      ticks = ticks + 1;
      }*/
 
//-*-*-*-*-*-*-*-*-*-*-*-*-* SENDER *-*-*-*-*-*-*-*-*-*-*-*-*-
  
  // read ticks in a given time interval and send to ECU
  void send(){
    int speed;

    srand(time(NULL));
    while(true){
      wait(TICKPERIOD, SC_MS);
      speed = rand();
      out.write(speed); // zur ECU schicken  
//	ticks = 0; 
    }
  }

//-*-*-*-*-*-*-*-*-*-*-*-*-*-* CONSTRUCTOR *-*-*-*-*-*-*-*-*-*-*-*-*-*-
  
  SC_CTOR(TickCounter) {
    //    SC_METHOD(count);
    //sensitive << inTicks;
    SC_THREAD(send);
  } 
}; 
#endif
