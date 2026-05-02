#include <systemc.h>

#include "TickCounter.h"
#include "ABSASR.h"
/* psl
vunit main(Main){
assert always (active(vr.send) && speed_vr.num_written == 1 -> 
  within_t(1,SC_MS) active(ecu_absasr.read_vr) && speed_vr.num_read == 1 && ecu_absasr.v[0] == vr.send.speed);

assert always (active(vl.send) && speed_vl.num_written == 1 -> 
  within_t(1,SC_MS) active(ecu_absasr.read_vl) && speed_vl.num_read == 1 && ecu_absasr.v[1] == vl.send.speed);

assert always (active(hr.send) && speed_hr.num_written == 1 -> 
  within_t(1,SC_MS) active(ecu_absasr.read_hr) && speed_hr.num_read == 1 && ecu_absasr.v[2] == hr.send.speed);
    
assert always (active(hl.send) && speed_hl.num_written == 1 -> 
  within_t(1,SC_MS) active(ecu_absasr.read_hl) && speed_hl.num_read == 1 && ecu_absasr.v[3] == hl.send.speed);
  


  assert never (
  waiting(vl.send) && 
  waiting(vr.send) && 
  waiting(hr.send) && 
  waiting(hl.send) && 

  waiting(ecu_absasr.read_vr) && 
  waiting(ecu_absasr.read_vl) && 
  waiting(ecu_absasr.read_hl) && 
  waiting(ecu_absasr.read_hr) && 

  waiting(ecu_absasr.not_a_main) && 

  not_notified(speed_vr.data_read_event()) &&
  not_notified(speed_vl.data_read_event()) && 
  not_notified(speed_hl.data_read_event()) &&
  not_notified(speed_hr.data_read_event()) &&

  not_notified(speed_vr.data_written_event()) && 
  not_notified(speed_vl.data_written_event()) && 
  not_notified(speed_hr.data_written_event()) && 
  not_notified(speed_hl.data_written_event()) && 

  not_notified(vr.send.wait_event()) &&
  not_notified(vl.send.wait_event()) && 
  not_notified(hr.send.wait_event()) &&
  not_notified(hl.send.wait_event()) &&
  not_notified(ecu_absasr.not_a_main.wait_event()));
}
psl */
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
