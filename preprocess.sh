#!/bin/bash

## load singularity
#module load singularity 2> /dev/null

## parse argument for path to file
export fsdir=`$SERVICE_DIR/jq -r '.fsdir' config.json`

echo "Create subject labels..."

fmgz=$fsdir/mri/aparc+aseg.mgz

echo Converting $fmgz into a .nii.gz now...

## run file conversion docker
#singularity exec -e docker://brainlife/freesurfer mri_convert $fmgz --out_orientation RAS aparc+aseg.nii.gz
mri_convert $fmgz --out_orientation RAS aparc+aseg.nii.gz

echo Done converting labels.
