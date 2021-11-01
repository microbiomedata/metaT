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
	String prefix

	command <<<
		out_file = sub(prefix, "_out.json", "")
		python <<OEF
		import json
		result = []
		list_of_fls = ['${sep="','" out_files}']
		for f in list_of_fls:
			with open(f, "rb") as infile:
				result.append(json.load(infile))
		with open(sub(prefix, "_out.json", ""), "w") as outfile:
			json.dump(result, outfile, indent=4)
		OEF
	>>>

	runtime {
		memory: "1 GiB"
		cpu: 1
	}

	output{
		File out_json_file = sub(prefix, "_antisense_out.json", "")
	}
}

task dockcollect_output{
	Array[File] out_files
	String prefix
	String DOCKER

	command <<<
		python <<OEF
		import json
		out_file = "${prefix}" + "_sense_out.json"
		result = []
		list_of_fls = ['${sep="','" out_files}']
		for f in list_of_fls:
			with open(f, "rb") as infile:
				result.append(json.load(infile))
		with open(out_file, "w") as outfile:
			json.dump(result, outfile, indent=4)
		OEF
	>>>

	runtime {
		docker: DOCKER
	}

	output{
		File out_json_file = prefix + "_sense_out.json"
	}
}

task dockcollect_output2{
        Array[File] out_files
        String prefix
        String DOCKER

        command <<<
                python <<OEF
                import json
                out_file = "${prefix}" + "_antisense_out.json"
                result = []
                list_of_fls = ['${sep="','" out_files}']
                for f in list_of_fls:
                        with open(f, "rb") as infile:
                                result.append(json.load(infile))
                with open(out_file, "w") as outfile:
                        json.dump(result, outfile, indent=4)
                OEF
        >>>

        runtime {
                docker: DOCKER
        }

        output{
                File out_json_file2 = prefix + "_antisense_out.json"
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

task stage {
   String container
   String proj
   String prefix=sub(proj, ":", "_")
   String target="${prefix}.fastq.gz"
   String input_file

   command{
       set -e
       if [ $( echo ${input_file}|egrep -c "https*:") -gt 0 ] ; then
           wget ${input_file} -O ${target}
       else
           cp ${input_file} ${target}
       fi
       date --iso-8601=seconds > start.txt
   }

   output{
      File read = "${target}"
      String start = read_string("start.txt")
      String pref = "${prefix}"
   }
   runtime {
     memory: "1 GiB"
     cpu:  2
     maxRetries: 1
     docker: container
   }
}

task split_interleaved_fastq{
    File reads
    String container
    String? memory = "4G"
    String output1 = "input.left.fastq.gz"
    String output2 = "input.right.fastq.gz"

    runtime {
        docker: container
        mem: "4 GiB"
        cpu:  1
    }
    command {
         reformat.sh -Xmx${default="10G" memory} in=${reads} out1=${output1} out2=${output2}
    }

    output {
            Array[File] outFastq = [output1, output2]
    }
}



task finish_metat {
   String container
   String start
   String activity_id
   String resource
   String url_base
   String git_url
   File hisat2_bam
   File out_json
   File out_json2
   File annotation_proteins_faa
   File annotation_structural_gff
   File annotation_functional_gff
   File annotation_ko_tsv
   File annotation_ec_tsv
   File annotation_cog_gff
   File annotation_pfam_gff
   File annotation_tigrfam_gff
   File annotation_smart_gff
   File annotation_supfam_gff
   File annotation_cath_funfam_gff
   File annotation_ko_ec_gff
   String outdir
   String qadir="${outdir}/qa/"
   String assemdir="${outdir}/assembly/"
   String annodir="${outdir}/annotation/"
   String mapback="${outdir}/mapback/"
   String out_jsons="${outdir}/metat_output/"


   command{
	   set -e
	   mkdir -p ${annodir}
	   end=`date --iso-8601=seconds`
		nmdc gff2json ${annotation_functional_gff} -of features.json -oa annotations.json -ai ${activity_id}
       	cp ${annotation_proteins_faa} ${annotation_structural_gff} ${annotation_functional_gff} \
          ${annotation_ko_tsv} ${annotation_ec_tsv} ${annotation_cog_gff} ${annotation_pfam_gff} ${annotation_tigrfam_gff} \
          ${annotation_smart_gff} ${annotation_supfam_gff} ${annotation_cath_funfam_gff} ${annotation_ko_ec_gff} \
          ${annodir}/
		cp features.json annotations.json ${annodir}/
		mkdir -p ${mapback}
		cp ${hisat2_bam} ${mapback}/
		mkdir -p ${out_jsons}
		cp ${out_json} ${out_json2} ${out_jsons}/
   }

   runtime {
     memory: "10 GiB"
     cpu:  4
     maxRetries: 1
     docker: container
   }
}
