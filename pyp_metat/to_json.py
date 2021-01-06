#! /usr/bin/env python

import json
import gffutils
import pandas as pd


class ConverToJson():
    """ Summarizes and converts all the results to one big JSON file."""

    def __init__(self, gff_file_name, rd_count_fn, name_of_feat, pkm_sc_fn, fasta_file_name, out_json_file, gff_db_fn):
        self.gff_file_name = gff_file_name
        self.gff_db_fn = gff_db_fn
        self.fasta_file_name = fasta_file_name
        self.rd_count_fn = rd_count_fn
        self.pkm_sc_fn = pkm_sc_fn
        self.name_of_feat = name_of_feat
        self.out_json_file = out_json_file

    def get_pkms_summ(self):
        """Get PKM values."""
        pm_dict_obj = pd.read_csv(self.pkm_sc_fn, sep=",", engine='python',
                                  comment="#", index_col="Geneid").to_dict(orient="index")
        for feat, rpkm_dic in pm_dict_obj.items():
            feat_rpkm = {}
            for var, value in rpkm_dic.items():
                if var == "RPKM":
                    int_read = round(float(value), 3)
            feat_rpkm[feat] = int_read
            pm_dict_obj.update(feat_rpkm)  # print(pm_dict_obj)
        return pm_dict_obj

    def gff2json(self):
        """A function that converts a gff file to JSON file."""
        # read in the gff file to a database
        gff_as_db = gffutils.FeatureDB(self.gff_db_fn, keep_order=True)
        dic_of_pkms = {}
        dic_of_reads = {}
        json_list = []
        with open(self.out_json_file, "w") as json_file:
            dic_of_pkms[self.name_of_feat] = self.get_pkms_summ()
            dic_of_reads[self.name_of_feat] = self.read_summary()
            for feat_obj in gff_as_db.all_features():
                feat_dic = {}  # an empty dictionary to append features
                feat_type = feat_obj.featuretype
                if feat_type == self.name_of_feat:
                    # assign read numbers and rpkms
                    try:
                        feat_dic["read_count"] = dic_of_reads[self.name_of_feat][feat_obj.id]
                    except KeyError:
                        feat_dic["read_count"] = None
                    try:
                        feat_dic["rpkm"] = dic_of_pkms[self.name_of_feat][feat_obj.id]
                    except KeyError:
                        feat_dic["rpkm"] = None
                    feat_dic_str = self.collect_features(
                        feat_type=feat_type, feat_obj=feat_obj, feat_dic=feat_dic)
                    if bool(feat_dic_str):  # only append if dic is not empty
                        json_list.append(feat_dic_str)
            json.dump(json_list, json_file, indent=4)

    def collect_features(self, feat_type, feat_obj, feat_dic):
        """A function that collect features."""
        feat_dic['featuretype'] = feat_type
        feat_dic['seqid'] = feat_obj.seqid
        feat_dic['id'] = feat_obj.id
        feat_dic['source'] = feat_obj.source
        feat_dic['start'] = feat_obj.start
        feat_dic['end'] = feat_obj.end
        feat_dic["length"] = abs(feat_obj.end - feat_obj.start) + 1
        feat_dic['strand'] = feat_obj.strand
        feat_dic['frame'] = feat_obj.frame
        feat_dic['extra'] = feat_obj.extra
        try:
            feat_dic['cog'] = feat_obj.attributes['cog'][0]
        except KeyError:
            pass
        try:
            feat_dic['ko'] = feat_obj.attributes['ko'][0]
        except KeyError:
            pass
        try:
            feat_dic['pfam'] = feat_obj.attributes['pfam'][0]
        except KeyError:
            pass
        try:
            feat_dic['ec_number'] = feat_obj.attributes['ec_number'][0]
        except KeyError:
            pass
        try:
            feat_dic['locus_tag'] = feat_obj.attributes['locus_tag'][0]
        except KeyError:
            pass
        try:
            feat_dic['product'] = feat_obj.attributes['product'][0]
        except KeyError:
            pass
        try:
            feat_dic['Note'] = feat_obj.attributes['Note']
        except KeyError:
            pass
        # just to make sure that keys are strings, else json dump fails
        feat_dic_str = {}
        for key, value in feat_dic.items():
            feat_dic_str[str(key)] = value
        return feat_dic_str

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
        read_data = pd.read_csv(
            self.rd_count_fn, sep="\t", comment="#", index_col="Geneid")

        # use regular expression to get rid of the whole path
        read_data.columns = [x.split(".mapping.")[-1].split(".")[0]
                             for x in read_data.columns]
        read_data.columns = ["Chr", "Start",
                             "End", "Strand", "Length", "count"]
        read_unq_df = read_data.drop_duplicates(
            ["Chr", "Start", "End", "Strand", "Length", "count"])
        read_dic_obj = read_unq_df.to_dict(orient="index")

        for feat, count_dic in read_dic_obj.items():
            # int_read = {}
            feat_read = {}
            for var, value in count_dic.items():
                if var == "count":
                    int_read = int(value)
            feat_read[feat] = int_read
            read_dic_obj.update(feat_read)  # print(read_dic_obj)
        return read_dic_obj
