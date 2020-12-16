import "../tasks/feature_counts.wdl" as fc
import "../tasks/calc_scores.wdl" as cs

workflow metat_omics {
	Array[String] feat_name_list
	File contig_file_path
	File gff_file_path
	File bam_file_path
	Int no_of_cpu
	String path_to_out
	String? project_name = "metatranscriptomics"

	scatter (feat in feat_name_list) {
# FIXME i am getting ERROR: failed to find the gene identifier attribute in the 9th column of the provided GTF file error with other features. See whats going ont here later.
		call fc.featurecount{
		input: no_of_cpu = no_of_cpu,
		project_name = project_name,
		gff_file_path = gff_file_path,
		bam_file_path = bam_file_path,
		name_of_feat = feat
	}

	}


	# call cs.CalScores{
	# 	input: no_of_cpu = no_of_cpu,
	# 	project_name = project_name,
	# 	fc_file = featurecount.ct_tbl
	# }

	
	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
		version: "0.0.1"
	}
}

