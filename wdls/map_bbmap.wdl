task bbmap_mapping{
	Int no_of_cpus
	Array[File] rna_clean_reads
	#Array[File] hisat2_ref_dbs
	File assembly_fna
	# String DOCKER


	command {
                bbmap.sh nodisk=true interleaved=true t=${no_of_cpus} ambiguous=random in=${rna_clean_reads[0]} ref=${assembly_fna} out=mapped_sorted.bam covstats=covstats.txt bamscript=to_bam.sh nhtag=t 
	}

	output{
		File map_bam = "mapped_sorted.bam"
	}
	
	runtime {
		time: "2:00:00"
		docker:'microbiomedata/bbtools:latest'
                memory: "120 GiB"
	}
}
