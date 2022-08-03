FROM continuumio/miniconda3:4.8.2

LABEL version="0.0.4"
LABEL software="NMDC_metatranscriptomics workflow"
LABEL tags="bioinformatics"

ENV container docker

RUN apt-get update --allow-releaseinfo-change -y \
    && apt-get install -y build-essential unzip wget curl gawk locales r-base\
    && apt-get clean

RUN conda config --add channels conda-forge && \ 
    conda config --add channels bioconda
RUN conda install megahit stringtie 
Run conda install pandas gffutils

RUN Rscript -e "install.packages('BiocManager', repos = 'http://cran.us.r-project.org')" \
    && Rscript -e "BiocManager::install('edgeR')"

RUN Rscript -e "install.packages('tidyverse', repos = 'http://cran.us.r-project.org')" \
    Rscript -e "install.packages('optparse', repos = 'http://cran.us.r-project.org')"


RUN wget https://github.com/microbiomedata/metaT/archive/refs/heads/metat-develop.zip \
    && unzip metat-develop.zip \
    && mkdir /scripts \
    && cp metaT-metat-develop/scripts/* /scripts \
    && rm -rf metaT-metat-develop/ metat-develop.zip

CMD ["/bin/bash"]
