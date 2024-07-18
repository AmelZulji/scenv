FROM ubuntu:20.04

# curl for downloading and gcc for compiling
RUN apt-get update \
    && apt-get install -y \
    curl \
    gcc

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
    && R -e 'pak::pkg_install(c("SeuratObject@4.1.3","Seurat@4.3.0","Signac@1.11.0", "bioc::MAST@1.30.0", "bioc::DESeq2@1.44.0", "optparse", "bioc::scDblFinder@1.18.0", "harmony@1.2.0", "tidyverse@2.0.0", "hdf5r"))' \
    # clean pak cache
    && R -e "pak::pak_cleanup(force=TRUE)" \
    # clean apt cache https://docs.docker.com/build/building/best-practices/#run:~:text=In%20addition%2C%20when,is%20not%20required.
    && rm -rf /var/lib/apt/lists/* \
    # remove tmp files
    && rm -r /tmp/*


# RUN apt-get update && \
#     apt-get install -y \
#     lib32gcc-s1 \
#     lib32stdc++6 \
#     libc6-i386 \
#     libclang-10-dev \
#     libclang-common-10-dev \
#     libclang-dev \
#     libclang1-10 \
#     libedit2 \
#     libgc1c2 \
#     libllvm10 \
#     libobjc-9-dev \
#     libobjc4 \
#     psmisc \
#     sudo

# RUN curl -O https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.04.2-764-amd64.deb
# RUN apt-get install -y ./rstudio-server-2024.04.2-764-amd64.deb
# # RUN gdebi -n rstudio-server-2024.04.2-764-amd64.deb

# ENV DEFAULT_USER="rstudio"
# RUN useradd -s /bin/bash -m "$DEFAULT_USER"
# RUN echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd
# RUN usermod -a -G staff "${DEFAULT_USER}"

# RUN mkdir -p "/home/${DEFAULT_USER}/.config/rstudio" && \
#     cat <<EOF >"/home/${DEFAULT_USER}/.config/rstudio/rstudio-prefs.json"
# {
#     "save_workspace": "never",
#     "always_save_history": false,
#     "reuse_sessions_for_project_links": true,
#     "posix_terminal_shell": "bash",
#     "initial_working_directory": "/"
# }
# EOF

# EXPOSE 8787