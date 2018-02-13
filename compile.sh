#!/bin/bash

module load matlab/2017a

mkdir -p compiled

matlab -nodisplay -nosplash -r build.m
