
task remove_rrna{
	File rqc_clean_reads
	String fdr_w_rnadb
	Int no_of_threads

	command <<<
		sortmerna --ref "${fdr_w_rnadb}/rfam-5s-database-id98.fasta" --ref "${fdr_w_rnadb}/rfam-5.8s-database-id98.fasta" --ref "${fdr_w_rnadb}/silva-arc-16s-id95.fasta" --ref "${fdr_w_rnadb}/silva-arc-23s-id98.fasta" --ref "${fdr_w_rnadb}/silva-bac-23s-id98.fasta" --ref "{fdr_w_rnadb}/silva-bac-16s-id90.fasta" --ref "{fdr_w_rnadb}/silva-euk-18s-id95.fasta" --ref "{fdr_w_rnadb}/silva-euk-28s-id98.fasta" --reads "${rqc_clean_reads}" --aligned aligned --other unaligned --fastx --threads "${no_of_threads}" --workdir tmp --paired --paired_in
	>>>


	runtime {
		docker: "bschiffthaler/sortmerna"
		memory: "50G"
		cpu: no_of_threads
	}

	output{
		File non_rrna_reads = "unaligned" + ".fastq"
		File rrna_reads = "aligned" + ".fastq"
	}
}

