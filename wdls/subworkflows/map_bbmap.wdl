task bbmap_mapping{
	Int no_of_cpus
	Array[File] rna_clean_reads
	Boolean stranded = true
	File assembly_fna
	# String DOCKER


	command {
		if [["${stranded}" = true]]; then
            bbmap.sh nodisk=true interleaved=true t=${no_of_cpus} samestrandpairs=t ambiguous=random in1=${rna_clean_reads[0]} in2=${rna_clean_reads[1]} ref=${assembly_fna} out=mapped_sorted.bam covstats=covstats.txt bamscript=to_bam.sh nhtag=t && \
			samtools sort mapped.bam -o mapped_sorted.bam
		else
		    bbmap.sh nodisk=true interleaved=true t=${no_of_cpus} samestrandpairs=f ambiguous=random in=${rna_clean_reads[0]} ref=${assembly_fna} out=mapped.bam covstats=covstats.txt bamscript=to_bam.sh nhtag=t && \
			samtools sort mapped.bam -o mapped_sorted.bam
		fi 
	}

	output{
		File map_bam = "mapped_sorted.bam"
		File covstats = "covstats.txt"
	}
	
	runtime {
		time: "2:00:00"
		docker:'microbiomedata/bbtools:latest'
                memory: "120 GiB"
	}
}
