FROM ubuntu:14.04

RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y build-essential autoconf automake libtool pkg-config libssl-dev tcl-dev libexpat1-dev \
                       git-core libpcre3-dev libcap-dev libcap2 libboost-all-dev bison flex curl wget \
                       tmux gdb valgrind awscli man python-magic checkinstall libunwind8-dev \
                       libjsoncpp-dev libb64-dev


RUN cd /opt && wget https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz && \
    tar xf cmake-3.9.0.tar.gz && cd cmake-3.9.0 && ./configure && make && make install


RUN cd /opt && git clone https://code.googlesource.com/re2 && cd re2 && git checkout 2016-09-01 && \
    make install && ldconfig

ENV GOLANG_VERSION 1.9.3

RUN set -eux; \
	\
# this "case" statement is generated via "update.sh"
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
		amd64) goRelArch='linux-amd64'; goRelSha256='a4da5f4c07dfda8194c4621611aeb7ceaab98af0b38bfb29e1be2ebb04c3556c' ;; \
		armhf) goRelArch='linux-armv6l'; goRelSha256='926d6cd6c21ef3419dca2e5da8d4b74b99592ab1feb5a62a4da244e6333189d2' ;; \
		arm64) goRelArch='linux-arm64'; goRelSha256='065d79964023ccb996e9dbfbf94fc6969d2483fbdeeae6d813f514c5afcd98d9' ;; \
		i386) goRelArch='linux-386'; goRelSha256='bc0782ac8116b2244dfe2a04972bbbcd7f1c2da455a768ab47b32864bcd0d49d' ;; \
		ppc64el) goRelArch='linux-ppc64le'; goRelSha256='c802194b1af0cd904689923d6d32f3ed68f9d5f81a3e4a82406d9ce9be163681' ;; \
		s390x) goRelArch='linux-s390x'; goRelSha256='85e9a257664f84154e583e0877240822bb2fe4308209f5ff57d80d16e2fb95c5' ;; \
		*) goRelArch='src'; goRelSha256='4e3d0ad6e91e02efa77d54e86c8b9e34fbe1cbc2935b6d38784dca93331c47ae'; \
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

ENV GLIDE_VERSION v0.13.0
ENV GLIDE_DOWNLOAD_URL https://github.com/Masterminds/glide/releases/download/$GLIDE_VERSION/glide-$GLIDE_VERSION-linux-amd64.tar.gz
ENV GLIDE_DOWNLOAD_SHA256 77680bbd9e51de9a5cbd212f4d0aab51abac49971695f0bc779b117f8cb188ff

ENV PATH $PATH:/usr/local/glide/linux-amd64

RUN curl -fsSL "$GLIDE_DOWNLOAD_URL" -o glide.tar.gz \
	&& echo "$GLIDE_DOWNLOAD_SHA256  glide.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/glide \
	&& tar -C /usr/local/glide -xzf glide.tar.gz \
	&& rm glide.tar.gz
