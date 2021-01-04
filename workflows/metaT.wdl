import "../tasks/feature_counts.wdl" as fc
import "../tasks/calc_scores.wdl" as cs
import "../tasks/to_json.wdl" as tj
import "../tasks/misc_tasks.wdl" as mt

workflow metat_omics {
	Array[String] feat_name_list
	File contig_file_path
	File gff_file_path
	File bam_file_path
	Int no_of_cpu
	String path_to_out
	String? project_name = "metatranscriptomics"

	call mt.clean_gff{
		input:gff_file_path = gff_file_path
	}

	call mt.extract_feats{
		input:gff_file_path = clean_gff.cln_gff_fl
	}

	call mt.create_gffdb{
		input:gff_file_path = clean_gff.cln_gff_fl
	}

	scatter (feat in extract_feats.feats_in_gff) {
		call fc.featurecount{
		input: no_of_cpu = no_of_cpu,
		project_name = project_name,
		gff_file_path = clean_gff.cln_gff_fl,
		bam_file_path = bam_file_path,
		name_of_feat = feat
	}

	call cs.CalScores{
		input: project_name = project_name,
		name_of_feat = feat,
		fc_file = featurecount.ct_tbl
	}

	call tj.conv_to_json{
		input:gff_file_path = clean_gff.cln_gff_fl,
		fasta_file_name = contig_file_path,
		rd_count_fn = featurecount.ct_tbl,
		pkm_sc_fn = CalScores.sc_tbl,
		name_of_feat = feat,
		gff_db_fn = create_gffdb.gff_db_fn
	}

	}

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
		version: "0.0.1"
	}
}

