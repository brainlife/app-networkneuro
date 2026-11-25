<h1 align="center">Network Neuro</h1>

<p align="center">
  Structural connectivity matrices weighted by streamline density and LiFE virtual-lesion evidence, from a LiFE-evaluated tractogram and the FreeSurfer Desikan-Killiany parcellation.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/bl.app.47"><img src="https://img.shields.io/badge/Brainlife-bl.app.47-blue.svg" alt="Run on brainlife.io"></a>
  <a href="https://github.com/brainlife/app-networkneuro/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> **This branch, `1.3`, is the brainlife.io App Network Neuro** ([doi:10.25663/bl.app.47](https://doi.org/10.25663/bl.app.47)).

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Builds structural connectivity matrices from a LiFE-evaluated tractogram and the FreeSurfer aparc+aseg parcellation with the FiNE toolbox, weighted by streamline density and virtual lesion strength.**

Converts the FreeSurfer aparc+aseg to NIfTI, assigns the LiFE-weighted streamlines to region pairs and computes connectivity matrices weighted by streamline density (corrected for ROI size) and by virtual lesion evidence, saving them as CSV and MAT files with region surfaces (VTK) for visualisation. Use it to obtain structural networks when a LiFE model has been fit to the tractography; it needs a FreeSurfer output and a LiFE output from the same subject.

| | |
|---|---|
| **Inputs** | `neuro/freesurfer` · `neuro/LiFE` |
| **Outputs** | `neuro/networkneuro` |
| **Container** | `brainlife/freesurfer:6.0.0` |
| **Resources** | 8 CPUs · 58 GB memory |
| **Requires** | `FREESURFER_LICENSE` |
| **Run it** | [doi.org/10.25663/bl.app.47](https://doi.org/10.25663/bl.app.47) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `freesurfer` | `neuro/freesurfer` | yes | FreeSurfer output; its aparc+aseg parcellation defines the network nodes. |
| `life` | `neuro/LiFE` | yes | Fitted LiFE model (fe structure) with streamline weights for the tractogram. |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `fine` | `neuro/networkneuro` | networkneuro output: connectivity matrices (CSV) weighted by streamline density and virtual lesion, intermediate MAT files and node surfaces for visualisation. |

<!-- brainlife-app:end -->

## Running the App

### On brainlife.io

Open the App at [doi.org/10.25663/bl.app.47](https://doi.org/10.25663/bl.app.47), choose a `neuro/freesurfer` output and a `neuro/LiFE` output of the same subject, and press **Execute**. The inputs must be in alignment: the LiFE output holds the streamlines evaluated with LiFE and the fitted fibre evaluation (`fe`) structure, and the FreeSurfer output provides the cortical labels (nodes) used to group the streamlines (edges) into a network.

The App uses the FiNE toolbox, distributed as part of the LiFE code, to build two weighted networks from the Desikan-Killiany (`aparc+aseg`) cortical labels:

- **streamline density**: the number of streamlines between two regions, corrected for the size of the ROIs they connect;
- **virtual lesion**: the diffusion signal explained by a connection, based on the forward model fit to the tractography.

The result is a `neuro/networkneuro` dataset. The connectivity matrices are stored as CSV files; the intermediate MATLAB files can be used by further pipelines and are needed for debugging.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/), [`jq`](https://jqlang.github.io/jq/) and a [FreeSurfer license](https://surfer.nmr.mgh.harvard.edu/registration.html). FreeSurfer 6.0.0, the compiled MATLAB code (MATLAB Runtime R2017a) and a Python VTK environment run inside containers.

1. Clone this repository and check out the branch brainlife.io runs: `git checkout 1.3`.
2. Create `config.json` with the paths to your inputs:

   ```json
   {
       "fsdir": "./input/freesurfer/output",
       "fe": "./input/life/output_fe.mat"
   }
   ```

3. Export your license and run the App:

   ```bash
   export FREESURFER_LICENSE="$(cat ~/freesurfer/license.txt)"
   ./main
   ```

### Sample data

Download a sample FreeSurfer and LiFE output from brainlife.io with the [brainlife CLI](https://github.com/brainlife/cli):

```bash
npm install -g brainlife
bl login
mkdir -p input/freesurfer input/life
bl dataset download 5a0e604116e499548135de87 && mv 5a0e604116e499548135de87 input/freesurfer/output
bl dataset download 5a0dcb1216e499548135dd27 && mv 5a0dcb1216e499548135dd27 input/life/output_fe.mat
```

## Outputs

```text
output/
├── count.csv                  streamline count
├── density.csv                streamline density
├── emd.csv                    LiFE (virtual lesion) edge weights
├── edge_density.png           quick view of the density network
├── edge_LiFE.png              quick view of the LiFE network
├── pconn.mat                  paired connections: all values from the upper triangle of the network
├── omat.mat                   all adjacency matrices built by FiNE (nnodes × nnodes × measures)
├── olab.mat                   the measure stored in each index of omat
├── rois.mat                   ROI information from streamline assignment and edge weighting
└── aparc+aseg_labels.nii.gz   inflated FreeSurfer labels used as the parcellation
```

The App also writes region surfaces (VTK) for visualisation on brainlife.io. All CSV and MAT matrices are 68 × 68. Label names follow the [FreeSurferColorLUT](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI/FreeSurferColorLUT); matrix indices map to labels as follows.

<details>
<summary>Matrix index to FreeSurfer label</summary>

| Idx | FreeSurfer label ID | Label Name | R | G | B |
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
| 33 | 1035 | ctx-lh-insula | 255 | 192 | 32 |
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

</details>

## Troubleshooting

- **`output missing`**: `output/pconn.mat` was not produced. Check that the LiFE and FreeSurfer inputs come from the same subject and are aligned.
- **`Please set FREESURFER_LICENSE in .bashrc`**: export the contents of your FreeSurfer `license.txt` as `FREESURFER_LICENSE` before running `./main`.

## Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Caiafa CF, Pestilli F. Multidimensional encoding of brain connectomes. *Scientific Reports* (2017). [PubMed 28904382](https://www.ncbi.nlm.nih.gov/pubmed/28904382)
- Pestilli F, et al. Evaluation and statistical inference for human connectomes. *Nature Methods* (2014). [PubMed 25194848](https://www.ncbi.nlm.nih.gov/pubmed/25194848)
- Fischl B. FreeSurfer. *NeuroImage* 62(2):774–781 (2012). [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S1053811912000389)
- Desikan RS, Ségonne F, Fischl B, Quinn BT, Dickerson BC, Blacker D, et al. An automated labeling system for subdividing the human cerebral cortex on MRI scans into gyral based regions of interest. *NeuroImage* 31(3):968–980 (2006). [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S1053811906000437)
- Network Neuro. brainlife.io App. [doi:10.25663/bl.app.47](https://doi.org/10.25663/bl.app.47)
- Fischl. FreeSurfer. *NeuroImage* 62:774-781 (2012). [doi:10.1016/j.neuroimage.2012.01.021](https://doi.org/10.1016/j.neuroimage.2012.01.021)
- Pestilli et al. Evaluation and statistical inference for human connectomes. *Nature Methods* 11:1058-1063 (2014). [doi:10.1038/nmeth.3098](https://doi.org/10.1038/nmeth.3098)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

- Franco Pestilli (project director)
- Brent McPherson

**Contributors:** Soichi Hayashi

The App builds on [vistasoft](https://github.com/vistalab/vistasoft), [encode](https://github.com/brain-life/encode) and [MBA](https://github.com/francopestilli/mba).

## Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## License

[MIT](https://github.com/brainlife/app-networkneuro/blob/master/LICENSE). FreeSurfer itself is distributed under its own [license](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSoftwareLicense).
