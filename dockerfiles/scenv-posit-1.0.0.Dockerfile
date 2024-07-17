FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y \
    curl \
    gcc

# define version of python to be installed
ENV PYTHON_VERSION="3.12.4"
RUN curl -O https://cdn.rstudio.com/python/ubuntu-2004/pkgs/python-${PYTHON_VERSION}_1_amd64.deb && \
    apt-get update && \
    apt-get install -y ./python-${PYTHON_VERSION}_1_amd64.deb && \
    # remove downloaded binray
    rm python-${PYTHON_VERSION}_1_amd64.deb

# add python on path
ENV PATH=/opt/python/"${PYTHON_VERSION}"/bin:$PATH

# update core python packages like (pip wheel)
RUN pip install --upgrade pip setuptools wheel && \
    # pip install scanpy==1.10.2 decoupler==1.7.0 snakemake==8.16.0
    pip install pandas



ENV R_VERSION=4.4.1
RUN curl -O https://cdn.rstudio.com/r/ubuntu-2004/pkgs/r-${R_VERSION}_1_amd64.deb && \
    apt-get update && \
    apt-get install -y ./r-${R_VERSION}_1_amd64.deb && \
    # remove donwloded binary
    rm r-${R_VERSION}_1_amd64.deb && \
    # symlink R to the default path
    ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R && \
    # symlink Rscript to the default path
    ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

RUN R -e 'install.packages("pak", repos="https://packagemanager.posit.co/cran/__linux__/focal/latest")' && \
    R -e 'pak::pkg_install(c("hdf5r"))'

RUN rm -r /tmp/*