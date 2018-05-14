FROM alpine as builder

LABEL version="0.1"

RUN apk --no-cache add \
        binutils \
        build-base \
        git \
        ncurses-dev \
        openssl-dev \
        readline-dev \
    && apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    && mkdir /usr/local/src
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so
WORKDIR /usr/local/src
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git
WORKDIR /usr/local/src/SoftEtherVPN_Stable
RUN git checkout tags/v4.25-9656-rtm

RUN ./configure && make


FROM alpine
RUN apk update && apk add readline \
        openssl &&\
        apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so
WORKDIR /root/
VOLUME /mnt
RUN ln -s /mnt/vpn_server.config vpn_server.config && \
        mkdir /mnt/backup.vpn_server.config &&\
        ln -s /mnt/backup.vpn_server.config backup.vpn_server.config &&\
        ln -s /mnt/lang.config lang.config
COPY --from=builder /usr/local/src/SoftEtherVPN_Stable/bin/vpnserver .
CMD ["/root/vpnserver", "execsvc"]
