#!/bin/bash

module unload matlab
module load matlab/2019a

log=compiled/commit_ids.txt
true > $log

echo "/N/u/brlife/git/jsonlab" >> $log
(cd /N/u/brlife/git/jsonlab && git log -1) >> $log

echo "/N/soft/mason/SPM/spm8" >> $log
(cd /N/soft/mason/SPM/spm8 && git log -1) >> $log

echo "/N/u/hayashis/git/vistasoft" >> $log
(cd /N/u/hayashis/git/vistasoft && git log -1) >> $log

echo "/N/u/brlife/git/encode" >> $log
(cd /N/u/brlife/git/encode && git log -1) >> $log

#echo "/N/u/brlife/git/fine" >> $log
#(cd /N/u/brlife/git/fine && git log -1) >> $log

cat > build.m <<END
addpath(genpath('/N/u/brlife/git/vistasoft'))
addpath(genpath('/N/soft/mason/SPM/spm8'))
addpath(genpath('/N/u/brlife/git/jsonlab'))
addpath(genpath('/N/u/brlife/git/encode'))
mcc -m -R -nodisplay -d compiled main
exit
END

matlab -nodisplay -nosplash -r build && rm build.m
