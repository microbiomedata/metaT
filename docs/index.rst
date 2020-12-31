Metatranscriptome workflow
==========================

Summary
-------

Metatranscriptome workflow

Workflow Diagram
------------------

.. image:: metat_workflow.png
   :scale: 40%
   :alt: Metatranscriptome workflow

Workflow Dependencies
---------------------

Third party software / packages
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- samtools > v1.9 (MIT License)
- featureCounts ≥ v2.0.0 (GPLv3)

Database 
~~~~~~~~
NA

Workflow Availability
---------------------
The workflow is available in GitHub:
https://github.com/microbiomedata/metaT

The container is available at Docker Hub (microbiomedata):



Test datasets
-------------

.. #TODO add my test dataset
`metaMAGs_test_dataset.tgz <https://portal.nersc.gov/cfs/m3408/test_data/metaMAGs_test_dataset.tgz>`_

Details
-------
metaT takes the assembled contigs and BAM file from the NMDC metaassembly workflow as the input along with the gff file from the annotation workflow and outputs a table with Transcript per million values for different features found in the gff file.

Inputs
~~~~~~

A json files with following entries:

1. Number of CPUs, 
2. Output directory
3. Project name
4. Metagenome Assembled Contig fasta file
5. Sam/Bam file from reads mapping back to contigs
6. GFF file from the annotation workflow
7. Features such as CDS that are available in gff file

.. code-block:: JSON

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

Outputs
~~~~~~~

The output will have a bunch of output directories, files, including statistical numbers, status log and a shell script to reproduce the steps etc. 

The final `MiMAG <https://www.nature.com/articles/nbt.3893#Tab1>`_ output is in `hqmq-metabat-bins` directory and its corresponding lineage result in `gtdbtk_output` directory.::

	|-- 3300037552.bam.sorted
	|-- 3300037552.depth
	|-- 3300037552.depth.mapped
	|-- bins.lowDepth.fa
	|-- bins.tooShort.fa
	|-- bins.unbinned.fa
	|-- checkm-out
	|   |-- bins/
	|   |-- checkm.log
	|   |-- lineage.ms
	|   `-- storage
	|-- checkm_qa.out
	|-- gtdbtk_output
	|   |-- align/
	|   |-- classify/
	|   |-- identify/
	|   |-- gtdbtk.ar122.classify.tree -> classify/gtdbtk.ar122.classify.tree
	|   |-- gtdbtk.ar122.markers_summary.tsv -> identify/gtdbtk.ar122.markers_summary.tsv
	|   |-- gtdbtk.ar122.summary.tsv -> classify/gtdbtk.ar122.summary.tsv
	|   |-- gtdbtk.bac120.classify.tree -> classify/gtdbtk.bac120.classify.tree
	|   |-- gtdbtk.bac120.markers_summary.tsv -> identify/gtdbtk.bac120.markers_summary.tsv
	|   |-- gtdbtk.bac120.summary.tsv -> classify/gtdbtk.bac120.summary.tsv
	|   `-- ..etc 
	|-- hqmq-metabat-bins
	|   |-- bins.11.fa
	|   |-- bins.13.fa
	|   `-- ... etc 
	|-- mbin-2020-05-24.sqlite
	|-- mbin-nmdc.20200524.log
	|-- metabat-bins
	|   |-- bins.1.fa
	|   |-- bins.10.fa
	|   `-- ... etc 


Requirements for Execution
--------------------------

- Docker or other Container Runtime
- `Cromwell <https://github.com/broadinstitute/cromwell>`_ or other WDL-capable Workflow Execution Tool

Running Workflow in Cromwell on Cori
------------------------------------
We provide two ways to run the workflow.  

1. `SlurmCromwellShifter/`: The submit script will request a node and launch the Cromwell.  The Cromwell manages the workflow by using Shifter to run applications. 

2. `CromwellSlurmShifter/`: The Cromwell run in head node and manages the workflow by submitting each step of workflow to compute node where applications were ran by Shifter.

Description of the files in each sud-directory:

 - `.wdl` file: the WDL file for workflow definition
 - `.json` file: the example input for the workflow
 - `.conf` file: the conf file for running Cromwell.
 - `.sh` file: the shell script for running the example workflow

Version History
---------------
- 1.0.0

Point of contact
----------------
Author: Migun Shakya <migun@lanl.gov>

