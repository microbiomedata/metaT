## Description
    This folder contains input files required for running a small test dataset, and a final output file.

## Files:
    A short description of the files in this folder:


### 1. test_small_input_fullpipe.json
    A JSON file with parameters for the worfklow and paths to input files. You will need to update this file based on where are your files in your computer.

### 2. test_small_output_fullpipe.json
    Expected output that is found in `outdir/proj_name_out.json`

### 3. test_smaller_interleave.fastq.gz
    This is a small fastq file for the test.

## Instructions for running the test:

To test the workflow, we have provided a small test dataset and a step by step guidance below:

### Step 1:

- Download the latest version of the metaT workflow.

```

git clone https://github.com/microbiomedata/metaT.git

```

- Change the branch of the repo from `main` to `full_wdl_v1`

 ```
git checkout full_wdl_v1

 ```

### Step 2:

Create or edit an input.json file using `test_data/test_small_input_fullpipe.json` as a template.

- `cd` into the metaT folder and then run the following command. You must have shifter and cromwell downloaded and installed.

```
cd metaT

java -Dconfig.file=wdls/shifter.conf -jar /full/path/to/cromwell-XX.jar run -i /full/path/to/metaT/test_data/test_small_input_fullpipe.json /full/path/to/metaT/wdls/metaT.wdl