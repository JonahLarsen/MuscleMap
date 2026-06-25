#!/bin/sh

#load SCT
# source /Users/labadmin/.bashrc

#Activate musclemap conda environment
.\.venv\Scripts\Activate.ps1

HOME=C:\Users\jsl94\

#Setup data_path and output_path variables
data_path=${HOME}\Documents\test_niix
output_path=${HOME}\Documents\output_test

echo Data path is ${data_path}
echo Output path is ${output_path}

#Create dataset folders in output path
mkdir -p ${output_path}/sourcedata

#List of subjects ids: Put only one id to run a single subject or more separated by spaces to run multiple subjects
ids=('009')
#ids=()

for id in ${ids[@]}; do

	echo Running ${id}

    ###Organize data###

    #Make BIDS like folders
    mkdir -p ${output_path}/sourcedata/Johnson_Svo_${id}
   
    mkdir -p ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w

    #Find muscle images for each location
    t1w_iso=${data_path}/Johnson_Svo_${id}/fl3d_vibe_iso_W_*.nii.gz
    t1w_neg200=${data_path}/Johnson_Svo_${id}/fl3d_vibe_200_W_*.nii.gz
    t1w_neg400=${data_path}/Johnson_Svo_${id}/fl3d_vibe_400_W_*.nii.gz
    t1w_neg600=${data_path}/Johnson_Svo_${id}/fl3d_vibe_600_W_*.nii.gz
    t1w_neg800=${data_path}/Johnson_Svo_${id}/fl3d_vibe_800_W_*.nii.gz
    t1w_neg1000=${data_path}/Johnson_Svo_${id}/fl3d_vibe_1000_W_*.nii.gz

    #Copy muscle json file
    t1w_json=${data_path}/Johnson_Svo_${id}/fl3d_vibe_iso_W_*.json
    cp ${t1w_json} ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w.json

    #Stitch muscle images together1
    sct_image -i ${t1w_iso} ${t1w_neg200} ${t1w_neg400} ${t1w_neg600} ${t1w_neg800} ${t1w_neg1000} -stitch -o ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w.nii.gz
    #sct_image -i ${t1w_iso} ${t1w_neg200} ${t1w_neg400} ${t1w_neg600} ${t1w_neg800} -stitch -o ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w.nii.gz

    ###Run Segmentations###

    #Segment dixon images and then rename output based on region

    source /opt/anaconda3/bin/activate MuscleMap
    
    #abdomen
    mm_segment -i ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w.nii.gz -r abdomen -o ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/
    mv ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_dseg.nii.gz ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_chunk-abdomen_dseg.nii.gz

    #pelvis
    mm_segment -i ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w.nii.gz -r pelvis -o ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/
    mv ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_dseg.nii.gz ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_chunk-pelvis_dseg.nii.gz

    #thigh
    mm_segment -i ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w.nii.gz -r thigh -o ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/
    mv ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_dseg.nii.gz ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_chunk-thigh_dseg.nii.gz

    #leg
    mm_segment -i ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w.nii.gz -r leg -o ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/
    mv ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_dseg.nii.gz ${output_path}/sourcedata/Johnson_Svo_${id}/ses-T1w/Johnson_Svo_${id}_ses-T1w_chunk-leg_dseg.nii.gz

done