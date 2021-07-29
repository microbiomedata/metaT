import "feature_counts.wdl" as fc
import "build_hisat2.wdl" as bh
import "map_hisat2.wdl" as mh
import "calc_scores.wdl" as cs
import "to_json.wdl" as tj
import "misc_tasks.wdl" as mt
import "additional_qc.wdl" as aq
import "metat_assembly.wdl" as ma
import "run_stringtie.wdl" as rs

workflow metat_omics {
	File rqc_clean_reads
	File ribo_kmer_file
	Int no_of_cpus
	String? project_name = "metatranscriptomics"
	String? docker = "microbiomedata/meta_t:latest"

	call aq.bbduk_rrna{
		input:rqc_clean_reads = rqc_clean_reads,
		ribo_kmer_file = ribo_kmer_file,
		no_of_threads = no_of_cpus,
		DOCKER = docker
	}

	call ma.megahit_assembly{
		input:rrna_clean_reads = bbduk_rrna.non_rrna_reads,
		assem_out_fdr = "out_fdr",
		assem_out_prefix = "megahit_assem",
		no_of_cpus = no_of_cpus,
		DOCKER = docker
	}

	output {
		Array[File] non_rrna_fastq = bbduk_rrna.non_rrna_reads
        File assemb_file = megahit_assembly.assem_fna_file
    }


	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
		version: "0.0.3"
	}
}

