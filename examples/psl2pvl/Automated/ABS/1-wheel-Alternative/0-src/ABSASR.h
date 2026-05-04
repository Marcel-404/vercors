/* This is a simple Anti-lock Braking System. The inputs are the
   number of ticks counted within 100 ms at each wheel. Outputs are
   control signals for pressure control (0 - constant pressure, 2 -
   increase pressure, 1 - increase pressure slightly, -1 - decrease
   pressure).

   would be better: move conversion from ticks to velocity to other
   modules, would be easier then to argue with a real refinement
   process (communication, data and time refinement)
*/

#include "settings.h"
#include <systemc.h>

#ifndef ABSASR_H
#define ABSASR_H
#define DEBUG

SC_MODULE(ABSASR) {
   
    //-*-*-*-*-*-*-*-*-*-*-*-*  INTERFACE  *-*-*-*-*-*-*-*-*-*-*-*-

    sc_fifo_in<int> bus_s;

    //-*-*-*-*-*-*-*-*-*-*-*-* LOCAL VARIABLES *-*-*-*-*-*-*-*-*-*-*-*-

    //  int ticks_vr, ticks_vl, ticks_hr, ticks_hl;
    int v[1], a[1];  // current wheel velocity and acceleration
    int temp_fv, fv; // estimated vehicle velocity
    int fa;          // estimated vehicle acceleration
    int lambda[1];   // Slippage at each wheel
    int s[1];        // ABS state per wheel
    int p[1];        // Braking pressure command (see above)

    // ABS Routine
    void _ABS() {
        if (fv > ABSACTIVE) { // ABS is only active above a threshold velocity
            for (int i = 0; i < 1; i = i + 1) {
                lambda[i] = ((fv - v[i]) * 100) / fv;
                switch (s[i]) {
                case 1:
                    if (a[i] < minus_a) {
                        p[i] = 0;
                        s[i] = 2;
                    }
                    break;
                case 2:
                    if (lambda[i] > lambda_abs) {
                        p[i] = -1;
                        s[i] = 3;
                    }
                    break;
                case 3:
                    if (a[i] > minus_a) {
                        p[i] = 0;
                        s[i] = 4;
                    }
                    break;
                case 4:
                    if (a[i] > plus_A) {
                        p[i] = 2;
                        s[i] = 5;
                    }
                    break;
                case 5:
                    if (a[i] < plus_A) {
                        p[i] = 0;
                        s[i] = 6;
                    }
                    break;
                case 6:
                    if (a[i] < plus_a) {
                        p[i] = 1;
                        s[i] = 7;
                    }
                    break;
                case 7:
                    if (a[i] < minus_a) {
                        p[i] = -1;
                        s[i] = 8;
                    }
                    break;
                case 8:
                    if (a[i] > minus_a) {
                        p[i] = 0;
                        s[i] = 4;
                    }
                    break;
                }
            }
        }
    }

    // ASR Routine
    void _ASR() {
        int j = 0; // the first comparison is vl (0) with hr (7)
                   // ASR assumes front wheel drive
        for (int i = 0; i < 1; i = i + 1) {
            if (v[i] > 0) {
                lambda[i] = ((v[i] - v[j]) * 100) / v[i];

                if (lambda[i] > lambda_asr) { // Slippage too high -> brake
                    if (a[i] > 0) {
                        p[i] = 2; // Increase pressure
                    } else {
                        p[i] = 0; // Keep pressure constant
                    }
                } else {       // No slippage -> release brakes
                    p[i] = -1; // Release braking pressure
                }
            }
            j = 0; // the second comparison is vr (1) with hl (6)
        }
    }

    int abs(int val) {
        if (val >= 0)
            return val;
        else
            return -val;
    }

    void not_a_main() {
        int i;
        // INIT
        for (i = 0; i < 1; i = i + 1) {
            s[i] = 1;
            v[i] = 0;
            a[i] = 0;
        }
        while (true) {
            wait(1, SC_MS);

            // Take the velocity of the wheel with the lowest acceleration as a
            // reference for the vehicle velocity
            i = 0;
            temp_fv = v[i];
            fa = temp_fv - fv;

            if (fa < 0) {           //  deceleration
                if (fa < minus_a) { // all wheels are locked -> use different
                                    // estimation for vehicle velocity
                    fv = fv + AREF; // estimated optimal deceleration
                } else
                    fv = temp_fv;
                _ABS();
            } else if (fa > 0) {
                fv = temp_fv;
                _ASR();
            }
        }
    }
    void read_s() {
        int tmp_0 = 0;
        while (true) {
            v[0] = bus_s.read();
            //  v[0] = VELOFACTOR * ticks_vr;
            a[0] = (v[0] - tmp_0); //*VELOFACTOR;
            tmp_0 = v[0];
        }
    }
    
    //-*-*-*-*-*-*-*-*-*-*-*-*-*-* KONSTRUKTOR *-*-*-*-*-*-*-*-*-*-*-*-*-*-

    SC_CTOR(ABSASR) {
        SC_THREAD(not_a_main);
        // read in the ticks and calculate a and v
        SC_THREAD(read_s);
    }
};
#endif