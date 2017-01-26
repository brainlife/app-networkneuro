#!/bin/bash

## Brent McPherson
## 20160916
##
## re-writing the conversion of FS annotations to labels to niftis because the matlab script that will supposedly do it stopped working - 
## because MATLAB should NEVER be used as a scripting language for external commands

SUBJ=$1
TOPDIR=$SUBJECTS_DIR/$SUBJ
LABDIR=$TOPDIR/label
OUTDIR=$TOPDIR/label

## convert annotation files to individual ROI labels
echo "Create individual label files..."
mri_annotation2label --subject $SUBJ --hemi lh --annotation $LABDIR/lh.aparc.annot --outdir $OUTDIR
mri_annotation2label --subject $SUBJ --hemi rh --annotation $LABDIR/rh.aparc.annot --outdir $OUTDIR

## register FS space back to raw ACPC space
echo "Register FS atlas to input data space..."
tkregister2 --subject $SUBJ --mov $TOPDIR/mri/rawavg.mgz --noedit --regheader --reg $TOPDIR/reg.dat

## for every left label...
echo "Create all left label NIfTIs..."
for i in $LABDIR/lh*.label; do
    #echo $i
    out=$(echo $i | sed 's/\./_/g');
    #out=$(echo $out | sed 's/_label/.nii.gz/g');
    out=${out}.nii.gz
    #echo $out
    mri_label2vol --subject $SUBJ --label $i --o $out --hemi lh --reg $TOPDIR/reg.dat --temp $TOPDIR/mri/rawavg.mgz --proj frac 0 1 0.1 --fillthresh 0.1; 
done;

## for every right label...
echo "Create all right label NIfTIs..."
for i in $LABDIR/rh*.label; do
    #echo $i
    out=$(echo $i | sed 's/\./_/g');
    #out=$(echo $out | sed 's/_label/.nii.gz/g');
    out=${out}.nii.gz
    #echo $out
    mri_label2vol --subject $SUBJ --label $i --o $out --hemi rh --reg $TOPDIR/reg.dat --temp $TOPDIR/mri/rawavg.mgz --proj frac 0 1 0.1 --fillthresh 0.1; 
done;

echo "Done!"
