
task remove_rrna{
	File rqc_clean_reads
	Map[String, File] sort_rna_db
	Int no_of_threads
	String DOCKER

	command <<<
		sortmerna --ref ${sort_rna_db["rfam_5S_db"]} --ref ${sort_rna_db["rfam_56S_db"]} --ref ${sort_rna_db["silva_arc_16s"]} --ref ${sort_rna_db["silva_arc_23s"]} --ref ${sort_rna_db["silva_bac_16s"]} --ref ${sort_rna_db["silva_bac_23s"]} --ref ${sort_rna_db["silva_euk_18s"]} --ref ${sort_rna_db["silva_euk_28s"]} --reads ${rqc_clean_reads} --aligned aligned --other unaligned --fastx --threads ${no_of_threads} --workdir tmp --paired --paired_in
	>>>

	runtime {
		docker: DOCKER
	}

	output{
		File non_rrna_reads = "unaligned.fastq"
		File rrna_reads = "aligned.fastq"
	}
}

