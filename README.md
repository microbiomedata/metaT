# metaT: The Metatranscriptome Workflow

## Summary
This workflow is designed to analyze metatranscriptomes.

![metatranscriptomics workflow](docs/metaT_figure.png)

## Version
0.0.3

## Third party tools and packages
To run this workflow you will need a Docker (Docker ≥ v2.1.0.3) instance and cromwell. All the third party tools are pulled from Dockerhub.

```
cromwell ≥ 54
bbtools ≥ v38.94
Python ≥ v3.7.6
featureCounts ≥ v2.0.2
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


## Docker images

- `microbiomedata/meta_t:latest`. 
`Dockerfile` can be found in `Docker/metatranscriptomics/` directory. 
- `microbiomedata/bbtools:38.94`
- `scanon/nmdc-meta:v0.0.1`
- `bfoster1/img-omics:0.1.7`
- `scanon/im-trnascan:v0.0.1`
- `scanon/im-last:v0.0.1`
- `scanon/im-hmmsearch:v0.0.0`


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
    "nmdc_metat.database": "/global/cfs/cdirs/m3408/aim2/database/",
    "nmdc_metat.activity_id": "test-activity-id",
    "nmdc_metat.threads": 64,
    "nmdc_metat.metat_folder": "/global/cfs/cdirs/m3408/aim2/metatranscriptomics/metaT"
}
```
### Input option descriptions:
- `proj`: A unique name for your project or sample.
- `input_file`: Full path to the fastq file. The file must be intereleaved paired end fastq.
- `git_url`: A link to this version. Update it based on which version you downloaded.
- `url_base`: A web location where all the data objects from this run will be stored.
- `url_root`: Same as url_base.
- `outdir`: Full path of the folder where all the important outputs will be saved.
- `resource`: A short description or name of where the data was processed.
- `database`: Full path to a folder where RQC (`RQCFilterData/`) and IMG (`img/`) annotation database are located. Within the `IMG` folder following folders are expected:
```
    Cath-FunFam  COG  IMG-NR  Pfam  Product_Name_Mappings  Rfam  SMART  SuperFamily  TIGRFAM
```
This folder should also be be set in the cromwell config file.
- `threads`: Number of threads.
- `activity_id`: A unique ID for the project.
- `metat_folder`: Full path to metaT folder.

## Outputs
All outputs can be found in the `outdir` folder. There are following subfolders:
- `outdir/annotation`: contains gff files from annotation run.
- `outdir/assembly`: contains FASTA fils from assembly.
- `outdir/mapback`: BAM file where reads were mapped back to the contigs.
- `outdir/metat_output`: Two JSON files for sense and antisense that have records for feature, their annotations, read counts from featurecount, and FPKM values. 
- `outdir/qa`: contains cleaned reads and a file with associated statistics.

# Output JSON
The output file is a JSON formatted file called `out.json` with JSON records that contains RPKMs, reads, and information from annotation. An example JSON record:
```json
        {
            "read_count": 2,
            "rpkm": 750750.751,
            "featuretype": "CDS",
            "seqid": "contig_3",
            "id": "contig_3_126_347",
            "source": "GeneMark.hmm_2 v1.05",
            "start": 126,
            "end": 347,
            "length": 222,
            "strand": "+",
            "frame": "0",
            "extra": [],
            "product": "hypothetical protein"
        }

```

## Test 
To test the workflow, we have provided a small test dataset and a step by step guidance. See `test_data` folder.

