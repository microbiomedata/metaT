import "rqcfilter.wdl" as rqc
import "annotation_full.wdl" as awf
import "build_hisat2.wdl" as bh
import "map_hisat2.wdl" as mh
import "calc_scores.wdl" as cs
import "to_json.wdl" as tj
import "misc_tasks.wdl" as mt
import "additional_qc.wdl" as aq
import "metat_assembly.wdl" as ma
import "run_stringtie.wdl" as rs

workflow nmdc_metat {
  String  container="bfoster1/img-omics:0.1.7"
  String  metat_container = "microbiomedata/meta_t:latest"
  String  proj
  String  input_file
  String  outdir
  String  database="/refdata/img/"
  String  resource="NERSC - Cori"
  String  activity_id="${proj}"
  String  git_url="https://github.com/microbiomedata/mg_annotation/releases/tag/0.1"
  String  url_root="https://data.microbiomedata.org/data/"
  String  url_base="${url_root}${proj}/annotation/"

  call stage {
    input: container=container,
           input_file=input_file,
           proj=proj
  }
  call rqc.jgi_rqcfilter as qc {
    input: input_files=[stage.read],
           outdir="${outdir}/qa/",
           threads=16,
           memory="60G"
  }

  call aq.bbduk_rrna{
    input: rqc_clean_reads = qc.filtered[0],
           DOCKER = metat_container
  }

  call ma.megahit_assembly as asm {
    input: rrna_clean_reads = bbduk_rrna.non_rrna_reads,
           assem_out_fdr = "out_fdr",
           assem_out_prefix = "megahit_assem",
           no_of_cpus = 32,
           DOCKER = metat_container
  }

  call awf.annotation {
    input: imgap_project_id=stage.pref,
           imgap_input_fasta=asm.assem_fna_file,
           database_location=database
  }

  call finish {
    input: container="scanon/nmdc-meta:v0.0.1",
           start=stage.start,
           resource=resource,
           url_base=url_base,
           git_url=git_url,
           activity_id=activity_id,
           read = stage.read,
           filtered = qc.filtered[0],
           filtered_stats = qc.stats[0],
           fasta=asm.assem_fna_file,
           proteins_faa=annotation.proteins_faa,
           functional_gff=annotation.functional_gff,
           structural_gff=annotation.structural_gff,
           ko_tsv=annotation.ko_tsv,
           ec_tsv=annotation.ec_tsv,
           cog_gff=annotation.cog_gff,
           pfam_gff=annotation.pfam_gff,
           tigrfam_gff=annotation.tigrfam_gff,
           smart_gff=annotation.smart_gff,
           supfam_gff=annotation.supfam_gff,
           cath_funfam_gff=annotation.cath_funfam_gff,
           ko_ec_gff=annotation.ko_ec_gff,
           outdir=outdir
  }

  meta {
    author: "Shane Canon"
    email: "scanon@lbl.gov"
    version: "1.0.0"
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



task finish {
   String container
   String start
   String activity_id
   String resource
   String url_base
   String git_url
   File read
   File filtered
   File filtered_stats
   File fasta
   File proteins_faa
   File structural_gff
   File functional_gff
   File ko_tsv
   File ec_tsv
   File cog_gff
   File pfam_gff
   File tigrfam_gff
   File smart_gff
   File supfam_gff
   File cath_funfam_gff
   File ko_ec_gff
   String outdir
   String qadir="${outdir}/qa/"
   String assemdir="${outdir}/assembly/"
   String annodir="${outdir}/annotation/"
   String magsdir="${outdir}/MAGs/"
   String rbadir="${outdir}/ReadbasedAnalysis/"

   command{
       set -e
       mkdir -p ${annodir}
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
             ${fasta} 'Assembled contigs fasta' \
       cp activity.json data_objects.json ${assemdir}/

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
             ${ko_ec_gff} 'KO_EC GFF file'

       cp ${proteins_faa} ${structural_gff} ${functional_gff} \
          ${ko_tsv} ${ec_tsv} ${cog_gff} ${pfam_gff} ${tigrfam_gff} \
          ${smart_gff} ${supfam_gff} ${cath_funfam_gff} ${ko_ec_gff} \
          ${annodir}/
       cp features.json annotations.json activity.json data_objects.json ${annodir}/


   }

   runtime {
     memory: "10 GiB"
     cpu:  4
     maxRetries: 1
     docker: container
   }
}


