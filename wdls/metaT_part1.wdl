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
	String? outdir

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

	call make_part1_output{
		input: outdir=outdir,
			non_rrna_fastq = bbduk_rrna.non_rrna_reads,
        	assemb_file = megahit_assembly.assem_fna_file
	}

	output {
		Array[File] non_rrna_fastq = make_part1_output.non_rrna_reads
        File assemb_file = make_part1_output.assem_fna_file
    }


	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
		version: "0.0.2"
	}
}
	task make_part1_output{
 	String outdir
 	Array[File] non_rrna_fastq
	File assemb_file


 	command{
 		if [ ! -z ${outdir} ]; then
 			mkdir -p ${outdir}
 			non_rrna_fastq_path=`dirname ${non_rrna_fastq[0]}`
 			assemb_file_path=`dirname ${assemb_file}`
 			mv -f $non_rrna_fastq_path/filtered_R*.fastq ${outdir}
 			mv -f $assemb_file_path/${assemb_file} ${outdir}/
 			chmod 764 -R ${outdir}
 		fi
 	}
	runtime {
		mem: "1 GiB"
		cpu:  1
	}
	output{
		Array[File] non_rrna_fastq = ["${outdir}/filtered_R1.fastq", "${outdir}/filtered_R2.fastq"]
		File assemb_file = "${outdir}/${assemb_file}"

	}
}

