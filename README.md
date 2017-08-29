[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.0-green.svg)](https://github.com/soichih/abcd-spec)

# app-networkneuro

Any preprocessing script should go to `submit.pbs`, but you can't run this locally.

`main.m` is the main matlab script. Add other matlab script here, but call them from main.m. To run `main.m` locally (for development purpose), simply run `main` in matlab.
 
Or to submit via PBS (like SCA-wf would do) run `./start.sh` on BigRed2

The configuration parameter will be passed in via `config.json`. `main.m` parses this and pull input parameters.

You can write any output data to the current directory.

To clean up files, run `./clean.sh`. Please add any files output to `clean.sh` to clean it
