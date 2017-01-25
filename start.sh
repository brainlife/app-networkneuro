#!/bin/bash

#this allows running this script locally (for development)
if [ -z $SCA_WORKFLOW_DIR ]; then export SCA_WORKFLOW_DIR=`pwd`; fi
if [ -z $SCA_TASK_DIR ]; then export SCA_TASK_DIR=`pwd`; fi
if [ -z $SCA_SERVICE_DIR ]; then export SCA_SERVICE_DIR=`pwd`; fi

#clean up previous job (just in case)
rm -f finished
jobid=`qsub $SCA_SERVICE_DIR/submit.pbs`
echo $jobid > jobid

