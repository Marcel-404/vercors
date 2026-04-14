#include <systemc.h>

#include "TickCounter.h"
#include "ABSASR.h"

#define DEBUG

/* psl 
vunit main{
  // Properties using within_t:
  assert always (active(s.send) && speed_s.data_written_event().triggered()) -> 
    within_t[(1,SC_MS)] (active(ecu_absasr.read_s) && bus_s.data_read_event().triggered() && ecu_absasr.v[0] == s.speed);
  
  assert always (active(ecu_absasr.read_s) && bus_s.data_read_event().triggered() -> 
    within[(1,SC_MS)] active(ecu_absasr.not_a_main) && ecu_absasr.fa == s.speed - ecu_absasr.fv);

  // Properties using before:
  assert always (active(s.send) && speed_s.data_written_event().triggered()) -> before (active(ecu_absasr.read_s) && bus_s.data_read_event().triggered()) 

  // Properties using until:


  // Already automatically checked by SystemC Transformation to PVL:
  assert always (waiting(s.send) -> 
    within_t[(1,SC_MS)] active(s.send)); 

  assert always (waiting(ecu_absasr.not_a_main) -> 
    within_t[(1,SC_MS)] active(ecu_absasr.not_a_main)); 

  } psl */
int sc_main (int argc, char* argv[]) 
{

  //  sc_signal<bool>         resetWheels;   
  
  sc_fifo< int >  speed_s;
  

  //  inp.resetAll(resetWheels);

  TickCounter s("s");

    s.out( speed_s );
    
  ABSASR ecu_absasr("absasr");
    ecu_absasr.bus_s( speed_s );
  sc_start(20,SC_MS); // Run the simulation till sc_stop is encountered

  //sc_close_vcd_trace_file(wf);
  return 0; // Terminate simulation

}
