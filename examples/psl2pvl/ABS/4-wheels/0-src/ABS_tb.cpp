#include <systemc.h>

#include "TickCounter.h"
#include "ABSASR.h"


/* psl 
vunit main (Main){
  // Properties using within_t:
  assert always active(vl.send) && speed_vl.data_written_event().triggered() -> 
    within_t[(1,SC_MS)] active(ecu_absasr.read_vl) && bus_vl.data_read_event().triggered() && ecu_absasr.v == vl.speed;
  } psl */
int sc_main (int argc, char* argv[]) 
{
  //  sc_signal<bool>         resetWheels;   
  
  sc_fifo< int >  speed_vl, speed_vr, speed_hl, speed_hr;
  

  //  inp.resetAll(resetWheels);

  TickCounter vl("vl");
    vl.out( speed_vl );
    
    
   TickCounter vr("vr");
    vr.out( speed_vr );
         
  TickCounter hl("hl");
    hl.out( speed_hl );
    

  TickCounter hr("hr");
    hr.out( speed_hr );
    
 
  ABSASR ecu_absasr("absasr");
    ecu_absasr.bus_vl( speed_vl );
    ecu_absasr.bus_vr( speed_vr );
    ecu_absasr.bus_hl( speed_hl );
    ecu_absasr.bus_hr( speed_hr );
  sc_start(20,SC_MS); // Run the simulation till sc_stop is encountered

  //sc_close_vcd_trace_file(wf);

  return 0; // Terminate simulation

}
