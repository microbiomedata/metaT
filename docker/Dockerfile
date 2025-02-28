FROM continuumio/miniconda3:4.10.3

# $ docker build . -t microbiomedata/meta_t:[version] --build-arg http_proxy=http://proxyout.lanl.gov:8080 --build-arg https_proxy=http://proxyout.lanl.gov:8080
# $ docker login
# $ docker push microbiomedata/meta_t:[version]

LABEL version="0.0.5"
LABEL software="NMDC_metatranscriptomics workflow"
LABEL tags="bioinformatics"

ENV container docker

RUN apt-get update -y \
    && apt-get install -y build-essential unzip wget curl gawk locales\
    && apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda
RUN conda install -c bioconda stringtie --yes
RUN conda install -c bioconda subread --yes
# RUN conda install -c bioconda samtools --force-reinstall --yes
# RUN conda install openssl=1.0 --yes
RUN conda install -c bioconda megahit --yes
# RUN conda install -c bioconda hisat2 --yes
# RUN conda install -c bioconda sortmerna --yes
RUN conda install R --yes
RUN conda clean -a
RUN pip install gffutils
RUN pip install pandas



RUN R -e "install.packages('BiocManager', repos = 'http://cran.us.r-project.org')" \
    && R -e "BiocManager::install('edgeR')"

RUN R -e "install.packages('tidyverse', repos = 'http://cran.us.r-project.org')" \
    R -e "install.packages('optparse', repos = 'http://cran.us.r-project.org')"

# RUN wget https://github.com/mshakya/WorkflowPlanning/archive/master.zip \
#     && unzip master.zip \
#     && cp WorkflowPlanning-master/metatranscriptomics/scripts/edgeR.R /usr/local/bin \
#     && rm -rf WorkflowPlanning-master/ master.zip

CMD ["/bin/bash"]
