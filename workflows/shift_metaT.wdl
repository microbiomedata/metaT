import "../tasks/map_hisat2.wdl" as mh
import "../tasks/build_hisat2.wdl" as bh2
import "../tasks/qc.wdl" as qc
import "../tasks/feature_counts.wdl" as fc
import "../tasks/calc_scores.wdl" as cs

workflow metaT {
   Boolean DoQC
   Int cpu
   String outdir
   Array[File] PairedReads=[]
   File ref_genome
   File ref_gff
   File? SingleRead
   String? QCopts=""
   String? project_name = "metatranscriptomics"
   String container = "docker:microbiomedata/meta_t:latest"

	if (DoQC){
		call qc.shift_qc{
			input: opts = QCopts,
			cpu = cpu,
			project_name = project_name,
			outdir = outdir,
			PairedReads = PairedReads,
			QCSingleRead = SingleRead,
			container = container
		}
	}

	call bh2.shift_BuildHisat2{
		input: cpu = cpu,
		ref_genome = ref_genome,
		container = container
	}

	call mh.shift_mapping{
		input: cpu = cpu,
		PairedReads = if DoQC then shift_qc.QCedPaired else PairedReads,
		hisat2_ref = shift_BuildHisat2.hs,
		db = shift_BuildHisat2.db,
		project_name = project_name,
		container = container
	}

	call fc.shift_featurecount{
		input: cpu = cpu,
		project_name = project_name,
		ref_gff = ref_gff,
		bam_file = shift_mapping.map_bam,
		container = container
	}

	call cs.shift_cal_scores{
		input: cpu = cpu,
		project_name = project_name,
		fc_file = shift_featurecount.ct_tbl,
		container = container
	}
	
	meta {
		author: "Migun Shakya, B10, LANL"
		email: "migun@lanl.gov"
	}
}

