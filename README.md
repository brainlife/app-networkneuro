[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-bl.app.v1.0-blue.svg)](https://doi.org/10.25663/bl.app.47)

# app-networkneuro

This service cconnecitity matrices using the FreeSurfer output and LiFE output. It uses the FiNE toolbox to create these results, which is distributed as part of the LiFE code. This generates and reports two matrices 

This app takes as inputs a brainlife FreeSurfer output and a brainlife LiFE output and combines them to create a brainlife networkneuro output. The network neuro output consists of a pair of connectivity matrices generated from the Desikan-Killiany (aparc+aseg) cortical labels and the intermediary data created in MATLAB stored as .mat files. The input requirements should ensure that the FreeSurfer output and LiFE output are in alignment. The LiFE output contains the streamlines that have been evaluated with the LiFE algorithm and contains the fiber evaluation (fe) structure that has been previously estimated. The FreeSurfer output is used to create and extract the cortical labels (nodes) to group the streamlines (edges) to create a network structure for evaluation.

The primary results in the networkneuro output structure are the connectivity matrices stored in .csv file format. The itermediary data stored in the .mat files can be used by additional pipelines for further processing and are necessary for debugging. 

2 different measures are used to create the weighted network: streamline density and virtual lesions.

Streamline density is the number of streamlines between 2 regions corrected for the size of the ROIs they are connecting.
Virtual lesions are an evaluation of the diffusion signal explained by a connection based on a forward model fit to the tractography.

### Authors
- Brent McPherson (bcmcpher@iu.edu)

### Contributors
- Soichi Hayashi (hayashis@iu.edu)

### Project director
- Franco Pestilli (franpest@indiana.edu)

### Funding 
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)

### References 
[1. Caiafa and Pestilli. (2017) Multidimensional encoding of brain connectomes. Scientific Reports.](https://www.ncbi.nlm.nih.gov/pubmed/28904382)

[2. Pestilli et al. (2014) Evaluation and statistical inference for human connectomes. Nature Methods.](https://www.ncbi.nlm.nih.gov/pubmed/25194848)

[3. Fischl, B. (2012). FreeSurfer. Neuroimage, 62(2), 774-781.](https://www.sciencedirect.com/science/article/pii/S1053811912000389)

[4. Desikan, R. S., Ségonne, F., Fischl, B., Quinn, B. T., Dickerson, B. C., Blacker, D., ... & Albert, M. S. (2006). An automated labeling system for subdividing the human cerebral cortex on MRI scans into gyral based regions of interest. Neuroimage, 31(3), 968-980.](https://www.sciencedirect.com/science/article/pii/S1053811906000437)

## Running the App 

### On Brainlife.io

You can submit this App online at [https://doi.org/10.25663/bl.app.47](https://doi.org/10.25663/bl.app.47) via the "Execute" tab.

### Running Locally (on your machine)

1. git clone this repo.
2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
        "freesurfer": "./input/freesurfer/output",
	"life": "./input/life/output_fe.mat",
}
```

3. Launch the App by executing `main`

```bash
./main
```

### Sample Datasets

If you don't have your own input file, you can download sample datasets from Brainlife.io, or you can use [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download 5a0e604116e499548135de87 && mv 5a0e604116e499548135de87 input/freesurfer/output
bl dataset download 5a0dcb1216e499548135dd27 && mv 5a0dcb1216e499548135dd27 input/life/output_fe.mat
```

## Output

The main output of this App are 3 .csv connectome files
- count.csv
- density.csv
- emd.csv
representing the streamline count, streamline density, and LiFE network edge weights, respectively.

The files `edge_density.png` and `edge_LiFE.png` are a simple visualization of the of the adjacency networks.

The file called `pconn.mat` contains the "paired connections" output which is a cell array containing all extracted values from the upper diagonal of the network.

The file called `omat.mat' contains all the adjacency networks build by the FiNE process. The dimension are nnodes x nnodes x olabs

The file called `olab.mat` contains the labels that define the measure used in each index of `omat`.

The file called `rois.mat` contains the information stored from the ROIs during the assignment of streamlines and the creation of the different edge weights.

aparc+aseg_labels.nii.gz is the inflated labels used from FreeSurfer as the parcellation to assign streamlines to connections. 

The label names are described in https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI/FreeSurferColorLUT All output csv/mat file contains 68x68 matries. The indecies of theses matrix can be converted to the label name using the following table.

| Idx | Freesufer Label Id | Label Name | R | G | B |
|---|---|---|---|---| --- |
| 0 | 1001 | ctx-lh-bankssts | 25 | 100 | 40 |
| 1 | 1002 | ctx-lh-caudalanteriorcingulate | 125 | 100 | 160 |
| 2 | 1003 | ctx-lh-caudalmiddlefrontal | 100 | 25 | 0 |
| 3 | 1005 | ctx-lh-cuneus | 220 | 20 | 100 |
| 4 | 1006 | ctx-lh-entorhinal | 220 | 20 | 10 |
| 5 | 1007 | ctx-lh-fusiform | 180 | 220 | 140 |
| 6 | 1008 | ctx-lh-inferiorparietal | 220 | 60 | 220 | 
| 7 | 1009 | ctx-lh-inferiortemporal | 180 | 40 | 120 |
| 8 | 1010 | ctx-lh-isthmuscingulate | 140 | 20 | 140 | 
| 9 | 1011 | ctx-lh-lateraloccipital | 20 | 30 | 140 | 
| 10 | 1012 | ctx-lh-lateralorbitofrontal | 35 | 75 | 50 |
| 11 | 1013 | ctx-lh-lingual | 225 | 140 | 140 |
| 12 | 1014 | ctx-lh-medialorbitofrontal | 200 | 35 | 75 |
| 13 | 1015 | ctx-lh-middletemporal | 160 | 100 | 50 |
| 14 | 1016 | ctx-lh-parahippocampal | 20 | 220 | 60 |
| 15 | 1017 | ctx-lh-paracentral | 60 | 220 | 60 |
| 16 | 1018 | ctx-lh-parsopercularis | 220 | 180 | 140 |
| 17 | 1019 | ctx-lh-parsorbitalis | 20 | 100 | 50 |
| 18 | 1020 | ctx-lh-parstriangularis | 220 | 60 | 20 |
| 19 | 1021 | ctx-lh-pericalcarine | 120 | 100 | 60 |
| 20 | 1022 | ctx-lh-postcentral | 220 | 20 | 20 |
| 21 | 1023 | ctx-lh-posteriorcingulate | 220 | 180 | 220 |
| 22 | 1024 | ctx-lh-precentral | 60 | 20 | 220 |
| 23 | 1025 | ctx-lh-precuneus | 160 | 140 | 180 |
| 24 | 1026 | ctx-lh-rostralanteriorcingulate | 80 | 20 | 140 |
| 25 | 1027 | ctx-lh-rostralmiddlefrontal | 75 | 50 | 125 |
| 26 | 1028 | ctx-lh-superiorfrontal | 20 | 220 | 160 |
| 27 | 1029 | ctx-lh-superiorparietal | 20 | 180 | 140 |
| 28 | 1030 | ctx-lh-superiortemporal | 140 | 220 | 220 |
| 29 | 1031 | ctx-lh-supramarginal | 80 | 160 | 20 |
| 30 | 1032 | ctx-lh-frontalpole | 100 | 0 | 100 |
| 31 | 1033 | ctx-lh-temporalpole | 70 | 70 | 70 |
| 32 | 1034 | ctx-lh-transversetemporal | 150 | 150 | 200 |
| 33 | 1035 | ctx-lh-insula | 255 | 192| 32
| 34 | 2001 | ctx-rh-bankssts | 25 | 100 | 40 |
| 35 | 2002 | ctx-rh-caudalanteriorcingulate | 125 | 100 | 160 |
| 36 | 2003 | ctx-rh-caudalmiddlefrontal | 100 | 25 | 0 |
| 37 | 2005 | ctx-rh-cuneus | 220 | 20 | 100 |
| 38 | 2006 | ctx-rh-entorhinal | 220 | 20 | 10 |
| 39 | 2007 | ctx-rh-fusiform | 180 | 220 | 140 |
| 40 | 2008 | ctx-rh-inferiorparietal | 220 | 60 | 220 |
| 41 | 2009 | ctx-rh-inferiortemporal | 180 | 40 | 120 |
| 42 | 2010 | ctx-rh-isthmuscingulate | 140 | 20 | 140 |
| 43 | 2011 | ctx-rh-lateraloccipital | 20 | 30 | 140 |
| 44 | 2012 | ctx-rh-lateralorbitofrontal | 35 | 75 | 50 |
| 45 | 2013 | ctx-rh-lingual | 225 | 140 | 140 |
| 46 | 2014 | ctx-rh-medialorbitofrontal | 200 | 35 | 75 |
| 47 | 2015 | ctx-rh-middletemporal | 160 | 100 | 50 |
| 48 | 2016 | ctx-rh-parahippocampal | 20 | 220 | 60 |
| 49 | 2017 | ctx-rh-paracentral | 60 | 220 | 60 |
| 50 | 2018 | ctx-rh-parsopercularis | 220 | 180 | 140 |
| 51 | 2019 | ctx-rh-parsorbitalis | 20 | 100 | 50 |
| 52 | 2020 | ctx-rh-parstriangularis | 220 | 60 | 20 |
| 53 | 2021 | ctx-rh-pericalcarine | 120 | 100 | 60 |
| 54 | 2022 | ctx-rh-postcentral | 220 | 20 | 20 |
| 55 | 2023 | ctx-rh-posteriorcingulate | 220 | 180 | 220 |
| 56 | 2024 | ctx-rh-precentral | 60 | 20 | 220 |
| 57 | 2025 | ctx-rh-precuneus | 160 | 140 | 180 |
| 58 | 2026 | ctx-rh-rostralanteriorcingulate | 80 | 20 | 140 |
| 59 | 2027 | ctx-rh-rostralmiddlefrontal | 75 | 50 | 125 |
| 60 | 2028 | ctx-rh-superiorfrontal | 20 | 220 | 160 |
| 61 | 2029 | ctx-rh-superiorparietal | 20 | 180 | 140 |
| 62 | 2030 | ctx-rh-superiortemporal | 140 | 220 | 220 |
| 63 | 2031 | ctx-rh-supramarginal | 80 | 160 | 20 |
| 64 | 2032 | ctx-rh-frontalpole | 100 | 0 | 100 |
| 65 | 2033 | ctx-rh-temporalpole | 70 | 70 | 70 |
| 66 | 2034 | ctx-rh-transversetemporal | 150 | 150 | 200 |
| 67 | 2035 | ctx-rh-insula | 255 | 192 | 32 |

#### Product.json

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) to run. If you don't have singularity, you will need to install following dependencies.  

  - VISTASOFT: https://github.com/vistalab/vistasoft/
  - ENCODE: https://github.com/brain-life/encode
  - MBA: https://github.com/francopestilli/mba
  - FiNE: public relsease pending submission

