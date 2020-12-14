task CalScores{
	File edgeR="scripts/edgeR.R"
	Int no_of_cpu
	String project_name
	File fc_file

	meta {
		description: "Calculate RPKMs for CDS"
	}

	command {
		mv ${edgeR} script.R
		Rscript script.R -r ${fc_file} -n CDS -o ${project_name}_sc_tbl.tsv -s ${project_name}
	}

	output {
	File sc_tbl = "${project_name}_sc_tbl.tsv"
	}
}



task shift_CalScores{
	Int cpu
	String project_name
	File fc_file
	String container

	meta {
		description: "Calculate RPKMs for CDS"
	}

	command {
		shifter --image=${container} edgeR.R -r ${fc_file} -n CDS -o ${project_name}_sc_tbl.tsv -s ${project_name}
	}

	runtime {
		poolname: "aim2_metaT"
		cluster: "cori"
		time: "01:00:00"
		cpu: cpu
		mem: "10GB"
		node: 1
		nwpn: 1
	}

	output {
	File sc_tbl = "${project_name}_sc_tbl.tsv"
	}
}


task dock_CalScores{
	Int cpu
	String project_name
	File fc_file

	meta {
		description: "Calculate RPKMs for CDS"
	}

	command {
		edgeR.R -r ${fc_file} -n CDS -o ${project_name}_sc_tbl.tsv -s ${project_name}
	}

	output {
	File sc_tbl = "${project_name}_sc_tbl.tsv"
	}

	runtime {
		docker: 'migun/nmdc_metat:latest'
	}
}
