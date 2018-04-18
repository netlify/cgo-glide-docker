FROM ubuntu:14.04

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y build-essential autoconf automake libtool pkg-config libssl-dev tcl-dev libexpat1-dev \
                       git-core libpcre3-dev libcap-dev libcap2 libboost-all-dev bison flex curl wget \
                       tmux gdb valgrind awscli man python-magic checkinstall libunwind8-dev \
                       libjsoncpp-dev libb64-dev


RUN cd /opt && wget https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz && \
    tar xf cmake-3.9.0.tar.gz && cd cmake-3.9.0 && ./configure && make && make install


RUN cd /opt && git clone https://code.googlesource.com/re2 && cd re2 && git checkout 2018-02-01 && \
    make install && ldconfig

ENV GOLANG_VERSION 1.9.5

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='d21bdabf4272c2248c41b45cec606844bdc5c7c04240899bde36c01a28c51ee7' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='e9b6f0cbd95ff3077ddeaec1958be77d9675f0cf5652a67152d28d84707a4e9e' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='d0bb265559cd8613882e6bbd197a80ed7090684117c6fc6900aa58dea2463715' ;; \
		i386) goRelArch='linux-386'; goRelSha256='52e0e3421ac4d9b8d8c89121ea93e5e3180a26679a8ea64ecbeb3657251634a3' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='dfd928ab818f72b801273c669d86e6c05626f2c2addc1c7178bb715fc608daf2' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='82c86885c8cc4d62ff81f828529c72cacd0ca8b02d442dc659858c6738363775' ;; \
		*) goRelArch='src'; goRelSha256='f1c2bb7f32bbd8fa7a19cc1608e0d06582df32ff5f0340967d83fb0017c49fbc'; \
			echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
	esac; \
	\
	url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
	wget -O go.tgz "$url"; \
	echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	if [ "$goRelArch" = 'src' ]; then \
		echo >&2; \
		echo >&2 'error: UNIMPLEMENTED'; \
		echo >&2 'TODO install golang-any from jessie-backports for GOROOT_BOOTSTRAP (and uninstall after build)'; \
		echo >&2; \
		exit 1; \
	fi; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

ENV GLIDE_VERSION v0.13.1
ENV GLIDE_DOWNLOAD_URL https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz
ENV GLIDE_DOWNLOAD_SHA256 c403933503ea40308ecfadcff581ff0dc3190c57958808bb9eed016f13f6f32c

ENV PATH $PATH:/usr/local/glide/linux-amd64

RUN curl -fsSL "$GLIDE_DOWNLOAD_URL" -o glide.tar.gz \
	&& echo "$GLIDE_DOWNLOAD_SHA256  glide.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/glide \
	&& tar -C /usr/local/glide -xzf glide.tar.gz \
	&& rm glide.tar.gz
