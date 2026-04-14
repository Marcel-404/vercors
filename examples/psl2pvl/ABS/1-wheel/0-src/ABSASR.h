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

/* psl
vunit absasr {
    int wheels = sizeof(v)/sizeof(v[0]);

    // _ABS
    property abs_values_stable = (stable(v) && stable(a) && stable(fv) &&
stable(fa)); assert always (active(_ABS()) -> abs_values_stable);

    property low_speed = (fv <= 22 -> next (stable(lambda) && stable(p) &&
stable(s))); assert always (active(_ABS()) -> low_speed);

    property correct_slippage = (fv > 22 -> forall z in {0..wheels-1}:
      (next (lambda[z] == ((fv-v[z]) * 100 / fv)));
    assert always (active(_ABS()) -> correct_slippage);

    property abs_state1 = (fv > 22 -> forall z in {0:wheels-1}:
      ((a[z] < - 14 && s[z] == 1) -> next (p[z] == 0 && s[z] == 2)));
    assert always (active(_ABS()) -> abs_state1);

    property abs_state2 = (fv > 22 -> forall z in {0:wheels-1}:
      ((s[z] == 2 && lambda[z] > 13) -> next (p[z] == -1 && s[z] == 3)));
    assert always (active(_ABS()) -> abs_state2);

    property abs_state3 = (fv > 22 -> forall z in {0:wheels-1}:
      ((a[z] > - 14 && s[z] == 3) -> next (p[z] == 0 && s[z] == 4)));
    assert always (active(_ABS()) -> abs_state3);

    property abs_state4 = (fv > 22 -> forall z in {0:wheels-1}:
      ((a[z] > 98 && s[z] == 4) -> next (p[z] == 2 && s[z] == 5)));
    assert always (active(_ABS()) -> abs_state4);

    property abs_state5 = (fv > 22 -> forall z in {0:wheels-1}:
      ((a[z] < 98 && s[z] == 5) -> next (p[z] == 0 && s[z] == 6)));
    assert always (active(_ABS()) -> abs_state5);

    property abs_state3 = (fv > 22 -> forall z in {0:wheels-1}:
      ((a[z] < 2 && s[z] == 6) -> next (p[z] == 1 && s[z]==7)));
    assert always (active(_ABS()) -> abs_state3);

    property abs_state7 = (fv > 22 -> forall z in {0:wheels-1}:
      ((a[z] < - 14 && s[z]) == 7) -> next (p[z] == -1 && s[z] == 8)));
    assert always active(_ABS)) -> abs_state7;

    property abs_state8 = (fv > 22 -> forall z in {0:wheels-1}:
      ((a[z] > - 14 && s[z] == 8) -> next (p[z] == 0 && s[z] == 4)));
    assert always (active(_ABS()) -> abs_state8);

    // ASR

    property asr_values_stable = (stable(v) && stable(a) && stable(fv) &&
stable(fa) && stable(s)); assert always (active(_ASR()) -> asr_values_stable);

    property noslippage = forall z in {0:wheels-1}:
      ((v[z] > 0 && (v[z] - v[wheels - z - 1]) * 100 / v[z] <= 13) -> next p[z]
< 0); assert always (active(_ASR()) -> noslippage);

    property slippage_but_not_wheel_accelerating = forall z in {0:wheels-1}:
      ((v[z] > 0 && (v[z] - v[wheels - z - 1]) * 100 / v[z] > 13 && a[z] <= 0)
-> next p[z] == 0); assert always (active(_ASR()) ->
slippage_but_not_wheel_accelerating);

    property slippage_and_wheel_accelerating = forall z in {0:wheels-1}:
      ((v[z] > 0 && (v[z] - v[wheels - z - 1])* 100 / v[z] > 13 && a[z] > 0) ->
next p[z] > 0); assert always (active(_ASR()) ->
slippage_and_wheel_accelerating);
}
psl */

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
        // psl assert always true;
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
        // psl assert always true;
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
