version 1.0

task clean_gff{
   input{
      File gff_file_path
      String DOCKER
   }
   command <<<
      set -eou pipefail
    # removing special characters that featurecount didnt like when parsing gff
      sed "s/\'//g" ~{gff_file_path} | sed "s/-/_/g"  > clean.gff

   >>>

   output{
      File cln_gff_fl = "clean.gff"
   }

   runtime {
      docker: DOCKER
   }
}

task extract_feats{
   input{
      File gff_file_path
      String DOCKER
   }
   command <<<
      set -eou pipefail
      awk -F'\t' '{print $3}' ~{gff_file_path} | sort | uniq
   >>>

   output{
      Array[String] feats_in_gff = read_lines(stdout())
   }

   runtime {
      docker: DOCKER
   }
}

task create_gffdb{
   input {
      File gff_file_path
      String DOCKER
   }
   command <<<
      set -eou pipefail
      python <<CODE
      import gffutils
      gffutils.create_db("~{gff_file_path}", dbfn="gff.db", force=True, keep_order=True, merge_strategy="create_unique")
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
   input {
      Array[File] out_files
      String prefix
      String DOCKER
   }
   command <<<
      set -eou pipefail
      python <<OEF
      import json
      out_file = "~{prefix}" + "_sense_out.json"
      result = []
      list_of_fls = ['~{sep="','" out_files}']
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
   input{
        Array[File] out_files
        String prefix
        String DOCKER
   }
      command <<<

         set -eou pipefail
         python <<CODE
         import json
         out_file = "~{prefix}" + "_antisense_out.json"
         result = []
         list_of_fls = ['~{sep="','" out_files}']
         for f in list_of_fls:
               with open(f, "rb") as infile:
                        result.append(json.load(infile))
         with open(out_file, "w") as outfile:
               json.dump(result, outfile, indent=4)
         CODE
        >>>

        runtime {
                docker: DOCKER
        }

        output{
                File out_json_file2 = prefix + "_antisense_out.json"
        }
}


task split_fastq{
   input{
      File intleave_fq_fl
   }

   command <<<
      set -eou pipefail
      cat ~{intleave_fq_fl} | paste - - - - - - - - | tee | cut -f 1-4 | tr "\t" "\n" | egrep -v '^$' > R1.fastq
      cat ~{intleave_fq_fl} | paste - - - - - - - - | tee | cut -f 5-8 | tr "\t" "\n" | egrep -v '^$' > R2.fastq

   >>>

   output{
      File out_r1_file = "R1.fastq"
      File out_r2_file = "R2.fastq"
   }
}

task stage {
   input{
      String container
      String proj
      String prefix=sub(proj, ":", "_")
      String target="~{prefix}.fastq.gz"
      String input_file
   }
   command <<<
       set -eou pipefail
       if [ $( echo ~{input_file}|egrep -c "https*:") -gt 0 ] ; then
           wget ~{input_file} -O ~{target}
       else
           cp ~{input_file} ~{target}
       fi
       date --iso-8601=seconds > start.txt
   >>>

   output{
      File read = "~{target}"
      String start = read_string("start.txt")
      String pref = "~{prefix}"
   }
   runtime {
     memory: "1 GiB"
     cpu:  2
     maxRetries: 1
     docker: container
   }
}

task split_interleaved_fastq{
    input{
      File reads
      String container
      String? memory = "4G"
      String output1 = "input.left.fastq.gz"
      String output2 = "input.right.fastq.gz"
   }
    runtime {
        docker: container
        mem: "4 GiB"
        cpu:  1
    }
    command <<<
         set -eou pipefail
         reformat.sh -Xmx~{default="10G" memory} in=~{reads} out1=~{output1} out2=~{output2}
    >>>

    output {
            Array[File] outFastq = [output1, output2]
    }
}


task make_interleaved {
   input{
      File input1
      File input2
      String pref
      String container
   }
   command <<<
      set -eou pipefail
      reformat.sh in1=~{input1} in2=~{input2} out="~{pref}.fastq.gz"
   >>>

   output{
      File out_fastq = "~{pref}.fastq.gz"
   }
   runtime {
     memory: "1 GiB"
     cpu:  2
     maxRetries: 1
     docker: container
   }
}

task rctojson{
	input {
		File gff
		File readcount
		String prefix
		String container = "microbiomedata/meta_t@sha256:ffeedfb622d1c49ad8a1f13d7608b65d9b88b1d27237328258093d8eccd3a6fc"
	}
	command <<<
		python <<CODE
		# Imports #######################################################################################################################################
		import os
		import json
		import pandas as pd
		import gffutils
		# Definitions #####################################################################################################################################
		# Functions #######################################################################################################################################
		def final_jsons(gff_in = "test_data/paired.gff", rc_in = "test_data/paired.rc", 
						gff_json = "paired.gff.json", 
						rc_json = "paired.rc.json",
						gff_rc_json = "gff_rc.json",
						cds_json = "cds_counts.json",
						sense_json = "sense_counts.json",
						anti_json = "antisense_counts.json",
						sorted_json = "sorted_features.json",
						sorted_tsv = "sorted_features.tsv",
						top100_json = "top100_features.json",
						prefix = ""
						):
			"""
			Generate JSON files for NMDC EDGE MetaT output tables. 
			Combine JSON files from GFF and read count TSV using pandas
			"""
			if (prefix != ""):
				gff_json = prefix + "_paired.gff.json"
				rc_json = prefix + "_paired.rc.json"
				gff_rc_json = prefix + "_gff_rc.json"
				cds_json = prefix + "_cds_counts.json"
				sense_json = prefix + "_sense_counts.json"
				anti_json = prefix + "_antisense_counts.json"
				sorted_json = prefix + "_sorted_features.json"
				sorted_tsv = prefix + "_sorted_features.tsv"
				top100_json = prefix + "_top100_features.json"
			
			gff_obj = GTFtoJSON(gff_in, gff_json).gtf_json()
			
			rc_obj = TSVtoJSON(rc_in, rc_json).tsv_json()

			gff_pd = pd.read_json(gff_json)
			rc_pd = pd.read_json(rc_json)

         gff_pd = gff_pd.fillna("None")
         rc_pd = rc_pd.fillna("None")

			gff_rc_pd = pd.merge(gff_pd, rc_pd, on = ["id", "seqid", "featuretype", "strand", "length"])

			cds_only = gff_rc_pd[gff_rc_pd['featuretype'] == "CDS"]

			sense_reads = cds_only[cds_only['strand'] == "+"].drop(columns = ["antisense_read_count", 
												"meanA",
												"medianA",
												"stdevA"])
			antisense_reads = cds_only[cds_only['strand'] == "-"].drop(columns = ["sense_read_count", 
												"mean",
												"median",
												"stdev"])

			sorted_features = gff_rc_pd.sort_values(by='sense_read_count', ascending=False)
			top100 = sorted_features[:100]
			
			write_json(gff_rc_pd.to_dict(orient="records"), gff_rc_json)
			write_json(cds_only.to_dict(orient="records"), cds_json)
			write_json(sense_reads.to_dict(orient="records"), sense_json)
			write_json(antisense_reads.to_dict(orient="records"), anti_json)
			write_json(sorted_features.to_dict(orient="records"), sorted_json)
			write_json(top100.to_dict(orient="records"), top100_json)
			
			sorted_features.to_csv(sorted_tsv, sep="\t") 
			
			print("Additional JSON files and tables printed.")

			
		def write_json(js_data, file_out: str):
			with open(file_out, 'w') as json_file:
				json.dump(js_data, json_file, indent=4)

		# Classes #######################################################################################################################################
		class GTFtoJSON():
			"""
			Converts GTF files to JSON records.

			Utilizes package gffutils to create database from gff / gtf files in gtf_json()
			Extracts desired attributes and features to json using collect_features().
			Utilizes package json to write json out and package os to check for db existence. 
			"""

			def __init__(self, gtf_file_name: str, out_json_file: str):
				"""
				gtf_file_name: string of gtf or gff file, relative or absolute path both work
				out_json_file: name of desired json output file, relative or absolute
				"""
				self.gtf_file_name = gtf_file_name
				self.out_json_file = out_json_file

			def gtf_json(self):
				"""
				A function that converts a gff file to JSON file.
				Reads gff in and exports to db (SQL) type file.
				Uses db type format to channel to collect_features and extract attributes to dictionary before writing to json.
				"""
				# read in the gff file to a database
				if os.path.exists("metat_db.db") is False:
					gtf_as_db = gffutils.create_db(self.gtf_file_name, dbfn="metat_db.db", force=True,
												keep_order=True,
												merge_strategy="create_unique")
					print("New gffutils db created")
				else:
					gtf_as_db = gffutils.FeatureDB("metat_db.db", keep_order=True)
					print("Cached gffutils db loaded")
				json_list = []
				for feat_obj in gtf_as_db.all_features():
					feat_dic = {}  # an empty dictionary to append features
					feat_dic_str = self.collect_features(feat_obj=feat_obj, feat_dic=feat_dic)
					if bool(feat_dic_str):  # only append if dic is not empty
						json_list.append(feat_dic_str)

				write_json(json_list, self.out_json_file)
				print("GTF to JSON completed")
				return json_list
				

			def collect_features(self, feat_obj, feat_dic: dict):
				"""
				A function that collect features. Usually called via gtf_json()
				feat_obj is each object give through loop of db from gffutils
				"""
				feat_dic['featuretype'] = feat_obj.featuretype
				feat_dic['seqid'] = feat_obj.seqid
				feat_dic['id'] = feat_obj.id
				feat_dic['source'] = feat_obj.source
				feat_dic['start'] = feat_obj.start
				feat_dic['end'] = feat_obj.end
				feat_dic['length'] = abs(feat_obj.end - feat_obj.start) + 1
				feat_dic['strand'] = feat_obj.strand
				feat_dic['frame'] = feat_obj.frame
				try:
					feat_dic['product'] = feat_obj.attributes['product'][0]
					feat_dic['product_source'] = feat_obj.attributes['product_source'][0]
				except KeyError:
					pass
				try:
					feat_dic['cov'] = feat_obj.attributes['cov'][0]
				except KeyError:
					pass
				try:
					feat_dic['FPKM'] = feat_obj.attributes['FPKM'][0]
				except KeyError:
					pass
				try:
					feat_dic['TPM'] = feat_obj.attributes['TPM'][0]
				except KeyError:
					pass
				# just to make sure that keys are strings, else json dump fails
				feat_dic_str = {}
				for key, value in feat_dic.items():
					feat_dic_str[str(key)] = value
				return feat_dic_str

		########################################################################################################################################

		class TSVtoJSON():
			""" 
			Convert TSV output from JGI ReadCounts script to JSON format 
			to combine with functional annotation gff file
			feat_dic['sense_read_count'] = DY's reads_cnt
			feat_dic['antisense_read_count'] = DY's reads_cntA instead of feat_dic['FPKM'] = feat_obj.attributes['FPKM']
			you will have to make it read the DY's output, ingest to a dic, read the functional annotation gff file using gffutils packages, and then add selected variables to the same dic and convert it to json and csv
				
			"""
			def __init__(self, tsv_file_name: str, out_json_file: str):
				self.tsv_file_name = tsv_file_name
				self.out_json_file = out_json_file
			
			def tsv_json(self):
				"""
				Convert TSV to dictionaries for writing out to json
				Uses pandas to read in CSV, rename columns, drop empty column, and create dictionary for json dumping. 
				"""
				tsv_obj = pd.read_csv(
					self.tsv_file_name, sep="\t"
					).drop(columns = ["locus_tag", "scaffold_accession"]
					).rename(columns = {"img_gene_oid": "id", 
										"img_scaffold_oid": "seqid",
										"reads_cnt": "sense_read_count",
										"reads_cntA": "antisense_read_count",
										"locus_type": "featuretype"})
				# tsv_dic = tsv_obj.to_dict(orient="records")
				print("TSV to JSON completed")

				write_json(tsv_obj.to_dict(orient="records"), self.out_json_file)
	
		# Function call #######################################################################################################################################
		final_jsons(gff_in = "~{gff}", rc_in = "~{readcount}", prefix = "~{prefix}")
		########################################################################################################################################
		CODE
	>>>

	output{
		File gff_json = "~{prefix}_paired.gff.json"
        File rc_json = "~{prefix}_paired.rc.json"
        File gff_rc_json = "~{prefix}_gff_rc.json"
		File cds_json = "~{prefix}_cds_counts.json"
		File sense_json = "~{prefix}_sense_counts.json"
		File anti_json = "~{prefix}_antisense_counts.json"
        File top100_json = "~{prefix}_top100_features.json"
		File sorted_json = "~{prefix}_sorted_features.json"
        File sorted_tsv = "~{prefix}_sorted_features.tsv"
	}

	runtime {
     memory: "8 GiB"
     cpu:  2
     maxRetries: 1
     docker: container
   }

}


task finish_metat {
   input{
      String container
      String start
      String informed_by
      File read
      File filtered
      File filtered_stats
      File filtered_stats2
      File fasta
      String resource
      String url_root
      String git_url
      String proj
      String prefix=sub(proj, ":", "_")
      File bbm_bam
      File covstats
      File out_json
      File top100
      File out_json2
      File stats_json
      File stats_tsv
      String outdir
      String qadir="~{outdir}/qa/"
      String assemdir="~{outdir}/assembly/"
      String annodir="~{outdir}/annotation/"
      String mapback="~{outdir}/mapback/"
      String metat_out="~{outdir}/metat_output/"
      File structural_gff
      File functional_gff
      File ko_tsv
      File ec_tsv
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
      File product_names_tsv
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
      String orig_prefix="scaffold"
      String sed="s/~{orig_prefix}_/~{proj}_/g"
   }

   command <<<
      set -eou pipefail
      mkdir -p ~{qadir}
      mkdir -p ~{assemdir}
      mkdir -p ~{mapback}
      mkdir -p ~{annodir}
      mkdir -p ~{metat_out}
      end=`date --iso-8601=seconds`


       #copy and re-ed qa objects
       cp ~{filtered} ~{qadir}/~{prefix}_filtered.fastq.gz
       cp ~{filtered_stats} ~{qadir}/~{prefix}_filterStats.txt
       cp ~{filtered_stats2} ~{qadir}/~{prefix}_filterStats2.txt

       # Generate QA objects
       /scripts/rqcstats.py ~{filtered_stats} > stats.json
       cp stats.json ~{qadir}/~{prefix}_qa_stats.json


       #rename fasta
       cat ~{fasta} | sed ~{sed} > ~{assemdir}/~{prefix}_contigs.fna
       # Generate assembly objects

       #rename mapping objects
       cat ~{covstats} | sed ~{sed} > ~{mapback}/~{prefix}_covstats.txt
       ## Bam file
       samtools view -h ~{bbm_bam} | sed ~{sed} | \
          samtools view -hb -o ~{mapback}/~{prefix}_pairedMapped_sorted.bam

       cat ~{proteins_faa} | sed ~{sed} > ~{annodir}/~{prefix}_proteins.faa
       cat ~{structural_gff} | sed ~{sed} > ~{annodir}/~{prefix}_structural_annotation.gff
       cat ~{functional_gff} | sed ~{sed} > ~{annodir}/~{prefix}_functional_annotation.gff
       cat ~{ko_tsv} | sed ~{sed} > ~{annodir}/~{prefix}_ko.tsv
       cat ~{ec_tsv} | sed ~{sed} > ~{annodir}/~{prefix}_ec.tsv
       cat ~{cog_gff} | sed ~{sed} > ~{annodir}/~{prefix}_cog.gff
       cat ~{pfam_gff} | sed ~{sed} > ~{annodir}/~{prefix}_pfam.gff
       cat ~{tigrfam_gff} | sed ~{sed} > ~{annodir}/~{prefix}_tigrfam.gff
       cat ~{smart_gff} | sed ~{sed} > ~{annodir}/~{prefix}_smart.gff
       cat ~{supfam_gff} | sed ~{sed} > ~{annodir}/~{prefix}_supfam.gff
       cat ~{cath_funfam_gff} | sed ~{sed} > ~{annodir}/~{prefix}_cath_funfam.gff
       cat ~{crt_gff} | sed ~{sed} > ~{annodir}/~{prefix}_crt.gff
       cat ~{genemark_gff} | sed ~{sed} > ~{annodir}/~{prefix}_genemark.gff
       cat ~{prodigal_gff} | sed ~{sed} > ~{annodir}/~{prefix}_prodigal.gff
       cat ~{trna_gff} | sed ~{sed} > ~{annodir}/~{prefix}_trna.gff
       cat ~{misc_bind_misc_feature_regulatory_gff} | sed ~{sed} > ~{annodir}/~{prefix}_rfam_misc_bind_misc_feature_regulatory.gff
       cat ~{rrna_gff} | sed ~{sed} > ~{annodir}/~{prefix}_rfam_rrna.gff
       cat ~{ncrna_tmrna_gff} | sed ~{sed} > ~{annodir}/~{prefix}_rfam_ncrna_tmrna.gff
       cat ~{crt_crisprs} | sed ~{sed} > ~{annodir}/~{prefix}_crt.crisprs
       cat ~{product_names_tsv} | sed ~{sed} > ~{annodir}/~{prefix}_product_names.tsv
       cat ~{gene_phylogeny_tsv} | sed ~{sed} > ~{annodir}/~{prefix}_gene_phylogeny.tsv

       cat ~{ko_ec_gff} | sed ~{sed} > ~{annodir}/~{prefix}_ko_ec.gff
       cat ~{stats_tsv} | sed ~{sed} > ~{annodir}/~{prefix}_stats.tsv
       cat ~{stats_json} | sed ~{sed} > ~{annodir}/~{prefix}_stats.json



       #re-id metat objects
       cat ~{out_json} | sed ~{sed} > ~{metat_out}/~{prefix}_sense_counts.json
       cat ~{out_json2} | sed ~{sed} > ~{metat_out}/~{prefix}_antisense_counts.json
       cat ~{sorted_features} | sed ~{sed} > ~{metat_out}/~{prefix}_sorted_features.tsv
       cat ~{top100} | sed ~{sed} > ~{metat_out}/top100_features.json


   >>>

   runtime {
     memory: "10 GiB"
     cpu:  4
     maxRetries: 1
     docker: container
   }
}
