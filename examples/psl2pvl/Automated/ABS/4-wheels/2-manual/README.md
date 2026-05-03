The first two entries of this README.md are entries from the artifact in the paper "Automated Invariant Generation for Efficient Deductive Reasoning About Embedded Systems" by Tasche, Herber and Huisman
The last entry represents the manual effort, that is required for our approach to verify the generated properties.

Some manual effort is required to make the program verifiable, optimize it and to encode the desired properties.

### Optimization

VeSUV cannot in general apply all optimizations that make verification with VerCors faster without altering the semantics of the design. These need to be manually encoded.

For the ABS/ASR example, this means
- Replacing the arrays in `Absasr.pvl` with PVL's `seq` type
- Making the loop variables in `Absasr.pvl` and `Absasr_not_a_main.pvl` local

- [Additional Info] Since each array in `Absasr.pvl` has been replaced by PVL's `seq` type, each time the variables have to be accessed differently:
- - Instead of ARRAY[i] = x -> ARRAY = ARRAY.update(i, x)
- - Therefore, also each Perm(ARRAY, read) -> Perm(ARRAY, write)
- This has to be done for `Absasr.pvl`, `Absasr_not_a_main.pvl` and  `Absasr_read_s.pvl`
- [Additional Info] Moreover, for each Perm(this.arrray, read) -> (this.arrray, write) 
- [Additional Info] Moreover, for each Perm(this.m.invariant,1) -> this.m.invariant()


### Verification

VeSUV generates almost all specifications necessary for verification, including permissions. However, there are still some small adjustments necessary for verification.

For the ABS/ASR example, this means
- Adding loop bounds to the loops in `Absasr.pvl` and `Absasr_not_a_main.pvl`
- Assigning a nondeterministic nonnegative value to the `buffer_size` in `Main.pvl`


### Property Verification

To enable the verification of the generated PVL properties from the PSL assertions, some manual effort is required. 
For each property using the within_t operator, an entry in the global arrays timer_set, timer_reset and timer_value are created.
The entries in the global variables are encoded in such a way, that the order of the within_t specification corresponds to the order in these arrays.
However, the timer operations, such as setting and resetting the timer need to be manually defined.

For instance, for the given timely reaction property, this means:
- A timer has to be set for each `Tickcounter_x_send.pvl` and its new value saved after line 74 `this.m.sc_fifo_int_speed_x.fifo_write(this.speed_send);` , where x \in \[vl,vr,hl,hr\] 
- This is encoded as: 
- - this.m.timer_set = this.m.timer_set.update(j,true);,
- - this.m.timer_value = this.m.timer_value.update(j,1);
- - this.m.event_state = this.m.event_state.update(i,1);, where j \in \[0,1,2,3\], where i == 13+j

- Moreover, the timer has to be reset in `Absasr_read_x.pvl` and its current value saved after line 61 `this.tmp_0_read_s = this.m.ecu_absasr_absasr.v[0];` , where x \in \[vl,vr,hl,hr\]
- This is encoded as:
- - this.m.timer_value = this.m.timer_value.update(j,this.m.event_state[i]);
- - this.m.timer_value = this.m.timer_reset.update(j,false);
- - this.m.event_state = this.m.event_state.update(i,-3);, where j \in \[0,1,2,3\], where i == 13+j
