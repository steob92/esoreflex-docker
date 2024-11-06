FROM --platform=$BUILDPLATFORM fedora:39

ARG BUILDPLATFORM=linux/amd64
ARG UID=1000
ARG GID=1000
ARG USER=docker
ARG PASSWORD=password


ENV LC_ALL=C
ENV LANG=C

RUN dnf install -y dnf-plugins-core && \
    dnf update -y && \
    dnf config-manager -y --add-repo=https://ftp.eso.org/pub/dfs/pipelines/repositories/stable/fedora/esorepo.repo
  
COPY install_packages.sh ./install_packages.sh

RUN chmod +x ./install_packages.sh && ./install_packages.sh


RUN dnf install -y novnc git python-websockify tigervnc-server

# Install desktop environment for novnc
RUN dnf groupinstall -y "Xfce Desktop"
# Set as the default desktop environment
RUN echo "PREFERRED=/usr/bin/xfce4-session" > /etc/sysconfig/desktop

RUN dnf clean all


RUN useradd -ms /bin/bash -u $UID $USER
RUN echo "${USER}:${PASSWORD}" | chpasswd
RUN usermod -aG wheel  $USER

COPY ./start_server.sh /home/${USER}/bin/start_server.sh
RUN chmod a+x /home/${USER}/bin/start_server.sh

USER ${USER}
# Create an .Xauthority and .Xsession file
RUN touch /home/${USER}/.Xauthority && touch /home/${USER}/.xauthority \
    && echo "xfce4-session" > /home/${USER}/.Xsession \
    && echo "xfce4-session" > /home/${USER}/.xsession

# Start a novnc server
WORKDIR /home/${USER}


# Setup VNC server
RUN mkdir /home/${USER}/.vnc \
    && echo "${PASSWORD}" | vncpasswd -f > /home/${USER}/.vnc/passwd \
    && chmod 600 /home/${USER}/.vnc/passwd \
    && chown -R ${USER}:${USER} /home/${USER}/.vnc \
    && mkdir /home/${USER}/reflex_rawdata

RUN git clone https://github.com/novnc/noVNC.git

ENV PATH="/home/${USER}/noVNC/utils/:/home/${USER}/bin:${PATH}:"
# Start the server
CMD ["start_server.sh"]