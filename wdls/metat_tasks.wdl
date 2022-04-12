task clean_gff{
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

task collect_output2{
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
   File read
   File filtered 
   File filtered_stats
   File fasta
   String resource
   String url_base
   String git_url
   File bbm_bam
   File out_json
   File out_json2
   String outdir
   String qadir="${outdir}/qa/"
   String assemdir="${outdir}/assembly/"
   String annodir="${outdir}/annotation/"
   String mapback="${outdir}/mapback/"
   String metat_out="${outdir}/metat_output/"
   File structural_gff
   File functional_gff
   File ko_tsv
   File ec_tsv
   File phylo_tsv
   File proteins_faa
   File ko_ec_gff
   File cog_gff
   File pfam_gff
   File tigrfam_gff
   File smart_gff
   File supfam_gff
   File cath_funfam_gff
   File cog_domtblout
   File pfam_domtblout
   File tigrfam_domtblout
   File smart_domtblout
   File supfam_domtblout
   File cath_funfam_domtblout
   File product_name_tsv
   File gene_phylogeny_tsv
   File crt_crisprs
   File crt_gff
   File genemark_gff
   File prodigal_gff
   File trna_gff
   File misc_bind_misc_feature_regulatory_gff
   File rrna_gff
   File ncrna_tmrna_gff
   File sorted_features
  
   command{
      set -e
      mkdir -p ${qadir}
      mkdir -p ${assemdir}
      mkdir -p ${mapback}
      mkdir -p ${annodir}
      mkdir -p ${metat_out}
      end=`date --iso-8601=seconds`
	
      
       # Generate QA objects
       /scripts/rqcstats.py ${filtered_stats} > stats.json
       /scripts/generate_objects.py --type "qa" --id ${activity_id} \
             --start ${start} --end $end \
             --resource '${resource}' --url ${url_base} --giturl ${git_url} \
             --extra stats.json \
             --inputs ${read} \
             --outputs \
             ${filtered} 'Filtered Reads' \
             ${filtered_stats} 'Filtered Stats'
       cp activity.json data_objects.json ${qadir}/

       # Generate assembly objects
       /scripts/generate_objects.py --type "assembly" --id ${activity_id} \
             --start ${start} --end $end \
             --resource '${resource}' --url ${url_base} --giturl ${git_url} \
             --inputs ${filtered} \
             --outputs \
             ${fasta} 'Assembled contigs fasta'
       cp activity.json data_objects.json ${assemdir}/

       # Generate mapping objects
       /scripts/generate_objects.py --type "mapping" --id ${activity_id} \
             --start ${start} --end $end \
             --resource '${resource}' --url ${url_base} --giturl ${git_url} \
             --inputs ${fasta} \
             --outputs \
             ${bbm_bam} 'Mapping file'
       cp ${bbm_bam} activity.json data_objects.json ${mapback}/

       # Generate annotation objects
       nmdc gff2json ${functional_gff} -of features.json -oa annotations.json -ai ${activity_id}

       /scripts/generate_objects.py --type "annotation" --id ${activity_id} \
             --start ${start} --end $end \
             --resource '${resource}' --url ${url_base} --giturl ${git_url} \
             --inputs ${fasta} \
             --outputs \
             ${proteins_faa} 'Protein FAA' \
             ${structural_gff} 'Structural annotation GFF file' \
             ${functional_gff} 'Functional annotation GFF file' \
             ${ko_tsv} 'KO TSV file' \
             ${ec_tsv} 'EC TSV file' \
             ${cog_gff} 'COG GFF file' \
             ${pfam_gff} 'PFAM GFF file' \
             ${tigrfam_gff} 'TigrFam GFF file' \
             ${smart_gff} 'SMART GFF file' \
             ${supfam_gff} 'SuperFam GFF file' \
             ${cath_funfam_gff} 'Cath FunFam GFF file' \
             ${ko_ec_gff} 'KO_EC GFF file' \
	     ${crt_crisprs} 'CRISPRS file' \
	     ${product_names_tsv} 'Product Names tsv' \
             ${gene_phylogeny_tsv} 'Gene Phylogeny tsv' \

       cp ${proteins_faa} ${structural_gff} ${functional_gff} \
          ${ko_tsv} ${ec_tsv} ${cog_gff} ${pfam_gff} ${tigrfam_gff} \
          ${smart_gff} ${supfam_gff} ${cath_funfam_gff} ${ko_ec_gff} \
	  ${crt_crisprs} ${product_names_tsv} ${gene_phylogeny_tsv} \
          ${annodir}/
       cp features.json annotations.json activity.json data_objects.json ${annodir}/

       # Generate metat objects - this is wrong for now, in development
       /scripts/generate_objects.py --type "metat" --id ${activity_id} \
             --start ${start} --end $end \
             --resource '${resource}' --url ${url_base} --giturl ${git_url} \
             --inputs ${functional_gff} ${bbm_bam}  \
             --outputs \
              ${out_json} 'Sense RPKM' \
              ${out_json2} 'Anstisense RPKM' \
	      ${sorted_features} 'Sorted Features tsv'
  
      cp ${out_json} ${out_json2} ${sorted_features} activity.json data_objects.json ${metat_out}/

   }

   runtime {
     memory: "10 GiB"
     cpu:  4
     maxRetries: 1
     docker: container
   }
}
