FROM amelzulji/scenv:1.0.1

ENV DEFAULT_USER="rstudio"

RUN apt-get update && \
    apt-get install -y \
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

RUN rm -rf /var/lib/apt/lists/* 

EXPOSE 8787