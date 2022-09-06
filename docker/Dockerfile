FROM continuumio/miniconda3:4.8.2

LABEL version="0.0.4"
LABEL software="NMDC_metatranscriptomics workflow"
LABEL tags="bioinformatics"

ENV container docker

RUN apt-get update --allow-releaseinfo-change -y \
    && apt-get install -y build-essential unzip wget curl gawk locales\
    && apt-get clean

RUN conda config --add channels conda-forge \
    && conda config --add channels bioconda
RUN conda install -c bioconda stringtie --yes \
    && conda install -c bioconda megahit --yes \
    && conda install R --yes \
    && conda clean -a 
RUN pip install gffutils pandas
RUN conda install R-tidyverse R-optparse \
    && conda install bioconductor-edger

RUN wget https://github.com/microbiomedata/metaT/archive/refs/heads/metat-develop.zip \
    && unzip metat-develop.zip \
    && mkdir -p /scripts \
    && cp metaT-metat-develop/scripts/* /scripts \
    && rm -rf metaT-metat-develop/ metat-develop.zip

CMD ["/bin/bash"]