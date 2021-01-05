task cal_scores{
	File edgeR="scripts/edgeR.R"
	String project_name
	String name_of_feat
	File fc_file

	meta {
		description: "Calculate RPKMs"
	}

	command {
		mv ${edgeR} script.R
		Rscript script.R -r ${fc_file} -n ${name_of_feat} -o ${name_of_feat}_sc.tsv -s ${project_name}
	}

	output {
		File sc_tbl = "${name_of_feat}_sc.tsv"
	}
}

task dockcal_scores{
	File edgeR="scripts/edgeR.R"
	String project_name
	String name_of_feat
	File fc_file

	meta {
		description: "Calculate RPKMs"
	}


	command {
		mv ${edgeR} script.R
		Rscript script.R -r ${fc_file} -n ${name_of_feat} -o ${name_of_feat}_sc.tsv -s ${project_name}
	}

	output {
		File sc_tbl = "${name_of_feat}_sc.tsv"
	}

	runtime {
		docker: 'microbiomedata/meta_t:latest'
	}
}
