#!/usr/bin/python

import vtk
import sys
import os
import json
import pandas as pd

if not os.path.exists("surfaces"):
   os.makedirs("surfaces")

#lut = pd.read_csv('FreeSurferColorLUT.csv')
with open("labels.json") as f:
    labels = json.load(f)
img_path = 'aparc+aseg.nii.gz'

# import the binary nifti image
print("loading %s" % img_path)
reader = vtk.vtkNIFTIImageReader()
reader.SetFileName(img_path)
reader.Update()

for label in labels["labels"]:
    label_id=int(label["label"])

    #only handle some surfaces
    if label_id < 1000 or label_id > 2036:
        continue

    surf_name='surfaces/'+label['label']+'.'+label['name']+'.vtk'
    print(surf_name)

    # do marching cubes to create a surface
    surface = vtk.vtkDiscreteMarchingCubes()
    surface.SetInputConnection(reader.GetOutputPort())

    # GenerateValues(number of surfaces, label range start, label range end)
    surface.GenerateValues(1, label_id, label_id)
    surface.Update()

    smoother = vtk.vtkWindowedSincPolyDataFilter()
    smoother.SetInputConnection(surface.GetOutputPort())
    smoother.SetNumberOfIterations(10)
    smoother.NonManifoldSmoothingOn()
    smoother.NormalizeCoordinatesOn()
    smoother.Update()

    connectivityFilter = vtk.vtkPolyDataConnectivityFilter()
    connectivityFilter.SetInputConnection(smoother.GetOutputPort())
    connectivityFilter.SetExtractionModeToLargestRegion()
    connectivityFilter.Update()

    # Center the output data at 0 0 0
    untransform = vtk.vtkTransform()
    untransform.SetMatrix(reader.GetQFormMatrix())
    untransformFilter=vtk.vtkTransformPolyDataFilter()
    untransformFilter.SetTransform(untransform)
    untransformFilter.SetInputConnection(connectivityFilter.GetOutputPort())
    untransformFilter.Update()

    cleaned = vtk.vtkCleanPolyData()
    cleaned.SetInputConnection(untransformFilter.GetOutputPort())
    cleaned.Update()

    writer = vtk.vtkPolyDataWriter()
    writer.SetInputConnection(cleaned.GetOutputPort())
    writer.SetFileName(surf_name)
    writer.Write()

