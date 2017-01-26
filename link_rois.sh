#!/bin/bash

## Brent McPherson
## 20170123
## symlink ROIs into anat folder
##

## build paths
SUBJ=$1
TOPDIR=/N/dc2/projects/lifebid/glue
ROIDIR=$TOPDIR/subjects/$SUBJ/anat/DKAtlas

## make ROI dir for linking
mkdir $ROIDIR

## I could do a loop over an array if I understood those any better in bash
## this preserves the sort order I originally used.

## for every ROI, create symlink in anat
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_superiorfrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_rostralmiddlefrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_caudalmiddlefrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_parsopercularis_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_parsorbitalis_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_parstriangularis_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_lateralorbitofrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_medialorbitofrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_precentral_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_paracentral_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_frontalpole_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_rostralanteriorcingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_caudalanteriorcingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_insula_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_superiorparietal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_inferiorparietal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_supramarginal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_postcentral_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_precuneus_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_posteriorcingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_isthmuscingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_inferiortemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_middletemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_superiortemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_bankssts_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_fusiform_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_transversetemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_entorhinal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_temporalpole_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_parahippocampal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_lateraloccipital_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_lingual_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_cuneus_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/lh_pericalcarine_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_superiorfrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_rostralmiddlefrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_caudalmiddlefrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_parsopercularis_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_parsorbitalis_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_parstriangularis_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_lateralorbitofrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_medialorbitofrontal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_precentral_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_paracentral_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_frontalpole_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_rostralanteriorcingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_caudalanteriorcingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_insula_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_superiorparietal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_inferiorparietal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_supramarginal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_postcentral_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_precuneus_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_posteriorcingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_isthmuscingulate_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_inferiortemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_middletemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_superiortemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_bankssts_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_fusiform_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_transversetemporal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_entorhinal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_temporalpole_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_parahippocampal_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_lateraloccipital_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_lingual_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_cuneus_label.nii.gz $ROIDIR/ 
ln -s $TOPDIR/freesurfer/$SUBJ/label/rh_pericalcarine_label.nii.gz $ROIDIR/

#ln -s $TOPDIR/freesurfer/$SUBJ/label/*.nii.gz $ROIDIR/ 