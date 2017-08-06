FROM sdhibit/mono:5.0-glibc
MAINTAINER Steve Hibit <sdhibit@gmail.com>

ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm'

ARG MEDIAINFO_VER="0.7.97"
ARG LIBMEDIAINFO_URL="https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VER}/MediaInfo_DLL_${MEDIAINFO_VER}_GNU_FromSource.tar.gz"
ARG MEDIAINFO_URL="https://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VER}/MediaInfo_CLI_${MEDIAINFO_VER}_GNU_FromSource.tar.gz"

#Build libmediainfo
#Install build packages
RUN apk --update upgrade \
 && apk add --no-cache --virtual=build-dependencies \
        g++ \
        gcc \
        git \
        make \
 && apk --update upgrade \
 && apk add --no-cache \
    ca-certificates \
    curl \
    libcurl \
    libmms \
    sqlite \
    sqlite-libs \
    tar \
    unrar \
    xz \
    zlib \
    zlib-dev \
 && mkdir -p /tmp/libmediainfo \
 && mkdir -p /tmp/mediainfo \
 && curl -kL ${LIBMEDIAINFO_URL} | tar -xz -C /tmp/libmediainfo --strip-components=1 \
 && curl -kL ${MEDIAINFO_URL} | tar -xz -C /tmp/mediainfo --strip-components=1 \
 && cd /tmp/mediainfo \
 && ./CLI_Compile.sh \
 && cd /tmp/mediainfo/MediaInfo/Project/GNU/CLI \
 && make install \
 && cd /tmp/libmediainfo \
 && ./SO_Compile.sh \
 && cd /tmp/libmediainfo/ZenLib/Project/GNU/Library \
 && make install \
 && cd /tmp/libmediainfo/MediaInfoLib/Project/GNU/Library \
 && make install \
 && apk del --purge build-dependencies \
 && rm -rf /tmp/*

# Set Sonarr Package Information
ENV PKG_NAME NzbDrone
ENV PKG_VER 2.0
ENV PKG_BUILD 0.4928
ENV APP_BASEURL https://update.sonarr.tv/v2/master/mono
ENV APP_PKGNAME ${PKG_NAME}.master.${PKG_VER}.${PKG_BUILD}.mono.tar.gz
ENV APP_URL ${APP_BASEURL}/${APP_PKGNAME}
ENV APP_PATH /opt/sonarr

# Download & Install Sonarr
RUN mkdir -p ${APP_PATH} \
 && curl -kL ${APP_URL} | tar -xz -C ${APP_PATH} --strip-components=1 

# Create user and change ownership
RUN mkdir /config \
 && addgroup -g 666 -S sonarr \
 && adduser -u 666 -SHG sonarr sonarr \
 && chown -R sonarr:sonarr \
    ${APP_PATH} \
    "/config"

VOLUME ["/config"]

# Default Sonarr server ports
EXPOSE 8989
EXPOSE 9898

WORKDIR ${APP_PATH}

# Add services to runit
ADD sonarr.sh /etc/service/sonarr/run
RUN chmod +x /etc/service/*/run
