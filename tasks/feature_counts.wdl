task featurecount{
	Int no_of_cpu
	String project_name
	File gff_file_path
	File bam_file_path
	String name_of_feat

	command {
		featureCounts -a ${gff_file_path} -B -p -P -C -g ID -t ${name_of_feat} -T ${no_of_cpu} -o ${name_of_feat}.count ${bam_file_path} 
	}

	output{
		File ct_tbl = "${name_of_feat}.count"
	}
}



task dock_featurecount{
	Int no_of_cpu
	String project_name
	File gff_file_path
	File bam_file_path
	String name_of_feat
	String DOCKER

	command {
		featureCounts -a ${gff_file_path} -B -p -P -C -g ID -t ${name_of_feat} -T ${no_of_cpu} -o ${name_of_feat}.count ${bam_file_path} 
	}

	output{
		File ct_tbl = "${name_of_feat}.count"
	}

	runtime {
		docker: DOCKER
		memory: "50G"
		cpu: no_of_cpu
	}

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}

}