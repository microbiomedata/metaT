FROM continuumio/miniconda3:24.4.0-0

# $ docker build . -t microbiomedata/meta_t:latest --build-arg http_proxy=http://proxyout.lanl.gov:8080 --build-arg https_proxy=http://proxyout.lanl.gov:8080
# $ docker login
# $ docker push microbiomedata/meta_t:latest

LABEL version="0.0.5"
LABEL software="NMDC_metatranscriptomics workflow"
LABEL tags="bioinformatics"

ENV container docker

# add directory relative to working directory
ADD pyp_metat/* /opt/conda/bin/pyp_metat/

RUN conda config --add channels conda-forge \
    &&  conda config --add channels bioconda

RUN conda install -c conda-forge pandas=2.1.4 --yes
RUN conda install -c bioconda gffutils=0.13  --yes
RUN conda clean -a


# add to env
ENV PATH="${PATH}:/opt/conda/bin/pyp_metat"

CMD ["/bin/bash"]
