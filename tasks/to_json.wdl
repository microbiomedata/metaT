task conv_to_json{
	File gff_file_path
	File gff_db_fn
	File fasta_file_name
	File pkm_sc_fn
	File rd_count_fn
	String name_of_feat
	File py_pack_path="pyp_metat"

	command <<<
		cp -R ${py_pack_path} pyp_metat
		python <<CODE
		from pyp_metat.to_json import ConverToJson
		json_conv_class = ConverToJson(gff_file_name="${gff_file_path}", gff_db_fn="${gff_db_fn}", fasta_file_name="${fasta_file_name}", pkm_sc_fn="${pkm_sc_fn}", rd_count_fn="${rd_count_fn}", name_of_feat="${name_of_feat}", out_json_file="${name_of_feat}.json")
		json_conv_class.gff2json()
		CODE
	>>>

	output{
		File out_json_file = "${name_of_feat}.json"
	}
}

    