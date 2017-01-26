#!/bin/bash

#pull fsdir from config.json

module load freesurfer/5.3.0

mkdir -p labels

## convert annotation files to individual ROI labels
echo "Create individual label files..."

export SUBJECTS_DIR=`$SCA_SERVICE_DIR/jq -r '.fsdir' config.json`
echo "using SUBJECT_DIR:$SUBJECTS_DIR to create labels"
#mri_annotation2label --subject "." --hemi lh --annotation aparc --outdir labels
#mri_annotation2label --subject "." --hemi rh --annotation aparc --outdir labels

echo "Register FS atlas to input data space..."
#tkregister2 --subject "." \
#    --mov $SUBJECTS_DIR/mri/rawavg.mgz \
#    --noedit \
#    --regheader \
#    --reg reg.dat

## for every left label...
echo "Create all left label NIfTIs..."

mkdir -p rois
cat $SCA_SERVICE_DIR/roi_labels.txt | while read label
do
    echo $label
    mri_label2vol --subject "." \
        --label labels/$label \
        --o "rois" \
        --hemi lh \
        --reg reg.dat \
        --temp $SUBJECTS_DIR/mri/rawavg.mgz \
        --proj frac 0 1 0.1 \
        --fillthresh 0.1
done

