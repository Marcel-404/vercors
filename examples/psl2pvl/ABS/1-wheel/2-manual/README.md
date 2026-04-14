Some manual effort is required to make the program verifiable, optimize it and to encode the desired properties.

### Optimization

VeSUV cannot in general apply all optimizations that make verification with VerCors faster without altering the semantics of the design. These need to be manually encoded.

For the ABS/ASR example, this means
- Replacing the arrays in `Absasr.pvl` with PVL's `seq` type
- Making the loop variables in `Absasr.pvl` and `Absasr_not_a_main.pvl` local

The optimized program can be found in `./optimized`.

### Verification

VeSUV generates almost all specifications necessary for verification, including permissions. However, there are still some small adjustments necessary for verification.

For the ABS/ASR example, this means
- Adding loop bounds to the loops in `Absasr.pvl` and `Absasr_not_a_main.pvl`
- Assigning a nondeterministic nonnegative value to the `buffer_size` in `Main.pvl`

The verifiable program can be found in `./verifiable`.

### Properties

Generated along with VESUV transformation depending on PSL definitions

We encode the same properties as in _Deductive Verification of Parameterized Embedded Systems Modeled in SystemC_ (VMCAI 2024), that is:
- Correct functioning of the initialization in `Absasr_not_a_main.pvl`
- Adherence to the ABS and ASR state machine specifications of the respective algorithms
- Deadlock freedom
- For each tick counter:
    - The signal takes less than 1ms to reach the ECU module
    - The received signal matches the sensor output

The program with encoded properties can be found in `./encoded`.
