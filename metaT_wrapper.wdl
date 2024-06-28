# metaT workflow wrapper
version 1.0

# import "https://raw.githubusercontent.com/microbiomedata/metaT_readsqc/main/rqcfilter.wdl" as qc
# import "https://raw.githubusercontent.com/microbiomedata/metaT_Assembly/main/metaT_assembly.wdl" as asse
# import "https://raw.githubusercontent.com/microbiomedata/mg_annotation/master/annotation_full.wdl" as anno
# import "https://raw.githubusercontent.com/microbiomedata/metaT_read_counting/main/readcount.wdl" as rc

import "./git_submodules/readsqc/rqcfilter.wdl" as readsqc 
import "./git_submodules/assembly/metaT_assembly.wdl" as assembly 
import "./git_submodules/annotation/annotation_full.wdl" as annotation 
import "./git_submodules/readcount/readcount.wdl" as readcounts
# import "./git_submodules/ReadbasedAnalysis/ReadbasedAnalysis.wdl" as readanalysis 
# import ".git_submodules/virusPlasmids/viral-plasmid_wf.wdl" as genomad 
import "./wdls/to_json.wdl" as json



workflow metaT {

    input {
        String  project_id
        Array[String] input_files
        String strand_type
        String prefix = sub(project_id, ":", "_")
        String out_dir = "~{prefix}_metaT"
        String container = "bryce911/bbtools:38.86"
    }

    call readsqc.metaTReadsQC as qc {
        input:
        proj = project_id,
        input_files = input_files
    }

    call assembly.metatranscriptome_assy as asse{
        input:
        # single file to array of files
        input_files = [qc.filtered_final],
        proj_id = project_id
    }

    call annotation.annotation as anno{
        input:
        proj = project_id,
        input_file = asse.final_contigs,
        imgap_project_id = project_id
    }

    call readcounts.readcount as rc{
        input:
        bam = asse.final_bam,
        gff = anno.functional_gff,
        out = out_dir,
        rna_type = strand_type,
        proj_id = project_id
    }


    call json.rctojson as tj{
        input:
        readcount = rc.count_table,
        gff = anno.functional_gff,
        prefix = prefix
    }

    output{ # what outputs to give users
        # metaT_ReadsQC
        File filtered_final = qc.filtered_final
        File filtered_stats_final = qc.filtered_stats_final
        File filtered_stats2_final = qc.filtered_stats2_final
        File rqc_info = qc.rqc_info
        # metaT_Assembly
        File final_tar_bam = asse.final_tar_bam
        File final_contigs = asse.final_contigs
        File final_scaffolds = asse.final_scaffolds
        File final_log = asse.final_log
	    File final_readlen = asse.final_readlen
        File final_sam = asse.final_sam
        File final_bam = asse.final_bam
        File asse_info  = asse.info_file
        # mg_annotation
        File proteins_faa = anno.proteins_faa
        File structural_gff = anno.structural_gff
        File ko_ec_gff = anno.ko_ec_gff
        File gene_phylogeny_tsv = anno.gene_phylogeny_tsv
        File functional_gff = anno.functional_gff
        File ko_tsv = anno.ko_tsv
        File ec_tsv = anno.ec_tsv
        File lineage_tsv = anno.lineage_tsv
        File stats_tsv = anno.stats_tsv
        File cog_gff = anno.cog_gff
        File pfam_gff = anno.pfam_gff
        File tigrfam_gff = anno.tigrfam_gff
        File smart_gff = anno.smart_gff
        File supfam_gff = anno.supfam_gff
        File cath_funfam_gff = anno.cath_funfam_gff
        File crt_gff = anno.crt_gff
        File genemark_gff = anno.genemark_gff
        File prodigal_gff = anno.prodigal_gff
        File trna_gff = anno.trna_gff
        File final_rfam_gff = anno.final_rfam_gff
        File product_names_tsv = anno.product_names_tsv
        File crt_crisprs = anno.crt_crisprs
        File imgap_version = anno.imgap_version
        # metaT_ReadCounts
        File count_table = rc.count_table
        File? count_ig = rc.count_table
        File? count_log = rc.count_table
        File readcount_info = rc.info_file
        # output tables
        File gff_json = tj.gff_json
        File rc_json = tj.rc_json
        File gff_rc_json = tj.gff_rc_json
		File cds_json = tj.cds_json
		File sense_json = tj.sense_json
		File anti_json = tj.anti_json
        File top100_json = tj.top100_json
		File sorted_json = tj.sorted_json
        File sorted_tsv = tj.sorted_tsv
    }

    parameter_meta {
        project_id: "Project ID string.  This will be appended to the gene ids"
        input_files: "File path(s) to raw fastq, can be interleaved or not"
        out_dir: "Out directory"
        strand_type: "RNA strandedness, either 'aRNA' or 'non_stranded_RNA'"
    }
    
}