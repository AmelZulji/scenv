FROM ubuntu:20.04

# Install curl (that will download rig), and configure locales
RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    curl \
    gnupg \
    locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# By default, user libraries will be installed in the root. To avoid problems during conversion to singularity, change path to user libs with R_LIBS_USER
ENV LANG=en_US.UTF-8 \ 
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    R_LIBS_USER=/usr/local/lib/R/site-library

# Install rig as described here: https://github.com/r-lib/rig?tab=readme-ov-file#id-linux 
# Install R without pak to avoid installing packages in root which is problematic for later conversion to .sif format
RUN curl -L https://rig.r-pkg.org/deb/rig.gpg -o /etc/apt/trusted.gpg.d/rig.gpg && \
    sh -c 'echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list' && \
    apt-get update && \
    apt-get install -y r-rig && \
    rig add 4.4.1 --without-pak && \ 
    rm -rf /tmp/rig && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install R packages (will be installed in the path specified in R_LIBS_USER)
RUN R -e "install.packages(c('pak'))" && \
    R -e "pak::pkg_install(c('SeuratObject@4.1.3','Seurat@4.3.0','Signac@1.11.0', 'bioc::MAST@1.30.0', 'bioc::DESeq2@1.44.0', 'optparse'))" && \
    R -e "pak::pkg_install(c('bioc::scDblFinder@1.18.0'))" && \
    R -e "pak::pkg_install(c('harmony@1.2.0'))" && \
    R -e "pak::pkg_install(c('tidyverse@2.0.0'))" && \
    R -e "pak::pkg_install(c('hdf5r'))" && \
    R -e "pak::pak_cleanup(force=TRUE)"

RUN pip3 install snakemake