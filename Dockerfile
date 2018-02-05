FROM golang:1.9.3-stretch

ENV GLIDE_VERSION v0.13.0
ENV GLIDE_DOWNLOAD_URL https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz
ENV GLIDE_DOWNLOAD_SHA256 77680bbd9e51de9a5cbd212f4d0aab51abac49971695f0bc779b117f8cb188ff

ENV PATH $PATH:/usr/local/glide/linux-amd64

RUN curl -fsSL "$GLIDE_DOWNLOAD_URL" -o glide.tar.gz \
	&& echo "$GLIDE_DOWNLOAD_SHA256  glide.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/glide \
	&& tar -C /usr/local/glide -xzf glide.tar.gz \
	&& rm glide.tar.gz

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y build-essential autoconf automake libtool pkg-config libssl-dev tcl-dev libexpat1-dev \
                       git-core libpcre3-dev libcap-dev libcap2 libboost-all-dev bison flex curl wget \
                       tmux gdb valgrind awscli man python-magic checkinstall libunwind8-dev \
                       libjsoncpp-dev libb64-dev

RUN cd /opt && wget https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz && \
    tar xf cmake-3.9.0.tar.gz && cd cmake-3.9.0 && ./configure && make && make install

RUN cd /opt && git clone https://code.googlesource.com/re2 && cd re2 && git checkout 2016-09-01 && \
    make install && ldconfig
