FROM fedora:39
  

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


RUN useradd -ms /bin/bash docker
RUN echo "docker:password" | chpasswd
RUN usermod -aG wheel docker
COPY ./start_server.sh /home/docker/start_server.sh
RUN chmod a+x /home/docker/start_server.sh

USER docker
# Create an .Xauthority and .Xsession file
RUN touch /home/docker/.Xauthority && touch /home/docker/.xauthority \
    && echo "xfce4-session" > /home/docker/.Xsession \
    && echo "xfce4-session" > /home/docker/.xsession

# Start a novnc server
WORKDIR /home/docker


# Setup VNC server
RUN mkdir /home/docker/.vnc \
    && echo "password" | vncpasswd -f > /home/docker/.vnc/passwd \
    && chmod 600 /home/docker/.vnc/passwd \
    && chown -R docker:docker /home/docker/.vnc \
    && mkdir /home/docker/reflex_rawdata

RUN git clone https://github.com/novnc/noVNC.git


# Start the server
CMD ["/home/docker/start_server.sh"]