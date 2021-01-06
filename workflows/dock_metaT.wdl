import "../tasks/feature_counts.wdl" as fc
import "../tasks/calc_scores.wdl" as cs
import "../tasks/to_json.wdl" as tj
import "../tasks/misc_tasks.wdl" as mt

workflow metat_omics {
	File contig_file_path
	File gff_file_path
	File bam_file_path
	Int no_of_cpu
	String? project_name = "metatranscriptomics"
	String? docker = "microbiomedata/meta_t:latest"

	call mt.dockclean_gff{
		input:gff_file_path = gff_file_path,
		DOCKER = docker
	}

	call mt.dockextract_feats{
		input:gff_file_path = dockclean_gff.cln_gff_fl,
		DOCKER = docker
	}

	call mt.dockcreate_gffdb{
		input:gff_file_path = dockclean_gff.cln_gff_fl,
		DOCKER = docker
	}

	scatter (feat in dockextract_feats.feats_in_gff) {
		call fc.dock_featurecount{
		input: no_of_cpu = no_of_cpu,
		project_name = project_name,
		gff_file_path = dockclean_gff.cln_gff_fl,
		bam_file_path = bam_file_path,
		name_of_feat = feat,
		DOCKER = docker
	}

	call cs.dockcal_scores{
		input: project_name = project_name,
		name_of_feat = feat,
		fc_file = dock_featurecount.ct_tbl,
		DOCKER = docker
	}

	call tj.dock_convtojson{
		input:gff_file_path = dockclean_gff.cln_gff_fl,
		fasta_file_name = contig_file_path,
		rd_count_fn = dock_featurecount.ct_tbl,
		pkm_sc_fn = dockcal_scores.sc_tbl,
		name_of_feat = feat,
		gff_db_fn = dockcreate_gffdb.gff_db_fn,
		DOCKER = docker
	}

	}

	call mt.dockcollect_output{
		input: out_files = dock_convtojson.out_json_file,
		DOCKER = docker
	}

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
		version: "0.0.1"
	}
}

