FROM ubuntu:focal

ARG HOME=/root

# Agent forwarding during docker build https://stackoverflow.com/questions/43418188/ssh-agent-forwarding-during-docker-build
# install ssh client and git
RUN apt-get update
RUN apt-get install -y openssh-client git

# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Install tools
RUN apt-get update &&  apt-get install -y \
    nano \
    ranger \
    tmux \
    tmuxinator \
    htop

# Copy tools configuration
COPY ./to_copy/nanorc $HOME/.nanorc
COPY ./to_copy/ranger $HOME/.config/ranger/rc.conf
COPY ./to_copy/aliases $HOME/.bash_aliases
COPY ./to_copy/tmux $HOME/.tmux.conf
WORKDIR $HOME

RUN --mount=type=ssh git clone git@github.com:WatchPlant/OrangeBox.git

WORKDIR $HOME/OrangeBox
RUN git checkout lovro-dev

RUN apt-get install -y \
    build-essential \
    python3-pip

RUN python3 -m pip install \
    pyyaml \
    dash \
    pandas \
    dash-bootstrap-components \
    ruamel.yaml \
    gitman \
    pyserial \
    zmq \
    memray

RUN --mount=type=ssh gitman install

# Add autocomplete
RUN echo "\
if ! shopt -oq posix; then \n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then \n\
    . /usr/share/bash-completion/bash_completion \n\
  elif [ -f /etc/bash_completion ]; then \n\
    . /etc/bash_completion \n\
  fi \n\
fi" >> $HOME/.bashrc

RUN echo "export MEAS_DIR=$HOME/measurements" >> $HOME/.bashrc
RUN echo "export MEAS_INT=10000" >> $HOME/.bashrc

RUN mkdir status
COPY ./overrides/experiment_number.txt /root/OrangeBox/status/experiment_number.txt
COPY ./overrides/orange_box.config /root/OrangeBox/config/orange_box.config


CMD /bin/bash
