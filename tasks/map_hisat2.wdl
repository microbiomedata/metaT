task mapping{
	Int cpu
	Array[File] PairedReads
	String project_name
	Array[File] hisat2_ref
	File db

	command {
		hisat2 -p ${cpu} -x ${db} -1 ${PairedReads[0]} -2 ${PairedReads[1]} | samtools view -Sbo ${project_name}.bam
	}

	output{
		File map_bam = "${project_name}.bam"
	}
}

task hisat2_mapping{
	Int no_of_cpus
	Array[File] rna_clean_reads
	Array[File] hisat2_ref_dbs
	File hisat_db_name


	command {
		hisat2 --dta -p ${no_of_cpus} --un-conc unaligned.fastq -x ${hisat_db_name} -1 ${rna_clean_reads[0]} -2 ${rna_clean_reads[1]} | samtools sort | samtools view -Su -o mapped_sorted.bam
	}

	output{
		File map_bam = "mapped_sorted.bam"
		Array[File] unaln_fl = ["unaligned.1.fastq", "unaligned.1.fastq"]
	}
	
	runtime {
		docker: 'intelliseqngs/hisat2:1.2.1'
	}
}