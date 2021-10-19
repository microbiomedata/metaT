task dock_featurecount{
	Int no_of_cpu
	String project_name
	File gff_file_path
	File bam_file_path
	String name_of_feat
	String DOCKER

	command {
	    #featureCounts -a ${gff_file_path} -B -p -P -C -g ID -t ${name_of_feat} -T ${no_of_cpu} -o ${name_of_feat}.count ${bam_file_path} 
            featureCounts -a ${gff_file_path}  -O -p -s 1 --countReadPairs -g ID -t CDS,INTERGENIC,misc_feature,ncRNA,regulatory,rRNA,tmRNA,tRNA -T ${no_of_cpu} -o sense_count ${bam_file_path}
	    featureCounts -a ${gff_file_path}  -O -p -s 2 --countReadPairs -g ID -t CDS,INTERGENIC,misc_feature,ncRNA,regulatory,rRNA,tmRNA,tRNA -T ${no_of_cpu} -o antisense.count ${bam_file_path}
	    cat *.count > features.count | grep -v "#" > all_features.count 
	}

	output{
		File ct_tbl = "all_features.count"
	}

	runtime {
		docker: DOCKER
	}

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}

}
