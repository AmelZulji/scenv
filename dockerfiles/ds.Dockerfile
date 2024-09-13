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
    # scanpy==1.10.2 \
    # decoupler==1.7.0 \
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

# Install pak package from R package manager
RUN R -e 'install.packages("pak", repos="https://packagemanager.posit.co/cran/__linux__/focal/latest")'

# Install other required R packages via pak
RUN R -e 'pak::pkg_install(c( \
    "SeuratObject@4.1.3", \
    "Seurat@4.3.0", \
    "Signac@1.11.0", \
    # "bioc::MAST@1.30.0", \ 
    # "bioc::DESeq2@1.44.0", \
    "optparse", \
    # "bioc::scDblFinder@1.18.0", \
    # "harmony@1.2.0", \
    "tidyverse@2.0.0", \
    "hdf5r", \
    # "bioc::clusterProfiler@4.12.1", \
    "bioc::glmGamPoi@1.16.0" \
    ))'

# Clean pak cache
RUN R -e "pak::pak_cleanup(force=TRUE)"

# install quarto
ENV QUARTO_VERSION="1.5.54"
RUN mkdir -p /opt/quarto/${QUARTO_VERSION}
RUN curl -o quarto.tar.gz -L "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
RUN tar -zxvf quarto.tar.gz \
    -C "/opt/quarto/${QUARTO_VERSION}" \
    --strip-components=1
RUN rm quarto.tar.gz

# Clean apt cache to reduce the image size
RUN rm -rf /var/lib/apt/lists/*

# Remove temporary files
RUN rm -r /tmp/*

