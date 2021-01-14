import "../tasks/feature_counts.wdl" as fc
import "../tasks/build_hisat2.wdl" as bh
import "../tasks/map_hisat2.wdl" as mh
import "../tasks/calc_scores.wdl" as cs
import "../tasks/to_json.wdl" as tj
import "../tasks/misc_tasks.wdl" as mt
import "../tasks/additional_qc.wdl" as aq
import "../tasks/metat_assembly.wdl" as ma
import "../tasks/run_stringtie.wdl" as rs

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

	call bh.dock_BuildHisat2{
		input:no_of_cpu = no_of_cpus,
		assem_contig_fna = megahit_assembly.assem_fna_file,
		DOCKER = docker
	}
	call mh.hisat2_mapping{
		input:rna_clean_reads = bbduk_rrna.non_rrna_reads,
		no_of_cpus = no_of_cpus,
		hisat2_ref_dbs = dock_BuildHisat2.hs,
		hisat_db_name = dock_BuildHisat2.db,
		DOCKER = docker
	}

	call rs.run_stringtie{
		input:bam_fl_path = hisat2_mapping.map_bam,
		no_of_cpus = no_of_cpus,
		DOCKER = docker

	}

	call tj.dock_gtftojson{
		input:gtf_file_name = run_stringtie.out_info_fl,
		name_of_feat = "transcript",
		DOCKER = docker
	
	}
	# call mt.dockclean_gff{
	# 	input:gff_file_path = gff_file_path,
	# 	DOCKER = docker
	# }

	# call mt.dockextract_feats{
	# 	input:gff_file_path = dockclean_gff.cln_gff_fl,
	# 	DOCKER = docker
	# }

	# call mt.dockcreate_gffdb{
	# 	input:gff_file_path = dockclean_gff.cln_gff_fl,
	# 	DOCKER = docker
	# }

	# scatter (feat in dockextract_feats.feats_in_gff) {
	# 	call fc.dock_featurecount{
	# 	input: no_of_cpu = no_of_cpu,
	# 	project_name = project_name,
	# 	gff_file_path = dockclean_gff.cln_gff_fl,
	# 	bam_file_path = bam_file_path,
	# 	name_of_feat = feat,
	# 	DOCKER = docker
	# }

	# call cs.dockcal_scores{
	# 	input: project_name = project_name,
	# 	name_of_feat = feat,
	# 	fc_file = dock_featurecount.ct_tbl,
	# 	DOCKER = docker
	# }

	# call tj.dock_convtojson{
	# 	input:gff_file_path = dockclean_gff.cln_gff_fl,
	# 	fasta_file_name = contig_file_path,
	# 	rd_count_fn = dock_featurecount.ct_tbl,
	# 	pkm_sc_fn = dockcal_scores.sc_tbl,
	# 	name_of_feat = feat,
	# 	gff_db_fn = dockcreate_gffdb.gff_db_fn,
	# 	DOCKER = docker
	# }

	# }

	# call mt.dockcollect_output{
	# 	input: out_files = dock_convtojson.out_json_file,
	# 	DOCKER = docker
	# }

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
		version: "0.0.1"
	}
}

