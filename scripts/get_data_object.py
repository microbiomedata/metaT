#!/usr/bin/env python3

import os, json, time, sys
from datetime import datetime
import collections
import hashlib


def md5sum(fname):
    md5_file = fname + ".md5"
    if os.path.isfile(md5_file):
        f = open(md5_file, "r")
        md5_string = f.read()
        f.close()
        return md5_string

    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    with open(md5_file, "w") as fw:
        fw.write(hash_md5.hexdigest())
    return hash_md5.hexdigest()


def md5string(text):
    result = hashlib.md5(text.encode())
    return result.hexdigest()


sampleid = sys.argv[1]
if len(sys.argv) > 2:
    idmap = sys.argv[2]
else:
    # idmap= "/global/cfs/cdirs/m3408/ficus/samp2gp.out"
    idmap = "/global/cfs/cdirs/m3408/aim2/output/id_mapping.txt"

idmap_dict = collections.defaultdict(dict)
with open(idmap, "r") as infile:
    for line in infile:
        # "1393_65597","Gp0095966","544588af0d87852530dcbf0e","8382.5.100461.AGTCAA.fastq.gz",13080010221
        sid, omic_id, file_id, file_name, file_size = line.replace('"', "").split(",")
        idmap_dict[sid]["omic_id"] = omic_id
        idmap_dict[sid]["file_id"] = file_id
        idmap_dict[sid]["file_name"] = file_name
        idmap_dict[sid]["file_size"] = file_size

# #:print(idmap_dict)
# if sampleid not in idmap_dict:
#     print(sampleid)
#     sys.exit()


# outfile = "RQC_" + str(idmap_dict[sampleid]["omic_id"]) + ".json"
# # if (os.path.isfile(outfile)):
# # sys.exit()


# metadata = collections.defaultdict(dict)
mhit_assem_fname = (
    "/global/cfs/cdirs/m3408/ficus/pipeline_products/"
    + sampleid
    + "/assembly/assembly_contigs.fna"
)
if os.path.exists(mhit_assem_fname) is False:
    sys.exit()
assem_md5sum_statfile = md5sum(mhit_assem_fname)  # get the md5s
assem_file_size = os.stat(mhit_assem_fname).st_size  # get the file size

metat_outjson_fname = (
    "/global/cfs/cdirs/m3408/ficus/pipeline_products/"
    + sampleid
    + "/metat_out_json/output.json"
)
if os.path.exists(metat_outjson_fname) is False:
    sys.exit()
metatjson_md5sum_statfile = md5sum(metat_outjson_fname)  # get the md5s
metatjson_file_size = os.stat(metat_outjson_fname).st_size  # get the file size

non_ribo_R1 = (
    "/global/cfs/cdirs/m3408/ficus/pipeline_products/"
    + sampleid
    + "/non_ribo_reads/filtered_R1.fastq"
)
if os.path.exists(non_ribo_R1) is False:
    sys.exit()

nonriboR1_md5sum_statfile = md5sum(non_ribo_R1)  # get the md5s
nonriboR1_file_size = os.stat(non_ribo_R1).st_size  # get the file size

non_ribo_R2 = (
    "/global/cfs/cdirs/m3408/ficus/pipeline_products/"
    + sampleid
    + "/non_ribo_reads/filtered_R2.fastq"
)
if os.path.exists(non_ribo_R1) is False:
    sys.exit()
nonriboR2_md5sum_statfile = md5sum(non_ribo_R2)  # get the md5s
nonriboR2_file_size = os.stat(non_ribo_R2).st_size  # get the file size


# statfile_time = datetime.fromtimestamp(os.path.getmtime(statfile)).strftime(
#     "%Y-%m-%d"
# )  # get the timestamp
# file_list = sampleid + "/qa/file-list.txt"  # one of the output of RQC
# file_list_time = datetime.fromtimestamp(os.path.getmtime(file_list)).strftime(
#     "%Y-%m-%d"
# )
# with open(
#     statfile, "r"
# ) as f:  # reading the stat file to get high level summary to put it in activity JSON as data object only files not stats
#     for line in f:
#         if "inputReads" in line:
#             key, value = line.rstrip().split("=")
#             metadata["input_read_count"] = int(value)
#         if "inputBases" in line:
#             key, value = line.rstrip().split("=")
#             metadata["input_read_bases"] = int(value)
#         if "outputReads" in line:
#             key, value = line.rstrip().split("=")
#             metadata["output_read_count"] = int(value)
#         if "outputBases" in line:
#             key, value = line.rstrip().split("=")
#             metadata["output_read_bases"] = int(value)


# filterfile = sampleid + "/qa/" + sampleid + ".filtered.fastq.gz" # filtered or processed fastq
# if os.path.islink(filterfile):
#     realfilterfilename = os.path.realpath(filterfile)
# else:
#     realfilterfilename = filterfile
# md5sum_realfilterfilename = md5sum(realfilterfilename)
# filesize_realfilterfilename = os.stat(realfilterfilename).st_size
# rawfilename = realfilterfilename.replace("anqdpht.", "")

omics_process_id = "gold:" + idmap_dict[sampleid]["omic_id"]
# ## init data dict of dict
# data = collections.defaultdict(dict)
# key = "ReadQC"
# data[key]["id"] = "nmdc:" + md5string("ReadQC activiity " + sampleid + file_list_time)
# data[key]["name"] = "ReadQC activiity " + sampleid
# data[key]["was_informed_by"] = omics_process_id
# data[key]["started_at_time"] = file_list_time
# data[key]["ended_at_time"] = statfile_time
# data[key]["type"] = "nmdc:ReadQCAnalysisActivity"
# # data[key]["workflow_version"]="1.0.0"
# data[key]["execution_resource"] = "NERSC - Cori"
# data[key]["git_url"] = "https://github.com/microbiomedata/ReadsQC/releases/tag/1.0.0"
# data[key]["has_input"] = []
# data[key]["has_output"] = []
# # data[key]["data_object_set"]=[]
# data[key].update(metadata)

# data[key]["has_input"].append("jgi:" + idmap_dict[sid]["file_id"])

# data[key]["has_output"].append("nmdc:" + md5sum_statfile)
# data[key]["has_output"].append("nmdc:" + md5sum_realfilterfilename)
# data object
data_object = []


data_object.append(
    {
        "id": "nmdc:" + nonriboR1_md5sum_statfile,
        "name": "filtered_R1.fastq",
        "description": "R1 reads without the ribosomal sequences for "
        + omics_process_id,
        "file_size_bytes": nonriboR1_file_size,
        "md5_checksum": nonriboR1_md5sum_statfile,
        "url": "https://data.microbiomedata.org/data/"
        + sampleid
        + "/non_ribo_reads/filtered_R1.fastq",
        "type": "nmdc:DataObject",
        "data_object_type": "filtered_R1.fastq",
    }
)

data_object.append(
    {
        "id": "nmdc:" + nonriboR2_md5sum_statfile,
        "name": "filtered_R2.fastq",
        "description": "R2 reads without the ribosomal sequences for "
        + omics_process_id,
        "file_size_bytes": nonriboR2_file_size,
        "md5_checksum": nonriboR2_md5sum_statfile,
        "url": "https://data.microbiomedata.org/data/"
        + sampleid
        + "/non_ribo_reads/filtered_R2.fastq",
        "type": "nmdc:DataObject",
        "data_object_type": "filtered_R2.fastq",
    }
)

data_object.append(
    {
        "id": "nmdc:" + assem_md5sum_statfile,
        "name": "assembly_contigs.fna",
        "description": "Assembly file, used MEGAHIT for" + omics_process_id,
        "file_size_bytes": assem_file_size,
        "md5_checksum": assem_md5sum_statfile,
        "url": "https://data.microbiomedata.org/data/"  # location of the file, need to update for metaT
        + sampleid
        + "/assembly/assembly_contigs.fna",
        "type": "nmdc:DataObject",
        "data_object_type": "assembly_contigs.fna",
    }
)

data_object.append(
    {
        "id": "nmdc:" + metatjson_md5sum_statfile,
        "name": "output.json",
        "description": "JSON records of features and the associated read counts and RPKMs for "
        + omics_process_id,
        "file_size_bytes": metatjson_file_size,
        "md5_checksum": metatjson_md5sum_statfile,
        "url": "https://data.microbiomedata.org/data/"
        + sampleid
        + "/metat_out_json/output.json",
        "type": "nmdc:DataObject",
        "data_object_type": "output.json",
    }
)


# with open(outfile, "w") as outfile:
#     json.dump(data, outfile, indent=4)

outfile2 = "metaT_" + str(idmap_dict[sampleid]["omic_id"]) + "_dataObject.json"
with open(outfile2, "w") as out:
    json.dump(data_object, out, indent=4)
