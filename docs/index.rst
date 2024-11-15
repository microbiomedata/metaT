Metatranscriptome Workflow (v0.0.6)
=====================================

.. image:: metat_workflow2024.svg
   :scale: 25%
   :alt: Metatranscriptome workflow


Workflow Overview
-----------------
MetaT is a workflow designed to analyze metatranscriptomes, building on top of already existing NMDC workflows for processing input. The metatranscriptoimics workflow takes in raw data and starts by quality filtering the reads using the `MetaT RQC workflow <https://github.com/microbiomedata/metaT_ReadsQC>`_. With filtered reads, the workflow filters out rRNA reads (and separates the interleaved file into separate files for the pairs) using bbduk (BBTools). After the filtering steps, reads are assembled into transcripts using the `MetaT Assembly workflow <https://github.com/microbiomedata/metaT_Assembly>`_ and annotated using the `Metagenome Anotation workflow <https://github.com/microbiomedata/mg_annotation>`_; producing GFF funtional annotation files. Features are counted with `MetaT Read Counting <https://github.com/microbiomedata/metaT_ReadCounts>`_ which assigns mapped reads to genomic features for sense and antisense reads. Please refer to each repository for their detailed documentation. 


Workflow Availability
---------------------
The workflow uses the listed docker images to run all third-party tools.
The workflow is available in GitHub: 
https://github.com/microbiomedata/metaT; and the corresponding Docker images that have all the required dependencies are available in following DockerHub:
- `microbiomedata/meta_t:0.0.5 <https://hub.docker.com/r/microbiomedata/meta_t>`_
- `bryce911/bbtools:38.86 <https://hub.docker.com/r/microbiomedata/bbtools>`_


Requirements for Execution (recommendations are in bold):  
--------------------------------------------------------
1. WDL-capable Workflow Execution Tool (**Cromwell**)
2. Container Runtime that can load Docker images (**Docker v2.1.0.3 or higher**)

Workflow Dependencies
---------------------
Third-party software (These are included in the Docker images.)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. `BBTools v38.94 <https://jgi.doe.gov/data-and-tools/bbtools/>`_. (License: `BSD-3-Clause-LBNL <https://bitbucket.org/berkeleylab/jgi-bbtools/src/master/license.txt>`_.)
2. `Python v3.7.12 <https://www.python.org/>`_.  (License: Python Software Foundation License)
3. `pandas v1.0.5 <https://pandas.pydata.org/>`_. (python package) (License: BSD-3-Clause)
4. `gffutils v0.10.1 <https://pythonhosted.org/gffutils/>`_. (python package) (License: MIT)



Requisite database
~~~~~~~~~~~~~~~~~~
The RQCFilterData Database must be downloaded and installed. This is a 106 GB tar file which includes reference datasets of artifacts, adapters, contaminants, the phiX genome, rRNA kmers, and some host genomes.  The following commands will download the database: 

.. code-block:: bash

  wget http://portal.nersc.gov/dna/microbial/assembly/bushnell/RQCFilterData.tar
  tar -xvf RQCFilterData.tar
  rm RQCFilterData.tar	


Sample dataset(s)
------------------
- Processed Metatranscriptome of soil microbial communities from the East River watershed near Crested Butte, Colorado, United States - ER_RNA_119 (`SRR11678315 <https://www.ncbi.nlm.nih.gov/sra/SRX8239222>`_) with `metadata available in the NMDC Data Portal <https://data.microbiomedata.org/details/study/nmdc:sty-11-dcqce727>`_. 
  - The zipped raw fastq file is available `here <https://portal.nersc.gov/project/m3408//test_data/metaT/SRR11678315.fastq.gz>`_
  - The sample outputs are available `here <https://portal.nersc.gov/cfs/m3408/test_data/metaT/SRR11678315/>`_


Input: A JSON file containing the following
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1.	output file prefix
2.  path to `input_file` if interleaved file
3.  paths to `input_fq1` and `input_fq2` non-interleaved paired-end reads 
4.	input_interleaved (boolean)
5.	RNA strand type (optional) either left blank, `aRNA`, or `non_stranded_RNA`

For further customization (such as databases and licenses outside of the NERSC / JAWS system), please refer to the individual repositories and add input parameters to metaT.wdl. Here is an example for adding the MetaT ReadsQC database:

- Add to input{`String rqc_db`}
- Add to call readsqc.metaTReadsQC as qc {input: `database = rqc_db`}
- Add to input.json {`"nmdc_metat.rqc_db": "/your_refdata/"`}


An example JSON file is shown below:

.. code-block:: JSON

  {
      "nmdc_metat.input_file": "https://portal.nersc.gov/project/m3408//test_data/metaT/SRR11678315.fastq.gz",
      "nmdc_metat.project_id":"SRR11678315-int-0.1",
      "nmdc_metat.input_interleaved": true
  }


Output
~~~~~~
Outputs are split up between steps of the workflow. The first half of the workflow will output rRNA-filtered reads and the assembled transcripts. After annotations and featureCount steps include a JSON file that contain read counts for both sense and antisense, reads, and information from annotation for each feature. This is the first block from the top 100 features output json:

.. code-block:: JSON

 {
        "featuretype":"CDS",
        "seqid":"SRR11678315-int-0.1_02468",
        "id":"SRR11678315-int-0.1_02468_2_823",
        "source":"Prodigal v2.6.3_patched",
        "start":2,
        "end":823,
        "length":822,
        "strand":"-",
        "frame":"0",
        "product":"cation transport ATPase",
        "product_source":"COG2217",
        "sense_read_count":3142,
        "mean":1563.9,
        "median":1458.0,
        "stdev":617.57,
        "antisense_read_count":3064,
        "meanA":1506.08,
        "medianA":1408.0,
        "stdevA":599.53
    }

Below is an example of the output directory files with descriptions to the right.


.. list-table:: 
   :widths: 25 50
   :header-rows: 1

   * - Directory/File Name
     - Description

   * - readsQC/filtered.fastq.gz
     - non-ribosomal reads 
   * - readsQC/filterStats.txt
     - summary statistics in JSON format
   * - readsQC/filterStats2.txt
     - more detailed summary statistics
   * - readsQC/rRNA.fastq.gz
     - ribosomal reads  
   * - readsQC/rqc.info
     - workflow information 
   * - readsQC/qc_stats.json
     - summary statistics in json form

   * - assembly/contigs.fna
     - assembled contigs
   * - assembly/scaffolds.fna
     - assembled scaffolds
   * - assembly/readlen.txt
     - read length information
   * - assembly/bamfiles.tar
     - zipped collection of bam files 
   * - assembly/pairedMapped.sam.gz
     - alignment of reads and transcripts
   * - assembly/pairedMapped.bam
     - binary alignment of reads and transcripts
   * - assembly/pairedMapped_sorted.bam.bai
     - bam index file 
   * - assembly/pairedMapped_sorted.bam.cov
     - bam coverage file 
   * - assembly/scaffold_stats.json
     - scaffold coverage statistics
   * - assembly/assy.info
     - assembly workflow information 
   * - assembly/spades.log
     - spades run log 


   * - annotation/proteins.faa  
     - fasta containing protiens 
   * - annotation/structural_annotation.gff
     - structural features  
   * - annotation/ko_ec.gff
     - features from ko and ec database
   * - annotation/functional_annotation.gff
     - functional features
   * - annotation/ec.tsv
     - ec terms tsv
   * - annotation/ko.tsv
     - ko terms tsv

   * - annotation/scaffold_lineage.tsv
     - ec terms tsv
   * - annotation/anno_stats.tsv
     - ko terms tsv
   * - annotation/anno_stats.json
     - ec terms tsv
   * - annotation/cog.gff
     - features from cog databse
   * - annotation/pfam.gff
     - features from pfam database
   * - annotation/tigrfam.gff
     - features from trigfam database
   * - annotation/smart.gff
     - features from smart database
   * - annotation/supfam.gff
     - features from supfam databse
   * - annotation/cath_funfam.gff
     - features from cath database
   * - annotation/crt.gff
     - features from crt database
   * - annotation/genemark.gff
     - features from genemark database
   * - annotation/prodigal.gff
     - features from prodigal database
   * - annotation/trna.gff
     - trna features
   * - annotation/rfam.gff
     - features from rfam database

   * - **annotation/product_names.tsv**
     - table of product names
   * - annotation/crt.crisprs
     - file of crisper terms
   * - annotation/anno.info
     - annotation workflow info
   * - annotation/renamed_contigs.fna
     - contigs renamed with annotation id
   * - annotation/contig_names_mapping.tsv
     - mapped renames of annotation id and original
   * - readmap/rnaseq_gea.txt
     - read counts table 
   * - readmap/readcount.stats.log
     - read count statistics 
   * - readmap/readcount.info
     - read count workflow info
   * - readmap/paired.gff.json
     - renamed gff converted to json
   * - readmap/paired.rc.json
     - read count file renamed to json
   * - readmap/gff_rc.json
     - combination of gff and read count files
   * - readmap/cds_counts.json
     - cds only counts
   * - readmap/sense_counts.json
     - sense strand only counts
   * - readmap/antisense_counts.json
     - antisense strand only counts
   * - readmap/top100_features.json
     - top 100 feature counts 
   * - readmap/sorted_features.json
     - feature counts sorted from most to least
   * - readmap/sorted_features.tsv
     - tsv format of sorted feature counts 


Version History 
---------------
- 0.0.2 (release date 01/14/2021; previous versions: 0.0.1)
- 0.0.3 (release date 07/28/2021; previous versions: 0.0.2)
- 0.0.4 (release date 08/31/2021; previous versions: 0.0.3)
- 0.0.5 (release date 10/28/2021; previous versions: 0.0.4)
- 0.0.6 (release date 09/17/2024; previous versions: 0.0.5)

Points of contact
-----------------
- Author: Migun Shakya <migun@lanl.gov>
- Maintainer: Kaitlyn Li <kli@lanl.gov>

