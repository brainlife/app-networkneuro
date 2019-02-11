#!/bin/bash

export fsdir=`$SERVICE_DIR/jq -r '.fsdir' config.json`

echo "Create subject labels..."

fmgz=$fsdir/mri/aparc+aseg.mgz

echo Converting $fmgz into a .nii.gz now...

mri_convert $fmgz --out_orientation RAS aparc+aseg.nii.gz

echo Done converting labels.
