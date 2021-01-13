metaT: The Metatranscriptome Workflow
=====================================

Summary
-------

This workflow analyzes metatranscriptomes. It takes contigs and BAM file from [metaAssembly](https://github.com/microbiomedata/metaAssembly) and gff file from [mg_annotation](https://github.com/microbiomedata/mg_annotation) as inputs. It outputs a single JSON file that has metadata derived from gff and read count and RPKM values.

Workflow Diagram
------------------

.. image:: workflow_metatranscripomics.png
   :scale: 40%
   :alt: Metatranscriptome workflow

Workflow Dependencies
---------------------

Third-party software/packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. sortmerna ≥ v4.2.0 (GPLv3)    
2. stringtie ≥ v2.1.2
3. HISAT2 ≥ v3.24.3(an R package)
4. Python ≥ v3.7.6
5. 7. Docker

Python packages
~~~~~~~~~~~~~~~
1. pandas ≥ v1.0.5 (python package)
2. gffutils ≥ v0.10.1 (python package)


Database 
~~~~~~~~
1. rRNA database from `(sortmerna) <https://github.com/biocore/sortmerna/tree/master/data/rRNA_databases>`_.


Workflow Availability
---------------------
The workflow is available in GitHub:
https://github.com/microbiomedata/metaT

The container is available at Docker Hub `(microbiomedata/meta_t) <https://hub.docker.com/repository/docker/microbiomedata/meta_t>`_.

Test datasets
-------------


Details
-------
metaT takes the RQC cleaned interleaved reads NMDC RQC workflow as the input and outputs a JSON file 
with FPKM, coverage, and TPM values for transcripts.

Inputs
~~~~~~

A JSON files with the following entries:

1. Number of CPUs
2. Project name
3. Interleaved paired reads
4. path to rRNA databases

.. code-block:: JSON

{
    "metat_omics.project_name": "test",
    "metat_omics.no_of_cpus": 1,
    "metat_omics.rqc_clean_reads": "test_data/test_interleave.fastq",
    "metat_omics.sort_rna_db": {
        "rfam_5S_db": "data/rRNA_databases/rfam-5.8s-database-id98.fasta",
        "rfam_56S_db": "data/rRNA_databases/rfam-5s-database-id98.fasta",
        "silva_arc_16s": "data/rRNA_databases/silva-arc-16s-id95.fasta",
        "silva_arc_23s": "data/rRNA_databases/silva-arc-23s-id98.fasta",
        "silva_bac_16s": "data/rRNA_databases/silva-bac-16s-id90.fasta",
        "silva_bac_23s": "data/rRNA_databases/silva-bac-23s-id98.fasta",
        "silva_euk_18s": "data/rRNA_databases/silva-euk-18s-id95.fasta",
        "silva_euk_28s": "data/rRNA_databases/silva-euk-28s-id98.fasta"
    }
}

Outputs
~~~~~~~

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
- 1.0.0

Point of contact
----------------
Author: Migun Shakya <migun@lanl.gov>

