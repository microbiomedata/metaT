import "misc_tasks.wdl" as mt
import "rqcfilter.wdl" as rqc
import "additional_qc.wdl" as aq
import "metat_assembly.wdl" as ma
import "build_hisat2.wdl" as bh
import "map_hisat2.wdl" as mh
import "annotation_full.wdl" as awf
import "feature_counts.wdl" as fc
import "calc_scores.wdl" as cs
import "to_json.wdl" as tj

workflow nmdc_metat {
    String  metat_container = "microbiomedata/meta_t:latest"
    String  proj
    String git_url
    String activity_id
    String url_base
    String resource
    File    input_file
    String  outdir
    String  rqc_database
    String  annot_database
    File edgeR="scripts/edgeR.R"
    File py_pack_path = "pyp_metat"

    call mt.stage as stage {
    input: input_file=input_file,
           proj=proj
    }
    
    call rqc.jgi_rqcfilter as qc {
    input: input_files=[stage.read],
           outdir="${outdir}/qa/",
           threads=32,
           memory="64G",
           database=rqc_database
    }

    call ma.megahit_assembly as asm {
    input: rqc_clean_reads = qc.filtered,
           assem_out_fdr = "${outdir}/assembly/",
           assem_out_prefix = sub(proj, ":", "_"),
           no_of_cpus = 32,
           DOCKER = metat_container
  }

    call bh.dock_BuildHisat2 as bhd{
        input:no_of_cpu = 32,
        assem_contig_fna = asm.assem_fna_file
    }
    call mt.split_interleaved_fastq as sif {
    input:
      reads=qc.filtered[0],
      container="microbiomedata/bbtools:38.90"
    }

    call mh.hisat2_mapping as h2m{
        input:rna_clean_reads = sif.outFastq,
        no_of_cpus = 32,
        hisat2_ref_dbs = bhd.hs,
        hisat_db_name = bhd.db,
    }
  call awf.annotation as iap {
    input: imgap_project_id=stage.pref,
           imgap_input_fasta=asm.assem_fna_file,
           database_location=annot_database
    }
	
    call mt.dockclean_gff as dcg{
		input:gff_file_path = iap.functional_gff,
		DOCKER = metat_container

	}

	call mt.dockextract_feats as ef {
		input:gff_file_path = dcg.cln_gff_fl,
		DOCKER = metat_container
	}

	call mt.dockcreate_gffdb{
		input:gff_file_path = dcg.cln_gff_fl,
		DOCKER = metat_container
	}
    
    scatter (feat in ef.feats_in_gff) {
		call fc.dock_featurecount{
		input: no_of_cpu = 32,
		project_name = sub(proj, ":", "_"),
		gff_file_path = dcg.cln_gff_fl,
		bam_file_path = h2m.map_bam,
		name_of_feat = feat,
		DOCKER = metat_container
		}
		call cs.dockcal_scores{
		input: project_name = sub(proj, ":", "_"),
		name_of_feat = feat,
		fc_file = dock_featurecount.ct_tbl,
                edgeR = edgeR,
		DOCKER = metat_container
		}
        call tj.dock_convtojson as tdc{
		input:gff_file_path = dcg.cln_gff_fl,
		fasta_file_name = asm.assem_fna_file,
		rd_count_fn = dock_featurecount.ct_tbl,
		pkm_sc_fn = dockcal_scores.sc_tbl,
		name_of_feat = feat,
		gff_db_fn = dockcreate_gffdb.gff_db_fn,
                py_pack_path = py_pack_path,
		DOCKER = metat_container
		}
	}

    call mt.dockcollect_output as mdo {
		input: out_files = tdc.out_json_file,
        prefix=sub(proj, ":", "_"),
		DOCKER = metat_container
	}

    call mt.finish_metat as mfm {
    input: container="scanon/nmdc-meta:v0.0.1",
           start=stage.start,
           resource=resource,
           url_base=url_base,
           git_url=git_url,
           activity_id="test",
        #    read = stage.read,
        #    filtered = qc.filtered[0],
        #    filtered_stats = qc.stats[0],
        #    fasta=asm.assem_fna_file,
           hisat2_bam=h2m.map_bam,
           out_json=mdo.out_json_file,
           annotation_proteins_faa=iap.proteins_faa,
           annotation_functional_gff=iap.functional_gff,
           annotation_structural_gff=iap.structural_gff,
           annotation_ko_tsv=iap.ko_tsv,
           annotation_ec_tsv=iap.ec_tsv,
           annotation_cog_gff=iap.cog_gff,
           annotation_pfam_gff=iap.pfam_gff,
           annotation_tigrfam_gff=iap.tigrfam_gff,
           annotation_smart_gff=iap.smart_gff,
           annotation_supfam_gff=iap.supfam_gff,
           annotation_cath_funfam_gff=iap.cath_funfam_gff,
           annotation_ko_ec_gff=iap.ko_ec_gff,
           outdir=outdir
  }


    meta {
        author: "Migun Shakya, B10, LANL"
        email: "migun@lanl.gov"
        version: "0.0.2"
    }
}

