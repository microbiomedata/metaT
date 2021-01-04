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
