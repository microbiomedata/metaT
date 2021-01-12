task clean_gff{
	File gff_file_path

	command <<<
	# removing special characters that featurecount didnt like when parsing gff
		sed "s/\'//g" ${gff_file_path} | sed "s/-/_/g"  > clean.gff

	>>>

	output{
		File cln_gff_fl = "clean.gff"
	}
}


task dockclean_gff{
	File gff_file_path
	String DOCKER
	command <<<
    # removing special characters that featurecount didnt like when parsing gff
		sed "s/\'//g" ${gff_file_path} | sed "s/-/_/g"  > clean.gff

	>>>

	output{
		File cln_gff_fl = "clean.gff"
	}
	
	runtime {
		docker: DOCKER
	}
}


task extract_feats{
	File gff_file_path

	command <<<
	awk -F'\t' '{print $3}' ${gff_file_path} | sort | uniq
	>>>

	output{
		Array[String] feats_in_gff = read_lines(stdout())
	}
}

task dockextract_feats{
	File gff_file_path
	String DOCKER

	command <<<
		awk -F'\t' '{print $3}' ${gff_file_path} | sort | uniq
	>>>

	output{
		Array[String] feats_in_gff = read_lines(stdout())
	}

	runtime {
		docker: DOCKER
	}
}


task create_gffdb{
	File gff_file_path

	command <<<
		python <<CODE
		import gffutils
		gffutils.create_db("${gff_file_path}", dbfn="gff.db", force=True, keep_order=True, merge_strategy="create_unique")
		CODE
	>>>

	output{
		File gff_db_fn = "gff.db"
	}

}

task dockcreate_gffdb{
	File gff_file_path
	String DOCKER

	command <<<
		python <<CODE
		import gffutils
		gffutils.create_db("${gff_file_path}", dbfn="gff.db", force=True, keep_order=True, merge_strategy="create_unique")
		CODE
	>>>

	output{
		File gff_db_fn = "gff.db"
	}
	runtime {
		docker: DOCKER
	}
}


task collect_output{
	Array[File] out_files

	command <<<
		python <<OEF
		import json
		result = []
		list_of_fls = ['${sep="','" out_files}']
		for f in list_of_fls:
			with open(f, "rb") as infile:
				result.append(json.load(infile))
		with open("output.json", "w") as outfile:
			json.dump(result, outfile, indent=4)
		OEF
	>>>

	runtime {
		memory: "1 GiB"
		cpu: 1
	}

	output{
		File out_json_file = "output.json"
	}
}

task dockcollect_output{
	Array[File] out_files
	String DOCKER

	command <<<
		python <<OEF
		import json
		result = []
		list_of_fls = ['${sep="','" out_files}']
		for f in list_of_fls:
			with open(f, "rb") as infile:
				result.append(json.load(infile))
		with open("output.json", "w") as outfile:
			json.dump(result, outfile, indent=4)
		OEF
	>>>

	runtime {
		docker: DOCKER
	}

	output{
		File out_json_file = "output.json"
	}
}



task split_fastq{
	File intleave_fq_fl

	command <<<
		cat ${intleave_fq_fl} | paste - - - - - - - - | tee | cut -f 1-4 | tr "\t" "\n" | egrep -v '^$' > R1.fastq
		cat ${intleave_fq_fl} | paste - - - - - - - - | tee | cut -f 5-8 | tr "\t" "\n" | egrep -v '^$' > R2.fastq
		
	>>>

	output{
		File out_r1_file = "R1.fastq"
		File out_r2_file = "R2.fastq"
	}
}

