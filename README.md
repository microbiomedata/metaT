# metaT: The Metatranscriptome Workflow

## Summary
This workflow is designed to analyze metatranscriptomes. It run in two parts. Part 1 (workflows/metaT_part1.wdl) takes in raw reads as input, filters out rRNA reads, and assemble filtered reads into transcripts. Part 2 requires GFF annotation files generated from the the [NMDC annotation workflow](https://github.com/microbiomedata/mg_annotation), assemblies and reads from part 1 to generate RPKMs for each feature in the GFF file.

![metatranscriptomics workflow](docs/workflow_metatranscriptomics.png)

## Version
0.0.2
## Third party tools and packages
To run this workflow you will need a Docker (Docker ≥ v2.1.0.3) instance and cromwell. All the third party tools are pulled from Dockerhub.

```
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
A ribokmer file. See [RQC](https://github.com/microbiomedata/ReadsQC) workflow for obtaining the file.

## Running workflow

### In a local computer/server with docker
Running workflow in a local computer or server using docker. cromwell should be installed in the same directory as this file.

```
   java  -jar /path/to/cromwell-XX.jar run workflows/metaT_part1.wdl -i  test_data/test_input.json -m metadata_out_part1.json
   java  -jar /path/to/cromwell-XX.jar run workflows/metaT_part2.wdl -i  test_data/test_input.json -m metadata_out_part2.json 
```

###  In cori with shifter 

The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications.

```
java -Dconfig.file=workflows/shifter.conf -jar /path/to/cromwell-XX.jar run -m metadata_out_part1.json -i test_data/test_input_cori.json workflows/metaT_part1.wdl
java -Dconfig.file=workflows/shifter.conf -jar /path/to/cromwell-XX.jar run -m metadata_out_part2.json -i test_data/test_input_cori.json workflows/metaT_part2.wdl

```
If you are running the workflow from a different directory, you will also need to copy the two folders(`scripts` and `pyp_metat`) to that folder.
## Docker image

The docker images: 
- `microbiomedata/meta_t:latest`. 
  The `Dockerfile` can be found in `Docker/metatranscriptomics/` directory. 
- `intelliseqngs/hisat2:1.2.1`
- `microbiomedata/bbtools:38.90`


## Inputs

### For Part 1
raw reads: A Fastq file. Interleaved pairwise reads that have been processed using RQC.
json: json file with paths to input and additional information (see below). Both part of the workflow uses same format of JSON.

### For Part 2
assembly : A FASTA file. Contigs assembled from Part of the workflow.
json: json file with paths to input and additional information (see below)

```json
{
  "metat_omics.project_name": "test",
  "metat_omics.no_of_cpus": 1,
  "metat_omics.rqc_clean_reads": "test_data/test_interleave.fastq",
  "metat_omics.ribo_kmer_file": "data/riboKmers20fused.fa.gz",
  "metat_omics.metat_contig_fn": "test_data/test_assembly_contigs.fna",
  "metat_omics.non_ribo_reads": [
    "test_data/test_R1.fastq",
    "test_data/test_R2.fastq"
  ],
  "metat_omics.ann_gff_fn": "test_data/test.gff"
}
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