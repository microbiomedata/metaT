
task megahit_assembly{
	File rrna_clean_reads
	String assem_out_fdr
	String assem_out_prefix
	Int no_of_cpus

#  parameter from https://www.nature.com/articles/s41597-019-0132-4
	command <<<
		megahit --12 "${rrna_clean_reads}" -t "${no_of_cpus}" -o "${assem_out_fdr}" --out-prefix "${assem_out_prefix}" --k-list 23,43,63,83,103,123
	>>>

	meta {
		description: "assemble transcript"
	}

	runtime {
		docker: "vout/megahit"
	}

	output{
		File assem_fna_file = "${assem_out_fdr}/${assem_out_prefix}.contigs.fa"
	}
}

