#!/bin/bash

export fsdir=`$SCA_SERVICE_DIR/jq -r '.fsdir' config.json`

module load freesurfer/5.3.0
source $FREESURFER_HOME/SetUpFreeSurfer.sh
#module load fsl

echo "Create individual label files..."
mkdir -p labels
export SUBJECTS_DIR=$fsdir
mri_annotation2label --subject "." --hemi lh --annotation aparc --outdir labels
mri_annotation2label --subject "." --hemi rh --annotation aparc --outdir labels

echo "Register FS atlas to input data space..."
tkregister2 --subject "." \
    --mov $fsdir/mri/rawavg.mgz \
    --noedit \
    --regheader \
    --reg reg.dat

echo "Create all left label NIfTIs..."
mkdir -p rois
for h in lh rh
do
    cat $SCA_SERVICE_DIR/roi_labels.txt | while read label
    do
        echo $label
        mri_label2vol --subject "." \
            --label labels/$h.$label \
            --o "rois/$h.$label.nii.gz" \
            --hemi $h \
            --reg reg.dat \
            --temp $fsdir/mri/rawavg.mgz \
            --proj frac 0 1 0.1 \
            --fillthresh 0.1
    done
done

