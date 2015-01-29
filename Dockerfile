# Nuxeo IO Base image to run a nuxeo instance
#
# VERSION               0.0.1

FROM       quay.io/nuxeoio/iobase
MAINTAINER Nuxeo <contact@nuxeo.com>

# Small trick to Install fuse(libreoffice dependency) because of container permission issue.
RUN apt-get -y install fuse || true
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get -y install fuse


# Create Nuxeo user
RUN useradd -m -d /home/nuxeo -p nuxeo nuxeo && adduser nuxeo sudo && chsh -s /bin/bash nuxeo
ENV NUXEO_USER nuxeo
ENV NUXEO_HOME /var/lib/nuxeo/server
ENV NUXEOCTL /var/lib/nuxeo/server/bin/nuxeoctl

RUN sudo apt-get install -y \
    openjdk-7-jdk \
    perl \
    locales \
    pwgen \
    imagemagick \
    ffmpeg2theora \
    libfaac-dev \
    ufraw \
    poppler-utils \
    libreoffice \
    libwpd-tools \
    gimp \
    exiftool \
    ghostscript

WORKDIR /tmp
ENV BUILD_YASM true

# Build ffmpeg
RUN git clone https://github.com/nuxeo/ffmpeg-nuxeo.git && \
    cd ffmpeg-nuxeo
ENV LIBFAAC true
RUN ./prepare-packages.sh && ./build-yasm.sh
RUN ./build-x264.sh && ./build-libvpx.sh
RUN ./build-ffmpeg.sh
RUN cd .. && \
    rm -Rf ffmpeg-nuxeo

# Expose default Tomcat and SSH ports
EXPOSE 8080
