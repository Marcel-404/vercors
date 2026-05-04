# PSL2PVL Case Study
This directory includes the PSL2PVL examples and each experiments that we ran. 
- Automated/ includes the SystemC designs and PVL transformations
- - Each Automated/ example consists of the folders 0-src, 1-VESUV-out, 2-manual, 3-prepare, 4-verify
- - The steps in 3-prepare and 4-verify consist of the steps required to generate the RASI and include it in the Main.pvl
- - Our approach generates the PVL specifications from PSL assertions defined in the main vunit defined above the sc_main function of a SystemC design
- - These transformations are generated along with the VESUV transformation in 1-VESUV-out
- - In 2-manual manual steps defined by the VESUV approach, as well as manual steps to locally set timers for our approach are defined
- run_experiments.sh can be used to run each step in the experiment: Transformation (transform.sh), RASI generation (generate.sh), Verification(verify.sh)

- VESUV-Encoding/ includes the manual specifications performed by the "Automated Invariant Generation for Efficient Deductive Reasoning About Embedded Systems" paper by Tasche, Herber and Huisman.
