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


task shift_featurecount{
	Int no_of_cpu
	String project_name
	File ref_gff
	File bam_file_path
	String container

	command {
		shifter --image=${container} featureCounts -a ${ref_gff} -B -p -P -C -g ID -t gene -T ${no_of_cpu} -o ${project_name}.count ${bam_file_path} 
	}

	runtime {
	poolname: "aim2_metaT"
		cluster: "cori"
		time: "01:00:00"
		no_of_cpu: no_of_cpu
		mem: "115GB"
		node: 1
		nwpn: 4
	}

	output{
		File ct_tbl = "${project_name}.count"
	}
}


task dock_featurecount{
	Int no_of_cpu
	String project_name
	File gff_file_path
	File bam_file_path
	String name_of_feat

	command {
		sed "s/\'//g" ${gff_file_path} > clean.gff
		featureCounts -a clean.gff -B -p -P -C -g ID -t ${name_of_feat} -T ${no_of_cpu} -o ${name_of_feat}.count ${bam_file_path} 
	}

	output{
		File ct_tbl = "${project_name}.count"
	}

	runtime {
		docker: 'migun/nmdc_metat:latest'
		memory: "50G"
		cpu: no_of_cpu
	}

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}

}