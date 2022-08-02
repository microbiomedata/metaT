#! /usr/bin/env python
import os
import json
import pandas as pd
import gffutils
import argparse
import csv

'''
This is a script that merges gff results with feature count and rpkm calculations. 
'''

###############################
'''Set Global Variables'''
###############################

features_list = [
     "CDS",
     "INTERGENIC",
     "misc_feature",
     "ncRNA",
     "regulatory",
     "rRNA",
     "tmRNA",
     "tRNA"
]

class GTFtoJSON():
    """Converts GTF files to JSON records."""

    def __init__(self, gtf_file_name, name_of_feat, out_json_file):
        self.gtf_file_name = gtf_file_name
        self.name_of_feat = name_of_feat
        self.out_json_file = out_json_file

    def gtf_json(self):
        """A function that converts a gff file to JSON file."""
        # read in the gff file to a database
        if os.path.exists("metat_db.db") is False:
            gtf_as_db = gffutils.create_db(self.gtf_file_name, dbfn="metat_db.db", force=True,
                                           keep_order=True,
                                           merge_strategy="create_unique")
        else:
            gtf_as_db = gffutils.FeatureDB("metat_db.db", keep_order=True)
        json_list = []
        with open(self.out_json_file, "w") as json_file:
            for feat_obj in gtf_as_db.all_features():
                feat_dic = {}  # an empty dictionary to append features
                feat_type = feat_obj.featuretype
                if feat_type == self.name_of_feat:
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


class SummarizeFeatures():

    def __init__(self, gff_file_name, rd_count_fn, pkm_sc_fn):
        self.gff_file_name = gff_file_name
        self.rd_count_fn = rd_count_fn
        self.pkm_sc_fn = pkm_sc_fn

    def get_pkms_summ(self):
        '''
        Get PKM values
        Input: EdgeR rpkm file 
        Output: Dictionary {GeneID: RPKM}
        '''
        pm_dict_obj = pd.read_csv(self.pkm_sc_fn, sep=",", engine='python',
                                  comment="#", index_col="Geneid").to_dict(orient="index")
        for feat, rpkm_dic in pm_dict_obj.items():
            feat_rpkm = {}
            for var, value in rpkm_dic.items():
                if var == "RPKM":
                    int_read = round(float(value), 3)
            feat_rpkm[feat] = int_read
            pm_dict_obj.update(feat_rpkm)
        return pm_dict_obj

    def read_summary(self):
        '''
        Get read values as a dictionary. 
        Input: Read Count File
        Output: Dictionary {GeneID: Read Count}
        '''
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
            feat_read = {}
            for var, value in count_dic.items():
                if var == "count":
                    int_read = int(value)
            feat_read[feat] = int_read
            read_dic_obj.update(feat_read)
        return read_dic_obj

    def collect_features(self, feat_type, feat_obj, feat_dic):
        '''A function that collect features. 
           Input: Feature String, Feature object from gff db, feature dictionary {GeneID: GeneID, Read Count: Int, RPKM: Int}
           Output: Dictionary object for each entry: {id: Str(GeneID), Read Count: Int, RPKM: Int, Featurtype: Str, seqid: str,
           source: str, start: Int, end: Int, length: Int, Strand: +/-, frame: Int, extra: List}
        '''
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

    def informFeatures(self): 
        # read in the gff file to a database
        gffutils.create_db(self.gff_file_name, dbfn="metat_db.db", force=True,
                                        keep_order=True,
                                        merge_strategy="create_unique")
        gff_as_db = gffutils.FeatureDB('metat_db.db', keep_order=True)
        dic_of_pkms = self.get_pkms_summ()
        dic_of_reads = self.read_summary()

        feat_sense_list = []
        feat_anti_list = []
        
        for feat_obj in gff_as_db.all_features():
            feat_dic = {}  # an empty dictionary to append features
            feat_type = feat_obj.featuretype
            if feat_obj.strand == "+":
                try:
                    feat_dic["read_count"] = dic_of_reads[feat_obj.id]
                    feat_dic["read_countA"] = 0
                except KeyError:
                    feat_dic["read_count"] = 0
                    feat_dic["read_countA"] = 0
                try:
                    feat_dic["rpkm"] = dic_of_pkms[feat_obj.id]
                    feat_dic["rpkmA"] = 0
                except KeyError:
                    feat_dic["rpkm"] = None
                    feat_dic["rpkmA"] = None
                feat_dic_strS = self.collect_features(
                    feat_type=feat_type, feat_obj=feat_obj, feat_dic=feat_dic)
                feat_sense_list.append(feat_dic_strS)
            elif feat_obj.strand == "-":
                try:
                    feat_dic["read_count"] = 0
                    feat_dic["read_countA"] = dic_of_reads[feat_obj.id]
                except KeyError:
                    feat_dic["read_count"] = 0
                    feat_dic["read_countA"] = 0
                try:
                    feat_dic["rpkm"] = 0
                    feat_dic["rpkmA"] = dic_of_pkms[feat_obj.id]
                except KeyError:
                    feat_dic["rpkm"] = 0
                    feat_dic["rpkmA"] = 0
                feat_dic_strA = self.collect_features(
                    feat_type=feat_type, feat_obj=feat_obj, feat_dic=feat_dic)
                feat_anti_list.append(feat_dic_strA)

        return feat_sense_list,feat_anti_list



if __name__=="__main__":

    parser=argparse.ArgumentParser(description = "Merge GFF, Counts, and RPKM information for MetaT Analysis ")
    parser.add_argument('-gff','--gff3', help='GFF3 file', required = True, type = str)
    parser.add_argument('-pkm', '--rpkm_file' ,help='Take in functional annotation md5sum', required=True,type=str)
    parser.add_argument('-rd_count', '--read_count', help='Informed by nmdc activity id', required=True, type=str)
    parser.add_argument('-proj', '--project_id', help='Informed by nmdc activity id', required=True, type=str)
    #set args
    args = parser.parse_args()

    sumfeats = SummarizeFeatures(gff_file_name=args.gff3,pkm_sc_fn=args.rpkm_file, rd_count_fn=args.read_count)
    summaryS,summaryA = sumfeats.informFeatures()
    summary_list = summaryS + summaryA

    headers = summary_list[0].keys()

    with open(f'{args.project_id}_rpkm_summary.tsv', 'w', newline='') as output_file:
        dict_writer = csv.DictWriter(output_file, headers, delimiter = "\t")
        dict_writer.writeheader()
        dict_writer.writerows(summary_list)