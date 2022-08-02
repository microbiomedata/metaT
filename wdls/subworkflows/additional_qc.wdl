task bbduk_rrna{
	File rqc_clean_reads
	String DOCKER

	command <<<
		bbduk.sh -Xmx3g in=${rqc_clean_reads} out=filtered_R1.fastq out2=filtered_R2.fastq outm=ribo.fastq k=31 minlen=3 stats=stats.txt
	>>>

	runtime {
		docker: "microbiomedata/bbtools:38.98"
	}

	output{
		Array[File] non_rrna_reads = ["filtered_R1.fastq", "filtered_R2.fastq"]
		File rrna_reads = "ribo.fastq"
	}
}

