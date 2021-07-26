# task BuildHisat2{
# 	Int cpu
# 	File ref_genome
# 	String ref_name = basename(ref_genome, ".fna")

# 	meta {
# 		description: "build reference index files for hisat2"
# 	}

# 	command {
# 		hisat2-build -q -p ${cpu} ${ref_genome} ${ref_name}
# 		touch ${ref_name}
# 	}

# 	output {
# 		Array[File] hs = [ref_name + ".1.ht2", ref_name + ".2.ht2",
# 						ref_name + ".3.ht2",
# 					  	ref_name + ".4.ht2",
# 					  	ref_name + ".5.ht2",
# 					  	ref_name + ".6.ht2",
# 					  	ref_name + ".7.ht2",
# 					  	ref_name + ".8.ht2"]
# 		File db = ref_name
# 	}
# }


# task shift_BuildHisat2{
# 	Int no_of_cpus
# 	File ref_genome
# 	String container
# 	String ref_name = basename(ref_genome, ".fna")

# 	meta {
# 		description: "build reference index files for hisat2"
# 	}

# 	command {
# 		shifter --image=${container} hisat2-build -q -p ${no_of_cpus} ${ref_genome} ${ref_name}
# 		touch ${ref_name}
# 	}

# 	output {
# 			Array[File] hs = [ref_name + ".1.ht2", ref_name + ".2.ht2",
# 						ref_name + ".3.ht2",
# 					  	ref_name + ".4.ht2",
# 					  	ref_name + ".5.ht2",
# 					  	ref_name + ".6.ht2",
# 					  	ref_name + ".7.ht2",
# 					  	ref_name + ".8.ht2"]
# 		File db = ref_name
# 	}

# 	runtime {
# 		poolname: "aim2_metaT"
# 		cluster: "cori"
# 		time: "01:00:00"
# 		no_of_cpus: no_of_cpus
# 		mem: "115GB"
# 		node: 1
# 		nwpn: 2
# 	}
# }

task dock_BuildHisat2{
    Int no_of_cpu
    File assem_contig_fna

    meta {
        description: "build reference index files for hisat2"
    }

    command {
        hisat2-build -q -p ${no_of_cpu} ${assem_contig_fna} megahit_hisat2
        touch megahit_hisat2
        
    }
    output {
        Array[File] hs = ["megahit_hisat2.1.ht2", "megahit_hisat2.2.ht2",
                        "megahit_hisat2.3.ht2",
                          "megahit_hisat2.4.ht2",
                          "megahit_hisat2.5.ht2",
                          "megahit_hisat2.6.ht2",
                          "megahit_hisat2.7.ht2",
                          "megahit_hisat2.8.ht2"]
        File db = "megahit_hisat2"
    }
    runtime {
        docker: 'intelliseqngs/hisat2:1.2.1'
    }
}