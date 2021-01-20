#!/bin/bash
#SBATCH --qos=regular
#SBATCH --time=6:00:00
#SBATCH --output=/path/to/out/out.log
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 32
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=youremail@something.com
#SBATCH --constraint=haswell
#SBATCH --account=act_name
#SBATCH --job-name=job_name

cd /path/to/out

java -Dconfig.file=/path/to/shifter.conf \
    -jar /path/to/cromwell-XX.jar \
    run -m /path/to/metadata_out.json -i input.json /path/to/metaT/workflows/dock_metaT.wdl 

