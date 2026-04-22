#include <systemc.h>

#include "TickCounter.h"
#include "ABSASR.h"

#define DEBUG

/* psl 
vunit main(Main){
  assert always (active(s.send) && speed_s.written() -> 
    within_t[(1,SC_MS)] active(ecu_absasr.read_s) && speed_s.read() && ecu_absasr.v[0] == s.send.speed);

  assert never (
  waiting(s.send) && 
  waiting(ecu_absasr.not_a_main) && 
  waiting(ecu_absasr.read_s) && 

  speed_s.data_read_event().not_notified() && 
  speed_s.data_written_event().not_notified() && 
  s.send.wait_event().not_notified() && 
  ecu_absasr.not_a_main.wait_event().not_notified() &&
  ecu_absasr.read_s.wait_event().not_notified());// Does not exist but can be wrongly specified
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
