task clean_gff {
	File annotation_gff
	Int intergenic_len=10
	String DOCKER

	command<<<
	   python /parse_intergenic.py ${annotation_gff} ${intergenic_len} && \

	   sed "s/\'//g" filtered_intergenic.gff | sed "s/-/_/g"  > clean.gff
	>>>
        
	output{
           File filtered_intergenic_gff = "clean.gff" 
        }

        runtime {
                time: "2:00:00"
                docker: DOCKER
                memory: "20 GiB"
        }

        meta {
                author: "Migun Shakya, B10, LANL"
                email: "migun@lanl.gov"
        }
}
task featurecount{
	Int no_of_cpu
	String project_name
	File gff_file_path
	File bam_file_path
	String DOCKER

	command<<<
        featureCounts -a ${gff_file_path}  -O -p -s 1 --countReadPairs -g ID -t CDS,INTERGENIC,misc_feature,ncRNA,regulatory,rRNA,tmRNA,tRNA -T ${no_of_cpu} -o stranded_features.count ${bam_file_path}
	    
	>>>

	output{
		File ct_tbl = "stranded_features.count"
	}

	runtime {
		time: "2:00:00"
		docker: DOCKER
		memory: "120 GiB" 
	}

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}

}

task add_feature_types {
    File sense
    File antisense
	String proj
	String DOCKER

        command {
                 
            python /metaT_sort_rpkm.py -sj ${sense} -aj ${antisense} -id ${proj}
        }

        output{
			File filtered_sense_json = "${proj}_sense_counts.json"
			File filtered_antisense_json = "${proj}_antisense_counts.json"
        	File full_features_tsv = "rpkm_sorted_features.tsv"
            File  top100 = "top100_features.json"
        }

        runtime {
                time: "2:00:00"
                docker: DOCKER
                memory: "120 GiB"
        }

        meta {
                author: "Migun Shakya, B10, LANL"
                email: "migun@lanl.gov"
        }

}
