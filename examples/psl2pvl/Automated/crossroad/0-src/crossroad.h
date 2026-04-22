//****************************************************
//  Crossroad example
//****************************************************

#include "systemc.h"
#include <math.h>

#ifndef _CROSSROAD_H_
#define _CROSSROAD_H_

enum direction {
    forward = 0,
    left = 1,
    right = 2,
    none = 3 // no car
};

// LCOV_EXCL_BR_START
SC_MODULE(crossroads) {
    // Event for directions
    sc_event direction_changed;

    // Directions of cars from all 4 sides of crossroads
    direction x[4];

    void drive(int id) {
        while (true) {
            // Generate direction
            // Data race error (Read-Write) with lines 15, 34, 45
            x[id] = (direction)(random() % 4);
            direction_changed.notify(0, SC_NS); // LCOV_EXCL_BR_LINE
            wait(0, SC_NS);                     // LCOV_EXCL_BR_LINE

            switch (x[id]) {
            case forward:
                move_forward(id);
                break;
            case left:
                move_left(id);
                break;
            case right:
            case none:; // nothing to do
            }
        }
    }

    // Forward direction handler
    void move_forward(int id) {
        int right_index = (id - 1 + 4) % 4;

        // waiting for none right car
        while (x[right_index] != none) {
            wait(direction_changed); // LCOV_EXCL_BR_LINE
        }
    }

    // Left direction handler
    void move_left(int id) {
        int right_index = (id - 1 + 4) % 4;
        int forward_index = (id + 2) % 4;

        // waiting for none right car and none forward car
        while (x[right_index] != none || x[forward_index] != none) {
            wait(direction_changed); // LCOV_EXCL_BR_LINE
        }
    }

    // Process(es)
    void north() { drive(0); }
    void east() { drive(1); }
    void south() { drive(2); }
    void west() { drive(3); }

    // Constructor
    SC_CTOR(crossroads) {
        SC_THREAD(north);
        SC_THREAD(east);
        SC_THREAD(south);
        SC_THREAD(west);
    }
};
// LCOV_EXCL_BR_STOP

#endif
