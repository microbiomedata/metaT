Metatranscriptome Workflow (v0.0.2)
=====================================

Summary
-------

This workflow is designed to analyze metatranscriptomes. It is dependent on outputs from other NMDC workflow for input. It runs in two parts: Part 1 (workflows/metaT_part1.wdl) takes in clean interleaved reads (from the NMDC Reads QC workflow) as input, filters out rRNA reads (and separates the interleaved file into separate files for the pairs) using bbduk (BBTools), and assembles filtered reads into transcripts using MEGAHIT; Part 2 (workflows/metaT_part2.wdl) requires input from Part 1 (filtered reads and assembled transcripts), and the GFF functional annotation files generated from the NMDC Metagenome Annotation Workflow, to generate RPKMs for each feature in the GFF file.


Workflow Diagram
------------------

.. image:: workflow_metatranscriptomics.png
   :scale: 25%
   :alt: Metatranscriptome workflow

Workflow Availability
---------------------
The workflow uses the listed docker images to run all third-party tools.
The workflow is available in GitHub: 
https://github.com/microbiomedata/metaT; and the corresponding Docker images that have all the required dependencies are available in following DockerHub (https://hub.docker.com/r/microbiomedata/bbtools, https://hub.docker.com/r/microbiomedata/meta_t, and https://hub.docker.com/r/intelliseqngs/hisat2)


Requirements for Execution (recommendations are in bold):  
--------------------------------------------------------
1. WDL-capable Workflow Execution Tool (**Cromwell**)
2. Container Runtime that can load Docker images (**Docker v2.1.0.3 or higher**)

Workflow Dependencies
---------------------
Third-party software (These are included in the Docker images.)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. `BBTools v38.94 <https://jgi.doe.gov/data-and-tools/bbtools/>`_. (License: `BSD-3-Clause-LBNL <https://bitbucket.org/berkeleylab/jgi-bbtools/src/master/license.txt>`_.)
2. `BBMap v38.94 <https://jgi.doe.gov/data-and-tools/bbtools/>`_. (License: `BSD-3-Clause-LBNL <https://bitbucket.org/berkeleylab/jgi-bbtools/src/master/license.txt>`_.)
3. `Python v3.7.6 <https://www.python.org/>`_.  (License: Python Software Foundation License)
4. `featureCounts v2.0.2<http://subread.sourceforge.net/>`_. (License: GNU-GPL)
5. `R v3.6.0 <https://www.r-project.org/>`_. (License: GPL-2/GPL-3)
6. `edgeR v3.28.1 <https://bioconductor.org/packages/release/bioc/html/edgeR.html>`_. (R package) (License: GPL (>=2))
7. `pandas v1.0.5 <https://pandas.pydata.org/>`_. (python package) (License: BSD-3-Clause)
8. `gffutils v0.10.1 <https://pythonhosted.org/gffutils/>`_. (python package) (License: MIT)


Requisite database
~~~~~~~~~~~~~~~~~~
The RQCFilterData Database must be downloaded and installed. This is a 106 GB tar file which includes reference datasets of artifacts, adapters, contaminants, the phiX genome, rRNA kmers, and some host genomes.  The following commands will download the database: 

.. code-block:: bash

  wget http://portal.nersc.gov/dna/microbial/assembly/bushnell/RQCFilterData.tar
  tar -xvf RQCFilterData.tar
  rm RQCFilterData.tar	


Sample dataset(s)
------------------
The following files are provided with the GitHub download in the test_data folder:

1. Raw reads: test_data/test_interleave.fastq.gz (output from ReadsQC workflow)

2. Annotation file: test_functional_annotation.gff (output from mg_annotation workflow)

Input: A JSON file containing the following
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1.	a name for the analysis
2.	the number of cpus requested 
3.	the path to the clean input interleaved fastq file (recommended: the output from the Reads QC workflow)
4.	the path to the rRNA_kmer database provided as part of RQCFilterData
5.	the path to the assembled transcripts (output of part 1)
6.	the paths to the reads with rRNA removed (paired-end files) (output of part 1)
7.	the path to the annotation file (from the Metagenome Annotation workflow) 

An example JSON file is shown below:

.. code-block:: JSON

  {
    "metat_omics.project_name": "test",
    "metat_omics.no_of_cpus": 1,
    "metat_omics.rqc_clean_reads": "test_data/test_interleave.fastq",
    "metat_omics.ribo_kmer_file": "/path/to/riboKmers20fused.fa.gz",
    "metat_omics.metat_contig_fn": "/path/to/megahit_assem.contigs.fa",
    "metat_omics.non_ribo_reads": [
      "/path/to/filtered_R1.fastq",
      "/path/to/filtered_R2.fastq"
    ],
    "metat_omics.ann_gff_fn": "test_data/test_functional_annotation.gff"
  }

Output
~~~~~~
Output is split up between steps of the workflow. The first half of the workflow will output rRNA-filtered reads and the assembled transcripts. After annotations and featureCount steps include a JSON file that contain RPKMs for both sense and antisense, reads, and information from annotation for each feature. An example of JSON outpus:

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

Below is an example of the output directory files with descriptions to the right.

.. list-table:: Title
   :widths: 25 50
   :header-rows: 1

   * - File Name
     - Description
   * - out.json
     - main output file
   * - megahit_assem.contigs.fa
     - assembled transcripts
   * - Mapped_sorted.bam
     - alignment of reads and transcripts
   * - `feat_names`.count
     - output of featureCounts
   * - filered_R1.fastq;filtered_R2.fastq
     - non-ribosomal reads 


Version History 
---------------
- 0.0.2 (release date 01/14/2021; previous versions: 0.0.1)
- 0.0.3 (release date 07/28/2021; previous versions: 0.0.2)
Points of contact
-----------------
- Author: Migun Shakya <migun@lanl.gov>

