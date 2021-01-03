task conv_to_json{
	Array[String] feat_name_list
	File gff_file_path
	File fasta_file_name
	String project_name
	File py_pack_path="pyp_metat"

	command <<<
		cp -R ${py_pack_path} pyp_metat
		python <<CODE
		from pyp_metat.to_json import ConverToJson
		json_conv_class = ConverToJson(gff_file_name=${gff_file_path}, fasta_file_name=${fasta_file_name}, list_of_feat=${sep=',' feat_name_list}, name_of_proj=${project_name}, out_json_file="out.json")
		conv_json_insta.gff2json()
		CODE
	>>>

	output{
		File out_json_file = "out.json"
	}
}

    