### Manual Steps

Make min_advance in Main.pvl a global variable temporarily
Afterwards, make the variable local again, add the RASI to Main.pvl and reference the invariant in the global_invariant before the psl_invariant reference.
