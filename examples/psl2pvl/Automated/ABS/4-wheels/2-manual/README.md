This README.md is copied from the artifact in the paper "Automated Invariant Generation for Efficient Deductive Reasoning About Embedded Systems" by Tasche, Herber and Huisman

Some manual effort is required to make the program verifiable, optimize it and to encode the desired properties.

### Optimization

VeSUV cannot in general apply all optimizations that make verification with VerCors faster without altering the semantics of the design. These need to be manually encoded.

For the ABS/ASR example, this means
- Replacing the arrays in `Absasr.pvl` with PVL's `seq` type
- Making the loop variables in `Absasr.pvl` and `Absasr_not_a_main.pvl` local


### Verification

VeSUV generates almost all specifications necessary for verification, including permissions. However, there are still some small adjustments necessary for verification.

For the ABS/ASR example, this means
- Adding loop bounds to the loops in `Absasr.pvl` and `Absasr_not_a_main.pvl`
- Assigning a nondeterministic nonnegative value to the `buffer_size` in `Main.pvl`

