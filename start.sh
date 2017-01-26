#!/bin/bash

#this allows running this script locally (for development)
if [ -z $SCA_WORKFLOW_DIR ]; then export SCA_WORKFLOW_DIR=`pwd`; fi
if [ -z $SCA_TASK_DIR ]; then export SCA_TASK_DIR=`pwd`; fi
if [ -z $SCA_SERVICE_DIR ]; then export SCA_SERVICE_DIR=`pwd`; fi

#make sure jq is installed on $SCA_SERVICE_DIR (will be used in submit.pbs?)
if [ ! -f $SCA_SERVICE_DIR/jq ];
then
        echo "installing jq"
        wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O $SCA_SERVICE_DIR/jq
        chmod +x $SCA_SERVICE_DIR/jq
fi

#clean up previous job (just in case)
rm -f finished
jobid=`qsub $SCA_SERVICE_DIR/submit.pbs`
echo $jobid > jobid

