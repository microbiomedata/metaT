task bbmap_mapping{
	Int no_of_cpus
	Array[File] rna_clean_reads
	Array[File] hisat2_ref_dbs
	File assembly_fna
	# String DOCKER


	command {
                bbmap.sh nodisk=true interleaved=false ambiguous=all in1=${rna_clean_reads[0]} in2=${rna_clean_reads[1]} ref=${assembly_fna} out=mapped_sorted.bam covstats=covstats.txt bamscript=to_bam.sh nhtag=t 
	}

	output{
		File map_bam = "mapped_sorted.bam"
		Array[File] unaln_fl = ["unaligned.1.fastq", "unaligned.1.fastq"]
	}
	
	runtime {
		docker:'microbiomedata/bbtools:latest'
	}
}
