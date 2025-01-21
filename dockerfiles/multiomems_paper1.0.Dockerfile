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
# install Posit binary https://docs.posit.co/resources/install-python.html
# Specify python version to be installed
ENV PYTHON_VERSION="3.12.4"
RUN curl -O https://cdn.rstudio.com/python/ubuntu-2004/pkgs/python-${PYTHON_VERSION}_1_amd64.deb \
    && apt-get update \
    && apt-get install -y ./python-${PYTHON_VERSION}_1_amd64.deb \
    # remove downloaded binray
    && rm python-${PYTHON_VERSION}_1_amd64.deb


# add python on path
ENV PATH=/opt/python/"${PYTHON_VERSION}"/bin:$PATH
# copy script with listed packages to be installed
COPY ../python_requirements.txt /tmp/python_requirements.txt

# update core python packages
RUN pip install --upgrade pip setuptools wheel \
    # install packages from list
    && pip install -r /tmp/python_requirements.txt \
    && rm -rf /root/.cache/pip

#### R ####
# install Posit binary https://docs.posit.co/resources/install-r.html
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

# copy script with packages to be installed
COPY ../install_R_packages.R /tmp/install_R_packages.R

# install packages from the list
RUN Rscript /tmp/install_R_packages.R \
    # Clean up any leftover temporary files
    && rm -rf /tmp/*