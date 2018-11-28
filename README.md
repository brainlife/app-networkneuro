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


#### Product.json

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing. 

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) to run. If you don't have singularity, you will need to install following dependencies.  

  - VISTASOFT: https://github.com/vistalab/vistasoft/
  - ENCODE: https://github.com/brain-life/encode
  - MBA: https://github.com/francopestilli/mba
  - FiNE: public relsease pending submission

