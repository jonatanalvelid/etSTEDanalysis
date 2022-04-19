# etSTEDanalysis
Analysis code for event-triggered STED data, including brief example data. Supporting the method implementation and findings in the manuscript "Event-triggered STED", Jonatan Alvelid, Martina Damenti, Chiara Sgattoni, Ilaria Testa (manuscript, submitted, 2021).

Jupyter notebooks and ImageJ scripts.

## Contents
coordinate_transformation - Jupyter notebook for testing and characterizing the coordinate transform.

datahandling - Jupyter notebooks for handling/resaving raw etSTED data (hdf5 files) to tiff stacks, saving individual frames from the tiff stacks, and saving a summary of an experiment run as a pdf.

pipeline_validation - Jupyter notebooks for validating calcium event detections in recorded widefield timelapses, and for saving the various intermediate images in a pipeline run.

sted_resolution - Jupyter notebook for fitting Lorentzians to already extracted line profiles.

synaptotagmin1 - ImageJ script for extracting binarized clusters and analysis of those from raw STED timelapses of synaptotagmin1-labelled synaptic vesicles. Jupyter notebook to get the results from multiple timelapses and summarizing them for different conditions (calcium-triggered and manual non-calcium-synchronized timelapses).

time_characterization - Jupyter notebook for characterizing the speed of the pipeline and imaging method switch from widefield to STED in experimental log files.
