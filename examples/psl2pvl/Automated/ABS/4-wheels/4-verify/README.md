### Manual Steps
The following steps are needed to ensure the verification of the example, as defined by the paper "Automated Invariant Generation for Efficient Deductive Reasoning About Embedded Systems" by Tasche, Herber and Huisman

- Make min_advance in Main.pvl a local variable again
- Thereby, remove min_advance = 0 in constructor
- Furthermore add `rasi1.pvl`, `rasi2.pvl`, `rasi3.pvl`, `rasi1.pvl` as invariants before global invariant 
- Lastly, add reference to each `this.reachable_abstract_states_invariant()` before this.psl_invariant() reference in the global_invariant()
