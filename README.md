# metaT: The Metatranscriptome Workflow

## Summary
This workflow is designed to analyze metatranscriptomes.

![metatranscriptomics workflow](docs/metaT_figure.png)

All parts of this workflow are housed in their own repositories and imported via WDL v1.0 https importing. 
The following repositories are used in this workflow:
 - [metaT_ReadsQC](https://github.com/microbiomedata/metaT_ReadsQC)
 - [metaT_ReadsQC](https://github.com/microbiomedata/metaT_Assembly)
 - [metaT_ReadsQC](https://github.com/microbiomedata/mg_annotation)
 - [metaT_ReadsQC](https://github.com/microbiomedata/metaT_ReadCounts)

## Version
1.0.0

## Third party tools and packages
To run this workflow you will need a Docker (Docker ≥ v2.1.0.3) instance and cromwell. All the third party tools are pulled from Dockerhub.

```
cromwell ≥ 54
bbtools ≥ v38.94
Python ≥ v3.7.12
pandas ≥ v1.0.5 (python package)
gffutils ≥ v0.10.1 (python package)

```

## Databases
metaT uses the same database uses for metagenome annotation. See README [here](https://github.com/microbiomedata/mg_annotation) for required databases. For QC databases see [here](https://github.com/microbiomedata/ReadsQC.)


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

- `microbiomedata/meta_t:latest`
- `bryce911/bbtools:38.86`


## Inputs

```json
{
    "metaT.input_files": ["./test_data/small_test/test_small_interleave.fastq.gz"],
    "metaT.project_id":"nmdc:xxxxxxx",
    "metaT.strand_type": "aRNA"
}
```
### Input option descriptions:
- `project_id`: A unique name for your project or sample.
- `input_files`: Full path to the fastq file. The file must be intereleaved paired end fastq.
- `strand_type`: RNA strand type. Inputs can be either `aRNA` or `non_stranded_RNA`

## Outputs
All outputs can be found in the `outdir` folder. There are following subfolders:
- `outdir/annotation`: contains gff files from annotation run.
- `outdir/assembly`: contains FASTA files from assembly and BAM files where reads were mapped back to the contigs.
- `outdir/mapback`: BAM file where reads were mapped back to the contigs.
- `outdir/metat_output`: Two JSON files for sense and antisense that have records for feature, their annotations, read counts from featurecount, and FPKM values. 
- `outdir/qc`: contains cleaned reads and a file with associated statistics.
- `outdir/rc`: contains read count tables and associated statistics.

# Output JSON
The output file is a JSON formatted file called `out.json` with JSON records that contains reads and information from annotation. An example JSON record:
```json
        {
            "read_count": 2,
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

