#include "consumer.h"
#include "producer.h"
#include <systemc.h>

int sc_main(int argc, char *argv[]) {

    sc_fifo<int> fifo_inst;

    producer prod("p");
    prod.fifo(fifo_inst);

    consumer cons("cons");
    cons.fifo(fifo_inst);
    sc_start(5000, SC_NS);

    return 0;
}
