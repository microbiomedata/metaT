# metaT: The Metatranscriptome Workflow

## Summary
This workflow is designed to analyze metatranscriptomes.

![metatranscriptomics workflow](docs/workflow_metatranscriptomics.png)

## Version
0.0.3

## Third party tools and packages
To run this workflow you will need a Docker (Docker ≥ v2.1.0.3) instance and cromwell. All the third party tools are pulled from Dockerhub.

```
cromwell ≥ 54
bbduk ≥ v38.44
hisat2 ≥ 2.1
Python ≥ v3.7.6
featureCounts ≥ v2.0.1
R ≥ v3.6.0
edgeR ≥ v3.28.1 (R package)
pandas ≥ v1.0.5 (python package)
gffutils ≥ v0.10.1 (python package)

```

## Databases
metaT uses the same database uses for metagenome annotation. See README [here](https://github.com/microbiomedata/mg_annotation) for required databases.For QC databases see [here](https://github.com/microbiomedata/ReadsQC.)


## Running workflow

###  In a server with shifter
The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications.


```
java -Dconfig.file=wdls/shifter.conf -jar /full/path/to/cromwell-XX.jar run -i input.json /full/path/to/wdls/metaT.wdl

```
<!-- ```
   java  -jar /path/to/cromwell-XX.jar run wdls/metaT_part1.wdl -i  test_data/small_test/test_small_input.json -m metadata_out_part1.json
   java  -jar /path/to/cromwell-XX.jar run wdls/metaT_part2.wdl -i  test_data/small_test/test_small_input.json -m metadata_out_part2.json 
``` -->

<!-- java -jar cromwell/cromwell-48.jar run wdls/nmdc-metaT_full.wdl -i test_data/small_test/test_small_input_fullpipe.json -l test_data/small_test/test_small_input_label.json -->


## Docker image

The docker images: 
- `microbiomedata/meta_t:latest`. 
  The `Dockerfile` can be found in `Docker/metatranscriptomics/` directory. 
- `intelliseqngs/hisat2:1.2.1`
- `microbiomedata/bbtools:38.90`


## Inputs

```json
{
    "nmdc_metat.proj": "gold:Ga0370541",
    "nmdc_metat.input_file": "/global/cfs/cdirs/m3408/aim2/metatranscriptomics/metaT/test_data/small_test/test_smaller_interleave.fastq.gz",
    "nmdc_metat.git_url": "https://github.com/microbiomedata/mg_annotation/releases/tag/0.1",
    "nmdc_metat.url_base": "https: //data.microbiomedata.org/data/",
    "nmdc_metat.outdir": "/global/cfs/cdirs/m3408/aim2/metatranscriptomics/metaT/test_data/test_small_out",
    "nmdc_metat.resource": "NERSC - Cori",
    "nmdc_metat.url_root": "https://data.microbiomedata.org/data/",
    "nmdc_metat.rqc_database": "/global/cfs/cdirs/m3408/aim2/database/",
    "nmdc_metat.annot_database": "/global/cfs/cdirs/m3408/aim2/database/img/",
    "nmdc_metat.activity_id": "test-activity-id"
}
```

## Outputs
All outputs can be found in the folder created by cromwell.
### From Part 1
Ribosome reads filtered fastqs (`filtered_R1.fastq` and `filtered_R2.fastq`) and assemblies.
### From Part 2
The output file is a JSON formatted file called `out.json` with JSON records that contains RPKMs, reads, and information from annotation. An example JSON record:
```json
        {
            "read_count": 5,
            "rpkm": 4.642,
            "featuretype": "CDS",
            "seqid": "seqid_8_10",
            "id": "seq_327",
            "source": "GeneMark.hmm_2 v1.05",
            "start": 10,
            "end": 327,
            "length": 318,
            "strand": "+",
            "frame": "0",
            "extra": [],
            "cog": "COG0208",
            "ko": "KO:K00526",
            "ec_number": "EC:1.17.4.1",
            "product": "ribonucleoside_diphosphate reductase beta chain"
        }

```

<!-- #TODO add documentation, get stuff from BIN -->