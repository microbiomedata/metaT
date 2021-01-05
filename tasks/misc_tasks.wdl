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

	command <<<
    # removing special characters that featurecount didnt like when parsing gff
		sed "s/\'//g" ${gff_file_path} | sed "s/-/_/g"  > clean.gff

	>>>

	output{
		File cln_gff_fl = "clean.gff"
	}
	
	runtime {
		docker: 'microbiomedata/meta_t:latest'
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

	command <<<
		awk -F'\t' '{print $3}' ${gff_file_path} | sort | uniq
	>>>

	output{
		Array[String] feats_in_gff = read_lines(stdout())
	}

	runtime {
		docker: 'microbiomedata/meta_t:latest'
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
		docker: 'microbiomedata/meta_t:latest'
	}
}
