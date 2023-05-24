task cal_scores{
	String project_name
	String name_of_feat
	File fc_file
	String DOCKER 
	meta {
		description: "Calculate RPKMs"
	}


	command {
		Rscript edgeR.R --reads_table ${fc_file} --name ${name_of_feat} --out_tbl ${name_of_feat}_sc.tsv --sample ${project_name}
	}

	output {
		File sc_tbl = "${name_of_feat}_sc.tsv"
	}

	runtime {
		docker: DOCKER
	}
}
