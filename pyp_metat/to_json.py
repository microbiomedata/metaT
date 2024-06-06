#! /usr/bin/env python
# Written for NMDC-EDGE MetaTranscriptomics output formatting
# June 2024 Updated for JGI Read Counts incorporation 
import os
import json
import pandas as pd
import gffutils

################################################################################################################################################################################################################################################################################

class GTFtoJSON():
    """
    Converts GTF files to JSON records.

    Utilizes package gffutils to create database from gff / gtf files in gtf_json()
    Extracts desired attributes and features to json using collect_features().
    Utilizes package json to write json out and package os to check for db existence. 
    """

    def __init__(self, gtf_file_name: str, name_of_feat: str, out_json_file: str):
        """
        gtf_file_name: string of gtf or gff file, relative or absolute path both work

        name_of_feat: the type of records stored in gtf, options for gff_utils include: 
                gene, transcript, exon, CDS, Selenocysteine, start_codon, stop_codon, three_prime_utr and five_prime_utr
            this is the third column value in gff, as defined at https://agat.readthedocs.io/en/latest/gxf.html#main-points-and-differences-between-gtf-formats
        
        out_json_file: name of desired json output file, relative or absolute
        """
        self.gtf_file_name = gtf_file_name
        self.name_of_feat = name_of_feat        #  CDS, gene, etc
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
        else:
            gtf_as_db = gffutils.FeatureDB("metat_db.db", keep_order=True)
        json_list = []
        with open(self.out_json_file, "w") as json_file:
            for feat_obj in gtf_as_db.all_features():
                feat_dic = {}  # an empty dictionary to append features
                if feat_obj.featuretype == self.name_of_feat:
                    feat_dic_str = self.collect_features(feat_obj=feat_obj, feat_dic=feat_dic)
                    if bool(feat_dic_str):  # only append if dic is not empty
                        json_list.append(feat_dic_str)
            json.dump(json_list, json_file, indent=4)

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
        # feat_dic['extra'] = feat_obj.extra
        feat_dic['product'] = feat_obj.attributes['product'][0]
        feat_dic['product_source'] = feat_obj.attributes['product_source'][0]
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

################################################################################################################################################################################################################################################################################

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
        tsv_dic = tsv_obj.to_dict(orient="records")
        with open(self.out_json_file, "w") as json_file:
            json.dump(tsv_dic, json_file, indent=4)

################################################################################################################################################################################################################################################################################

def combine_json(json_file1: str, json_file2: str, out_json: str):
    """
    Combine JSON files from GFF and read count TSV using pandas
    """
    json1 = pd.read_json(json_file1)
    json2 = pd.read_json(json_file2)
    json3 = pd.merge(json1, json2, on = ["id", "seqid", "featuretype", "strand", "length"])
    j3_dic = json3.to_dict(orient="records")
     with open(self.out_json, "w") as json_file:
            json.dump(j3_dic, json_file, indent=4)
