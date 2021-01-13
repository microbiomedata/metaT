task run_stringtie{
	Int no_of_cpus
	File bam_fl_path
	String DOCKER

	command {
		stringtie -o out.gtf -p ${no_of_cpus} -A gene_abundan.gtf ${bam_fl_path}
	}

	output{
		File abun_info_fl = "gene_abundan.gtf"
		File out_info_fl = "out.gtf"
	}
	
	runtime {
		docker: DOCKER
	}
}