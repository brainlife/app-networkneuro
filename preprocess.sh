#!/bin/bash

export fsdir=`$SCA_SERVICE_DIR/jq -r '.fsdir' config.json`
module load freesurfer/5.3.0
source $FREESURFER_HOME/SetUpFreeSurfer.sh

echo "Create individual label files..."
mkdir -p labels
export SUBJECTS_DIR=$fsdir
for h in lh rh
do
    mri_annotation2label --subject "." --hemi $h --annotation aparc --outdir labels
    if [ $? -ne 0 ]; then
        echo "mri_annotation2label($h) process failed"
        exit 1 
    fi
done

echo "Register FS atlas to input data space..."
tkregister2 --subject "." \
    --mov $fsdir/mri/rawavg.mgz \
    --noedit \
    --regheader \
    --reg reg.dat
if [ $? -ne 0 ]; then
    echo "tkregister2 process failed"
    exit 1 
fi

echo "Create all left label NIfTIs..."
mkdir -p rois
for h in lh rh
do
    cat $SCA_SERVICE_DIR/roi_labels.txt | while read label
    do
        echo "$label --------------------------- "
        mri_label2vol --subject "." \
            --label labels/$h.$label \
            --o "rois/$h.$label.nii.gz" \
            --hemi $h \
            --reg reg.dat \
            --temp $fsdir/mri/rawavg.mgz \
            --proj frac 0 1 0.1 \
            --fillthresh 0.1
        if [ $? -ne 0 ]; then
            echo "mri_label2vol($h/$label) process failed"
            exit 1 
        fi
    done
done

