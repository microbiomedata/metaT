task dock_featurecount{
	Int no_of_cpu
	String project_name
	File gff_file_path
	File bam_file_path
	File name_of_feat
	String DOCKER

	command {
            featureCounts -a ${gff_file_path}  -O -p -s 1 --countReadPairs -g ID -t ${name_of_feat} -T ${no_of_cpu} -o ${name_of_feat}_sense.count ${bam_file_path}
	    featureCounts -a ${gff_file_path}  -O -p -s 2 --countReadPairs -g ID -t ${name_of_feat} -T ${no_of_cpu} -o ${name_of_feat}_antisense.count ${bam_file_path}
	    cat ${name_of_feat}_sense.count ${name_of_feat}_antisense.count > ${name_of_feat}.count
	}

	output{
		File ct_tbl = "${name_of_feat}.count"
	}

	runtime {
		docker: DOCKER
	}

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}

}
