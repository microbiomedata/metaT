metaT: The Metatranscriptome Workflow
=====================================

Summary
-------

This workflow is designed to analyze metatranscriptomes. It run in two parts. Part 1 (workflows/metaT_part1.wdl) takes in raw reads as input, filters out rRNA reads, and assemble filtered reads into transcripts. Part 2 requires GFF annotation files generated from the the [NMDC annotation workflow](https://github.com/microbiomedata/mg_annotation), assemblies and reads from part 1 to generate RPKMs for each feature in the GFF file.


Workflow Diagram
------------------

.. image:: workflow_metatranscriptomics.png
   :scale: 40%
   :alt: Metatranscriptome workflow

Workflow Dependencies
---------------------

Third-party software/packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. bbduk ≥ v38.44
2. hisat2 ≥ 2.1
3. Python ≥ v3.7.6
4. featureCounts ≥ v2.0.1
5. R ≥ v3.6.0
6. edgeR ≥ v3.28.1 (R package)
7. pandas ≥ v1.0.5 (python package)
8. gffutils ≥ v0.10.1 (python package)


Database 
~~~~~~~~
1. rRNA k-mer database for bbduk. See `(RQC) <https://github.com/microbiomedata/ReadsQC>`_.


Workflow Availability
---------------------
The workflow is available in GitHub:
https://github.com/microbiomedata/metaT

Following containers available at Docker Hub 

1. `(microbiomedata/meta_t) <https://hub.docker.com/repository/docker/microbiomedata/meta_t>`_.
2. `(intelliseqngs/hisat2:1.2.1) <https://hub.docker.com/repository/docker/intelliseqngs/hisat2>`_.
3. `(microbiomedata/bbtools) <https://hub.docker.com/repository/docker/microbiomedata/bbtools>`_.

Test datasets
-------------
Test input JSON file and the corresponding test files can be found in the folder test_data.

Details
-------
metaT workflow is designed to analyze metatranscriptomes. It run in two parts. Part 1 (workflows/metaT_part1.wdl) takes in raw reads as input, filters out rRNA reads, and assemble filtered reads into transcripts. Part 2 requires GFF annotation files generated from the the [NMDC annotation workflow](https://github.com/microbiomedata/mg_annotation), assemblies and reads from part 1 to generate RPKMs for each feature in the GFF file.

Inputs
~~~~~~

Part 1
***********
raw reads: A Fastq file. Interleaved pairwise reads that have been processed using RQC.
json: json file with paths to input and additional information (see below). Both part of the workflow uses same format of JSON.

Part 2
**********
assembly : A FASTA file. Contigs assembled from Part of the workflow.
json: json file with paths to input and additional information (see below)

.. code-block:: JSON

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



Outputs
~~~~~~~

All outputs can be found in the folder created by cromwell.

Part 1
********
Ribosome reads filtered fastqs (`filtered_R1.fastq` and `filtered_R2.fastq`) and assemblies.

Part 2
******
The output file is a JSON formatted file called `out.json` with JSON records that contains RPKMs, reads, and information from annotation. An example JSON record:

.. code-block:: JSON
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



The output file is a JSON formatted file called `out.JSON` with JSON records. An example JSON record:

.. code-block:: JSON

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



Requirements for Execution
--------------------------

- Docker
- `Cromwell <https://github.com/broadinstitute/cromwell>`_ or other WDL-capable Workflow Execution Tool

Running Workflow
----------------

.. In local computer/server with third party tools installed and in PATH
.. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. Running workflow in a local computer or server where all the dependencies are installed and in path. 

.. `cd` into the folder and:

.. .. code-block:: sh

.. 	$ java -jar /path/to/cromwell-XX.jar run workflows/metaT.wdl -i test_data/test_input.json -m metadata_out.json



In a local computer/server with docker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Running workflow in a local computer or server using docker.

.. code-block:: sh

   java  -jar /path/to/cromwell-XX.jar run workflows/dock_metaT.wdl -i  test_data/test_input.json -m metadata_out.json 


In cori with shifter 
~~~~~~~~~~~~~~~~~~~~~~~~~

The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications.

.. code-block:: sh

	java -Dconfig.file=workflows/shifter.conf -jar /path/to/cromwell-XX.jar run -m metadata_out.json -i test_data/test_input_cori.json workflows/dock_metaT.wdl


Version History
---------------
- 0.0.2

Point of contact
----------------
Author: Migun Shakya <migun@lanl.gov>

