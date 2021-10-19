task bbmap_mapping{
	Int no_of_cpus
	Array[File] rna_clean_reads
	Array[File] hisat2_ref_dbs
	File hisat_db_name
	# String DOCKER


	command {
		#hisat2 --dta -p ${no_of_cpus} --un-conc unaligned.fastq -x ${hisat_db_name} -1 ${rna_clean_reads[0]} -2 ${rna_clean_reads[1]} | samtools sort | samtools view -Su -o mapped_sorted.bam
                bbmap.sh nodisk=true interleaved=false ambiguous=all in1={rna_clean_reads[0]} in2={rna_clean_reads[1]} ref=${hisat2_ref_ndbs} out=mapped.bam covstats=covstats.txt bamscript=to_bam.sh nhtag=t && \
                samtools sort -@ 10 -o mapped_sorted.bam mapped.bam 
	}

	output{
		File map_bam = "mapped_sorted.bam"
		Array[File] unaln_fl = ["unaligned.1.fastq", "unaligned.1.fastq"]
	}
	
	runtime {
		docker:'microbiomedata/bbtools:latest'
	}
}
