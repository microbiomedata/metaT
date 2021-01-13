# metaT: The Metatranscriptome Workflow
## Summary
This workflow is designed to analyze metatranscriptomes. This is still work in progress.

## Third party tools and packages
```
sortmerna v4.2.0
stringtie v2.1.2
hisat2
Python v3.7.6
pandas v1.0.5 (python package)
gffutils v0.10.1 (python package)
Docker
```

![metatranscriptomics workflow](docs/workflow_metatranscriptomics.png)
## Running workflow

Details coming soon.
<!-- ````
salloc -N 1 -C haswell -q interactive -t 04:00:00

/global/cfs/cdirs/m3408/ficus/pipeline_products

<!-- ``` -->
<!-- ### In local computer/server with third party tools installed and in PATH.
Running workflow in a local computer or server where all the dependencies are installed and in path. cromwell should be installed in the same directory as this file. 

`cd` into the folder and:

```
	$ java -jar /path/to/cromwell-XX.jar run workflows/metaT.wdl -i test_data/test_input.json -m metadata_out.json

``` -->

### In a local computer/server with docker
Running workflow in a local computer or server using docker. cromwell should be installed in the same directory as this file.

```
   java  -jar /path/to/cromwell-XX.jar run workflows/dock_metaT.wdl -i  test_data/test_input.json -m metadata_out.json 
```

###  In cori with shifter 

The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications.

```
java -Dconfig.file=workflows/shifter.conf -jar /path/to/cromwell-XX.jar run -m metadata_out.json -i test_data/test_input_cori.json workflows/dock_metaT.wdl

```
## Docker image

The docker images for all profilers is at the docker hub: `microbiomedata/meta_t:latest`. The `Dockerfile` can be found in `Docker/metatranscriptomics/` directory.


## Inputs
raw reads: Interleaved pairwise reads that have been processed using RQC.
json: json file with paths to input and additional information (see below)

```json
{
  "metat_omics.project_name": "1781_100346",
  "metat_omics.no_of_cpus": 1,
  "metat_omics.rqc_clean_reads": "test_data/test_interleave.fastq",
  "metat_omics.sort_rna_db": {
    "rfam_5S_db": "data/rRNA_databases/rfam-5s-database-id98.fasta",
    "rfam_56S_db": "data/rRNA_databases/rfam-5.8s-database-id98.fasta",
    "silva_arc_16s": "data/rRNA_databases/silva-arc-16s-id95.fasta",
    "silva_arc_23s": "data/rRNA_databases/silva-arc-23s-id98.fasta",
    "silva_bac_16s": "data/rRNA_databases/silva-bac-16s-id90.fasta",
    "silva_bac_23s": "data/rRNA_databases/silva-bac-23s-id98.fasta",
    "silva_euk_18s": "data/rRNA_databases/silva-euk-18s-id95.fasta",
    "silva_euk_28s": "data/rRNA_databases/silva-euk-28s-id98.fasta"
  }
}

```

## Outputs
The output file is a JSON formatted file called `out.json` with JSON records that contains FPKMs, TPMs, and coverage. An example JSON record:

```json
  {
        "featuretype": "transcript",
        "seqid": "k123_15",
        "id": "STRG.2.1",
        "source": "StringTie",
        "start": 1,
        "end": 491,
        "length": 491,
        "strand": ".",
        "frame": ".",
        "extra": [],
        "cov": "5.928717",
        "FPKM": "76638.023438",
        "TPM": "146003.046875"
    }


```

<!-- #TODO add documentation, get stuff from BIN -->