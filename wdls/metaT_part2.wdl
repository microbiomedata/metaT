import "feature_counts.wdl" as fc
import "build_hisat2.wdl" as bh
import "map_hisat2.wdl" as mh
import "calc_scores.wdl" as cs
import "to_json.wdl" as tj
import "misc_tasks.wdl" as mt
import "metat_assembly.wdl" as ma
import "run_stringtie.wdl" as rs

workflow metat_omics {
	File metat_contig_fn
	Array[File] non_ribo_reads
	File ann_gff_fn
	Int no_of_cpus
	String? name_of_proj = "metaT"
	String? docker = "microbiomedata/meta_t:latest"
		File edgeR="scripts/edgeR.R"
		File py_pack_path = "pyp_metat"
	String? outdir

	call bh.dock_BuildHisat2{
		input:no_of_cpu = no_of_cpus,
		assem_contig_fna = metat_contig_fn,
		DOCKER = docker
	}

	call mh.hisat2_mapping{
		input:rna_clean_reads = non_ribo_reads,
		no_of_cpus = no_of_cpus,
		hisat2_ref_dbs = dock_BuildHisat2.hs,
		hisat_db_name = dock_BuildHisat2.db,
		DOCKER = docker
	}


	call mt.dockclean_gff{
		input:gff_file_path = ann_gff_fn,
		DOCKER = docker
	}

	call mt.dockextract_feats{
		input:gff_file_path = dockclean_gff.cln_gff_fl,
		DOCKER = docker
	}

	call mt.dockcreate_gffdb{
		input:gff_file_path = dockclean_gff.cln_gff_fl,
		DOCKER = docker
	}

	scatter (feat in dockextract_feats.feats_in_gff) {
		call fc.dock_featurecount{
		input: no_of_cpu = no_of_cpus,
		project_name = name_of_proj,
		gff_file_path = dockclean_gff.cln_gff_fl,
		bam_file_path = hisat2_mapping.map_bam,
		name_of_feat = feat,
		DOCKER = docker
		}

		call cs.dockcal_scores{
		input: project_name = name_of_proj,
		name_of_feat = feat,
		fc_file = dock_featurecount.ct_tbl,
                edgeR = edgeR,
		DOCKER = docker
		}

	call tj.dock_convtojson{
		input:gff_file_path = dockclean_gff.cln_gff_fl,
		fasta_file_name = metat_contig_fn,
		rd_count_fn = dock_featurecount.ct_tbl,
		pkm_sc_fn = dockcal_scores.sc_tbl,
		name_of_feat = feat,
		gff_db_fn = dockcreate_gffdb.gff_db_fn,
                py_pack_path = py_pack_path,
		DOCKER = docker
		}
	}

	call mt.dockcollect_output{
		input: out_files = dock_convtojson.out_json_file,
		DOCKER = docker
	}

	call mt.make_part2_output{
		input: json_file = dockcollect_output.out_json_file,
		outdir = outdir
	}

    output {
        File json_out = make_part2_output.json_out
    }

	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
		version: "0.0.3"
	}
}

