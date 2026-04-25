#include <systemc.h>
#include <cstdlib>
#include <ctime>
#include "settings.h"

#ifndef TICK_COUNTER_H
#define TICK_COUNTER_H

SC_MODULE ( TickCounter ) {

  sc_fifo_out<int> out; 
  int ticks;      
    
  void send(){
    int speed;

    srand(time(NULL));
    while(true){
      wait(TICKPERIOD, SC_MS);
      speed = rand();
      out.write(speed); 
    }
  }  
  SC_CTOR(TickCounter) {
    SC_THREAD(send);
  } 
}; 
#endif
