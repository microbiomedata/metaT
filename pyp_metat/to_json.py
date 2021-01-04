#! /usr/bin/env python

"""Check design."""
import os
import sys
import json
import gffutils
import pandas as pd
from Bio.Seq import Seq
# from Bio.Alphabet import generic_dna

class ConverToJson():
    """ Summarizes and converts all the results to one big JSON file."""
    def __init__(self, gff_file_name, rd_count_fn, name_of_feat, pkm_sc_fn, fasta_file_name, out_json_file):
        self.gff_file_name = gff_file_name
        self.fasta_file_name = fasta_file_name
        self.rd_count_fn = rd_count_fn
        self.pkm_sc_fn = pkm_sc_fn
        self.name_of_feat = name_of_feat
        self.out_json_file = out_json_file

    def get_pkms_summ(self):
        """Get PKM values."""
        # pm_file_name = self.name_of_proj + "_" + name_of_feat + "_sc.tsv"
        pm_dict_obj = pd.read_csv(self.pkm_sc_fn, sep=",", engine='python',
                              comment="#", index_col="Geneid").to_dict(orient="index")
        for feat, rpkm_dic in pm_dict_obj.items():
            feat_rpkm = {}
            for var, value in rpkm_dic.items():
                if var == "RPKM":
                    int_read = round(float(value), 3)
            feat_rpkm[feat] = int_read
            pm_dict_obj.update(feat_rpkm)# print(pm_dict_obj)
        return pm_dict_obj

    def gff2json(self):
        """A function that converts a gff file to JSON file."""
        db_out = "gff.db"
        # read in the gff file to a database
        gff_as_db = gffutils.create_db(self.gff_file_name, dbfn=db_out, force=True,
                                keep_order=True,
                                merge_strategy="create_unique")
        dic_of_pkms = {}
        dic_of_reads = {}
        with open(self.out_json_file, "w") as json_file:
            dic_of_pkms[self.name_of_feat] = self.get_pkms_summ()
            dic_of_reads[self.name_of_feat] = self.read_summary()
            json_list = []
            for feat_obj in gff_as_db.all_features():
                feat_dic = {}  # an empty dictionary to append features
                feat_type = feat_obj.featuretype
                feat_dic['featuretype'] = feat_type
                feat_dic['seqid'] = feat_obj.seqid
                feat_dic['id'] = feat_obj.id
                feat_dic['source'] = feat_obj.source
                feat_dic['start'] = feat_obj.start
                feat_dic['end'] = feat_obj.end
                feat_dic["length"] = abs(feat_obj.end - feat_obj.start) + 1
                feat_dic['strand'] = feat_obj.strand
                feat_dic['frame'] = feat_obj.frame
                try:
                    feat_dic['locus_tag'] = feat_obj.attributes['locus_tag'][0]
                except KeyError:
                    pass
                try:
                    feat_dic['Note'] = feat_obj.attributes['Note']
                except KeyError:
                    pass
                feat_dic['extra'] = feat_obj.extra
                # if feat_type != "region":
                #     try:
                #         # nt_seqs = feat_obj.sequence(self.fasta_file_name)
                #         # nt_obj = Seq(nt_seqs)
                #         # feat_dic['nt_seq'] = nt_seqs
                #     except KeyError:
                #         pass
# ============================================================================#
                if feat_type == "CDS":
                    # translate the CDS
                    # feat_dic['aa_seqs'] = self.translate(nt_obj, "CDS")
                    # assign read numbers
                    try:
                        feat_dic["read_count"] = dic_of_reads["CDS"][feat_obj.id]
                    except KeyError:
                        feat_dic["read_count"] = None
                    try:
                        feat_dic["rpkm"] = dic_of_pkms["CDS"][feat_obj.id]
                    except KeyError:
                        feat_dic["rpkm"] = None

# ============================================================================#
                elif feat_type == 'rRNA':
                    try:
                        feat_dic["read_count"] = dic_of_reads["rRNA"][feat_obj.id]
                    except KeyError:
                        feat_dic["read_count"] = None
                    try:
                        feat_dic["rpkm"] = dic_of_pkms["rRNA"][feat_obj.id]
                    except KeyError:
                        feat_dic["rpkm"] = None

# ============================================================================#
                elif feat_type == 'tRNA':
                    try:
                        feat_dic["read_count"] = dic_of_reads["tRNA"][feat_obj.id]
                    except KeyError:
                        feat_dic["read_count"] = None
                    try:
                        feat_dic["rpkm"] = dic_of_pkms["tRNA"][feat_obj.id]
                    except KeyError:
                        feat_dic["rpkm"] = None
# ============================================================================#
                elif feat_type == 'exon':
                    try:
                        feat_dic["read_count"] = dic_of_reads["exon"][feat_obj.id]
                    except KeyError:
                        feat_dic["read_count"] = None
                    try:
                        feat_dic["rpkm"] = dic_of_pkms["exon"][feat_obj.id]
                    except KeyError:
                        feat_dic["rpkm"] = None
# ============================================================================#
                elif feat_type == "gene":
                    # assign read numbers
                    try:
                        feat_dic["read_count"] = dic_of_reads[feat_obj.id]
                    except KeyError:
                        feat_dic["read_count"] = None
                    try:
                        feat_dic["rpkm"] = dic_of_pkms["gene"][feat_obj.id]
                    except KeyError:
                        feat_dic["rpkm"] = None
                # just to make sure that keys are strings, else json dump fails
                feat_dic_str = {}
                for key, value in feat_dic.items():
                    feat_dic_str[str(key)] = value

                json_list.append(feat_dic_str)
            json.dump(json_list, json_file, indent=4)

    def assign_scores(self, feat_dic, edger_sdic, feat_id):
        """Assign scores from edger and deseq to summary dic."""
        try:
            feat_dic["edger_cpm"] = edger_sdic[0][feat_id]
        except KeyError:
            feat_dic["edger_cpm"] = None
        try:
            feat_dic["edger_rpkm"] = edger_sdic[1][feat_id]
        except KeyError:
            feat_dic["edger_rpkm"] = None

    def read_summary(self):
        """Get read values as a dictionary."""
        # read_file = feat_type + ".count"
        read_data = pd.read_csv(self.rd_count_fn, sep="\t", comment="#", index_col="Geneid")
        
            # use regular expression to get rid of the whole path
        read_data.columns = [x.split(".mapping.")[-1].split(".")[0] for x in read_data.columns]
        read_data.columns = ["Chr", "Start", "End", "Strand", "Length", "count"]
        read_unq_df = read_data.drop_duplicates(["Chr", "Start", "End", "Strand", "Length", "count"])
        read_dic_obj = read_unq_df.to_dict(orient="index")

        for feat, count_dic in read_dic_obj.items():
            # int_read = {}
            feat_read = {}
            for var, value in count_dic.items():
                if var == "count":
                    int_read = int(value)
            feat_read[feat] = int_read
            read_dic_obj.update(feat_read)# print(read_dic_obj)
        return read_dic_obj

    def translate(self, nucleotide, type):
        """Takes in a string of nucleotides and translate to AA."""
        if type == "CDS":
            aa = nucleotide.translate()
        elif type == "exon":
            aa = nucleotide.translate()
        else:
            aa = "not translated"
        return str(aa)  