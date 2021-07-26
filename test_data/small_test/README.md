## Description
    This folder contains input files required for running a small test dataset, and a final output file.

## Files:
    A short description of the files in this folder:


### 1. test_small_input.json
    A JSON file with parameters for the worfklow and paths to input files. This file is required for both part 1 and part 2 of the workflow.

### 2. test_small_interleave.fastq.gz
    An interleaved fastq file that is an output of RQC workflow. This file is required for part 1 of the workflow.

### 3. test_small_assembly_contigs.fna
    A FASTA file containing assembled contigs from part 1. This file is required for part 2 and processed with the mg_annotation workflow to generate the annotation GFF files.

### 4. test_small_functional_annotation.gff
    A GFF file produced by the mg_annotation workflow using `test_small_assembly_contigs.fna`.

### 5. test_small_filtered_R2.fastq.gz and test_small_filtered_R1.fastq.gz
    Paired FASTQ files after removing ribosomal RNA reads from `test_small_interleave.fastq.gz`

### 6. test_small_output.json
    Final output JSON file.

## Instructions for running the test:

### Step 1:
    Go to metaT directory:

```
$ cd /path/to/metaT
```

### Step 2:
    Run part 1 of the workflow using following command:

```
java  -jar /path/to/cromwell.jar run wdls/metaT_part1.wdl -i test_data/small_test/test_small_input.json -m metadata_out_part1.json
```

Paths to the output files can be found in the `metadata_out_part1.json`.


### Step 3:
    Run part 2 of the workflow:

```
java  -jar /path/to/cromwell.jar run wdls/metaT_part2.wdl -i test_data/small_test/test_small_input.json -m metadata_out_part2.json
```

Paths to the output file that can be compared to `test_small_output.json` can be found in the `metadata_out_part2.json`.

## Note
    Contigs are annotated separately using the `mg_annotation` workflow which happens out side this workflow. I have provided the `test_small_functional_annotation.gff`, which was processed separately using the `mg_annotation` workflow so that the pipeline can be tested fully.


