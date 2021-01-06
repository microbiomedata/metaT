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
1. featureCounts ≥ v2.0.0 (GPLv3)    
2. R ≥ v3.5.1
3. edgeR ≥ v3.24.3(an R package)
4. Python ≥ v3.7.6
5. pandas ≥ v1.0.5 (python package)
6. gffutils ≥ v0.10.1 (python package)

Database 
~~~~~~~~
NA

Workflow Availability
---------------------
The workflow is available in GitHub:
https://github.com/microbiomedata/metaT

The container is available at Docker Hub (`microbiomedata/meta_t) <https://hub.docker.com/repository/docker/microbiomedata/meta_t>`_.

Test datasets
-------------


Details
-------
metaT takes the assembled contigs and BAM file from the NMDC metaAssembly workflow as the input along with the gff file from the mg_annotation workflow and outputs a table with RPKM values for different features found in the off file.

Inputs
~~~~~~

A JSON files with the following entries:

1. Number of CPUs
2. Project name
3. Metagenome Assembled Contig fasta file
4. Bam file from reads mapping back to contigs
5. GFF file from the annotation workflow

.. code-block:: JSON

	{
		"metat_omics.project_name": "A_GOOD_PROJECT",
		"metat_omics.no_of_cpu": 1,
		"metat_omics.contig_file_path": "PATH/TO/CONTIG/FASTA",
		"metat_omics.gff_file_path": "PATH/TO/GFF/FILE",
		"metat_omics.bam_file_path": "PATH/TO/BAM/FILE"
	}

Outputs
~~~~~~~

The output file is a JSON formatted file called `output.JSON` with JSON records that contains raw read counts, rpkms, and additional annotation metadata from gff file. An example JSON record:

.. code-block:: JSON

    {
        "read_count": 5,
        "rpkm": 9780.908,
        "featuretype": "CDS",
        "seqid": "1781_100346_scf_10009_c1",
        "id": "1781_100346_scf_10009_c1_3_452",
        "source": "GeneMark.hmm_2 v1.05",
        "start": 3,
        "end": 452,
        "length": 450,
        "strand": "_",
        "frame": "0",
        "extra": [],
        "cog": "COG0568",
        "ko": "KO:K03086",
        "pfam": "Sigma70_r",
        "product": "RNA polymerase primary sigma factor"
    }


Requirements for Execution
--------------------------

- Docker or other Container Runtime
- `Cromwell <https://github.com/broadinstitute/cromwell>`_ or other WDL-capable Workflow Execution Tool

Running Workflow
----------------

In local computer/server with third party tools installed and in PATH
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Running workflow in a local computer or server where all the dependencies are installed and in path. 

`cd` into the folder and:

.. code-block:: sh

	$ java -jar /path/to/cromwell-XX.jar run workflows/metaT.wdl -i test_data/test_input.json -m metadata_out.json



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

