FROM ubuntu:20.04

# curl for downloading and gcc for compiling
RUN apt-get update \
    && apt-get install -y \
    curl \
    gcc \
    locales \ 
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	    && locale-gen en_US.utf8 \
	    && /usr/sbin/update-locale LANG=en_US.UTF-8

#### PYTHON ####
# install from Posit compiled binaries https://docs.posit.co/resources/install-python.html
# Specify python version to be installed
ENV PYTHON_VERSION="3.12.4"
RUN curl -O https://cdn.rstudio.com/python/ubuntu-2004/pkgs/python-${PYTHON_VERSION}_1_amd64.deb \
    && apt-get update \
    && apt-get install -y ./python-${PYTHON_VERSION}_1_amd64.deb \
    # remove downloaded binray
    && rm python-${PYTHON_VERSION}_1_amd64.deb

# add python on path
ENV PATH=/opt/python/"${PYTHON_VERSION}"/bin:$PATH

    # update core python packages
RUN pip install --upgrade pip setuptools wheel \
    # install needed packages
    && pip install \
    scanpy==1.10.2 \
    decoupler==1.7.0 \
    snakemake==8.16.0

#### R ####
# install from Posit compiled binaries https://docs.posit.co/resources/install-r.html
# Specify R version to be installed
ENV R_VERSION=4.4.1
RUN curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${R_VERSION}_1_amd64.deb \
    && apt-get update \
    && apt-get install -y ./r-${R_VERSION}_1_amd64.deb \
    # remove donwloded binary
    && rm r-${R_VERSION}_1_amd64.deb \
    # symlink R to the default path
    && ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R \
    # symlink Rscript to the default path
    && ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

RUN R -e 'install.packages("pak", repos="https://packagemanager.posit.co/cran/__linux__/focal/latest")' \
    && R -e 'pak::pkg_install(c( \
        "SeuratObject@4.1.3", \
        "Seurat@4.3.0", \
        "Signac@1.11.0", \
        "harmony@1.2.0", \
        "hdf5r", \
        "immunogenomics/presto@1.0.0", \
        "optparse", \
        "tidyverse@2.0.0", \
        "magick@2.8.5", \
        "bioc::BayesSpace@1.14.0", \
        "bioc::MAST@1.30.0", \
        "lme4/lme4@bfd7a44d0a718fff090412871504858559a0829f", \
        "bioc::DESeq2@1.44.0", \
        "bioc::scDblFinder@1.18.0", \
        "bioc::glmGamPoi@1.16.0", \
        "bioc::clusterProfiler@4.12.6" \
    ))' \
    # clean pak cache
    && R -e "pak::pak_cleanup(force=TRUE)" \
    # clean apt cache https://docs.docker.com/build/building/best-practices/#run:~:text=In%20addition%2C%20when,is%20not%20required.
    && rm -rf /var/lib/apt/lists/* \
    # remove tmp files
    && rm -r /tmp/*
