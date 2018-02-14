#!/bin/bash

## load singularity
module load singularity 2> /dev/null

## parse argument for path to file
export fsdir=`$SERVICE_DIR/jq -r '.fsdir' config.json`

echo "Create subject labels..."

## run file conversion docker
singularity exec -e docker://brainlife/freesurfer mri_convert $fsdir/mri/aparc+aseg.mgz --out_orientation RAS aparc+aseg.nii.gz

