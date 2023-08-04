FROM ubuntu:20.04

ENV TERM="xterm-color"
ARG USER_ID=999
ARG GROUP_ID=999
ARG USER=docker
ARG PWD=docker
ARG HOME="/home/$USER"

# Create our group and user so we can login as ourself. Useful for ssh.
RUN groupadd -g $GROUP_ID $USER && \
    useradd -g $GROUP_ID -m -s /bin/bash -d $HOME -u $USER_ID $USER

# Suppresses prompt for timezone
ENV DEBIAN_FRONTEND=noninteractive

# Update dependencies
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install git bash python3

RUN ln -s /usr/bin/python3 /usr/bin/python

# Other stuff that might be helpful
RUN apt-get -y install vim curl ca-certificates

# Clean up old package data that's no longer needed.
RUN apt autoremove -y

# We get SSL issue if we don't include Zscaler certificates DUH....
COPY ZscalerRootCertificate-2048-SHA256.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Switch user to you
USER $USER

# Git repo init will complain not having user.name and email
RUN git config --global user.name Docker
RUN git config --global user.email docker@fluke.com

# Stop repo from prompting for color
RUN git config --global color.ui false

# Install and setup google repo
RUN mkdir -p ~/.bin
RUN echo '\n\
export PATH="$HOME/.bin:$PATH"\n\
\n' >> ~/.bashrc
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
RUN chmod a+rx ~/.bin/repo

# start the ssh-agent && and prompt for ssh passphrase
# Run this whenever we call bash so don't forget.
RUN echo '\n\
ssh_start_agent() {\n\
    if [ ! -S "${HOME}/.ssh/ssh_auth_sock_${HOSTNAME}" ]; then\n\
        echo "Running ssh-agent from .bashrc"\n\
        eval "$(ssh-agent)"\n\
        ln -sf "$SSH_AUTH_SOCK" "${HOME}/ssh_auth_sock_${HOSTNAME}"\n\
    fi\n\
    export SSH_AUTH_SOCK="${HOME}/ssh_auth_sock_${HOSTNAME}"\n\
    ssh-add -l > /dev/null || ssh-add\n\
}\n\
ssh_start_agent\n' >> ${HOME}/.bashrc

WORKDIR $PWD
CMD /bin/bash

