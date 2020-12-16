# metaT
Metatranscriptomics workflow

## Summary
This workflow is designed for analyzing metatranscriptomic datasets. It is dependent

![metatranscriptomics workflow](workflow_metatranscriptomics.png)
## Running workflow


### In 



<!-- ````
salloc -N 1 -C haswell -q interactive -t 04:00:00

/global/cfs/cdirs/m3408/ficus/pipeline_products

``` -->
### In local computer/server with conda
Running workflow in a local computer or server where all the dependencies are installed and in path. cromwell should be installed in the same directory as this file. 

`cd` into the folder and:

```
	$ java -jar cromwell-XX.jar run workflows/metaT.wdl -i test_data/test_input.json -m metadata_out.json

```

### In a local computer/server with docker
Running workflow in a local computer or server using docker. cromwell should be installed in the same directory as this file.

```
  java -jar cromwell-XX.jar run workflows/docker_metaT.wdl -i  test_data/test_input.json 

```

###  In cori with shifter and/or JTM

Running workflow in cori with JTM:

The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications.

```
java -Dconfig.file=../../metagenome/assembly/shifter.conf -jar /global/common/software/m3408/cromwell-45.jar run -m metadata_out.json -i test_data/test_input_cori.json metaT.wdl 

```
```
java -Dconfig.file=jtm.conf -jar cromwell-XX.jar run -i test_data/test_input.json workflows/shift_metaT.wdl
```

## Docker image

The docker images for all profilers is at the docker hub: `migun/nmdc_metat:latest`. The `Dockerfile` can be found in `Docker/metatranscriptomics/` directory.


## Inputs
fasta: contigs from assembly workflow
gff: annotation file from annotation workflow
bam file: BAM file produced by mapping reads back to the contigs (also from assembly workflow)
json: json file with paths to input and additional information (see below)

```json
{
{
  "metat_omics.project_name": "1781_100346",
  "metat_omics.no_of_cpu": 1,
  "metat_omics.path_to_out": "test_results",
  "metat_omics.contig_file_path": "test_data/1781_100346/assembly/assembly_contigs.fna",
  "metat_omics.gff_file_path": "test_data/1781_100346/annotation/1781_100346_functional_annotation.gff",
  "metat_omics.bam_file_path": "test_data/1781_100346/assembly/pairedMapped_sorted.bam",
  "metat_omics.feat_name_list": [
    "CDS"
  ]
}
  }


```


<!-- #TODO add documentation, get stuff from BIN -->