FROM ubuntu:20.04

# curl for downloading and gcc for compiling
RUN apt-get update \
    && apt-get install -y \
    curl \
    gcc \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    libclang-10-dev \
    libclang-common-10-dev \
    libclang-dev \
    libclang1-10 \
    libedit2 \
    libgc1c2 \
    libllvm10 \
    libobjc-9-dev \
    libobjc4 \
    psmisc \
    sudo \
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
    snakemake==8.16.0 \ 
    # needed for python in vscode/quarto
    ipykernel

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

# Install R package manager - pak (uses package binaries from posit - usefull for speed)
RUN R -e 'install.packages("pak", repos="https://packagemanager.posit.co/cran/__linux__/focal/latest")'

# Use pak to install other packages
RUN R -e 'pak::pkg_install(c( \
    # "SeuratObject@4.1.3", \
    # "Seurat@4.3.0", \
    # "Signac@1.11.0", \
    # "bioc::MAST@1.30.0", \ 
    # "bioc::DESeq2@1.44.0", \
    "optparse", \
    # supports R code editing in vscode 
    "languageserver", \ 
    # enables combining R and python
    "reticulate", \
    "tidyverse@2.0.0" \
    # "bioc::scDblFinder@1.18.0", \
    # "harmony@1.2.0", \
    # "hdf5r", \
    # "bioc::clusterProfiler@4.12.1", \
    # "bioc::glmGamPoi@1.16.0" \
    ))'

# Clean pak cache
RUN R -e "pak::pak_cleanup(force=TRUE)"

#### RSTUDIO SERVER ####
ENV DEFAULT_USER="rstudio"

RUN curl -O https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.04.2-764-amd64.deb \
    && apt-get install -y ./rstudio-server-2024.04.2-764-amd64.deb \
    && rm rstudio-server-2024.04.2-764-amd64.deb

RUN useradd -s /bin/bash -m "$DEFAULT_USER"
RUN echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd
RUN usermod -a -G staff "${DEFAULT_USER}"

# set session settings. List of all possibilities here: https://docs.posit.co/ide/user/ide/guide/productivity/custom-settings.html 
RUN mkdir -p "/home/${DEFAULT_USER}/.config/rstudio" && \
    cat <<EOF >"/home/${DEFAULT_USER}/.config/rstudio/rstudio-prefs.json"
{
    "save_workspace": "never",
    "always_save_history": false,
    "reuse_sessions_for_project_links": true,
    "posix_terminal_shell": "bash",
    "initial_working_directory": "/",
    "insert_native_pipe_operator": true,
    "restore_last_project": false,
    "load_workspace": false,
    "highlight_selected_line": true
}
EOF

#### QUARTO ####
# install quarto binaries built by posit https://docs.posit.co/resources/install-quarto.html
ENV QUARTO_VERSION="1.5.54"
RUN mkdir -p /opt/quarto/${QUARTO_VERSION}
RUN curl -o quarto.tar.gz -L "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
RUN tar -zxvf quarto.tar.gz \
    -C "/opt/quarto/${QUARTO_VERSION}" \
    --strip-components=1
#ad soft link so that quarto is globally available
RUN ln -s /opt/quarto/${QUARTO_VERSION}/bin/quarto /usr/local/bin/quarto

# remove quarto installer
RUN rm quarto.tar.gz

#### CLEANUP ####
# Clean apt cache to reduce the image size
RUN rm -rf /var/lib/apt/lists/*

# Remove temporary files
RUN rm -r /tmp/*