# etSTEDanalysis
Analysis code for event-triggered STED data, including brief example data. Supporting the method implementation and findings in the published paper "Event-triggered STED imaging", Jonatan Alvelid, Martina Damenti, Chiara Sgattoni, Ilaria Testa, Nature Methods 19, 1268–1275 (2022). https://doi.org/10.1038/s41592-022-01588-y

Dataset: https://doi.org/10.5281/zenodo.5593270

Jupyter notebooks and ImageJ scripts.

## Contents
coordinate_transformation - Jupyter notebook for testing and characterizing the coordinate transform.

datahandling - Jupyter notebooks for handling/resaving raw etSTED data (hdf5 files) to tiff stacks, saving individual frames from the tiff stacks, and saving a summary of an experiment run as a pdf.

pipeline_validation - Jupyter notebooks for validating calcium event detections in recorded widefield timelapses, and for saving the various intermediate images in a pipeline run.

sted_resolution - Jupyter notebook for fitting Lorentzians to already extracted line profiles.

synaptotagmin1 - ImageJ script for extracting binarized clusters and analysis of those from raw STED timelapses of synaptotagmin1-labelled synaptic vesicles. Jupyter notebook to get the results from multiple timelapses and summarizing them for different conditions (calcium-triggered and manual non-calcium-synchronized timelapses).

time_characterization - Jupyter notebook for characterizing the speed of the pipeline and imaging method switch from widefield to STED in experimental log files.
