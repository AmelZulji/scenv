FROM amelzulji/scenv:1.0.0

RUN apt-get update && \
    apt-get install -y \
    sudo \
    gdebi-core \
    wget \
    psmisc \
    libclang-dev \
    lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2024.04.2-764-amd64.deb
RUN gdebi -n rstudio-server-2024.04.2-764-amd64.deb
RUN rm rstudio-server-2024.04.2-764-amd64.deb

# RUN mkdir -p /etc/R

ENV DEFAULT_USER="rstudio"
RUN useradd -s /bin/bash -m "$DEFAULT_USER"
RUN echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd
RUN usermod -a -G staff "${DEFAULT_USER}"

RUN mkdir -p "/home/${DEFAULT_USER}/.config/rstudio" && \
    cat <<EOF >"/home/${DEFAULT_USER}/.config/rstudio/rstudio-prefs.json"
{
    "save_workspace": "never",
    "always_save_history": false,
    "reuse_sessions_for_project_links": true,
    "posix_terminal_shell": "bash",
    "initial_working_directory": "/"
}
EOF

# add library path which is installed by pak
RUN cat <<EOF >"/home/${DEFAULT_USER}/.Renviron"
R_LIBS_SITE="/usr/local/lib/R/site-library"
EOF

EXPOSE 8787
