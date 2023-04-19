# airwayRT
MATLAB-based scripts to analyze radiation-induced airway changes using VIDA segmentations
# File descriptions
## transformAirway.m
This function will iterate through the entire 'data' directory and subfolders to re-orient the specified segmentation file back into the reference frame of the CT scan the segmentation was originally derived from. You MUST run this function prior to running analyzeLobes.m.

## analyzeLobes.m
This is the main file that calls the other functions for analyzing. To run this script you must have data in the 'data' directory following the format ./data/IPF###_SCAN#/. Data needed: RTDose in NIFTI format, JacRatio in NIFTI format, preRT Airway Color NIFTI, postRT WARPED Airway Color NIFTI. Remember that any data created from VIDA (i.e. aircolor segmentations) must first be preprocessed using the transformAirway.m function.

## findTerminalAirways.m
Finds the correspondence in airway labels between the preRT airway color map and the warped postRT airway color map, as well as the labels corresponding to the terminal airways (i.e. airways that have no further branches)

## resistanceCalc2.m
Calculates the resistance lookup table (rlut) and grabs airway metrics (aichange). The output variable aichange contains the following columns of data for each subject: preRT airway segment ID, preRT mean luminal diameter, preRT mean wall thickness, preRT mean outer area, preRT mean inner area, postRT airway segment ID, postRT mean luminal diameter, postRT mean wall thickness, postRT mean outer area, postRT mean inner area, maximum dose, average dose, total number of airway segment voxels.

## nnJacRatio.m
Performs nearest neighbor search for each terminal airway. Output is a lung mask with each voxel assigned the value of the preRT airway segment ID that is closest to it.

Metrics are saved out to resistances.xlsx and dichanges_vol.xlsx. dichanges_vol.xslx contains the variables listed from resistanceCalc2. resistances.xlsx contains the following columns of data for each subject: preRT airway segment ID of terminal airway, preRT cumulative resistance, postRT airway segment ID of corresponding terminal airway, postRT cumulative resistance, resistance ratio (post/pre cumulative resistances).

# How to warp airways
In order to find correspondance between the postRT and preRT airway labels, you must warp the postRT aircolor map into the reference frame of the preRT scan.
1. Perform rigid registration between the two scans
  - {path_to_lungseg-bld}/bin/RigidRegistration preRT_scan_100IN.mask.nii.gz postRT_scan_100IN.mask.nii.gz postRT_aircolor.nii.gz aircolor_rigid.nii.gz mask
2. Use ANTs to apply transformation (this assumes you already have performed deformable registration between the two images and have the corresponding displacementField.mha file)
  - antsApplyTransforms -d 3 -r preRT_scan_100IN.nii.gz -t displacementField.mha -i aircolor_rigid.nii.gz -o aircolor_warped.nii.gz -n GenericLabel
