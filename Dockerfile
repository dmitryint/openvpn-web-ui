FROM golang:1.13-stretch as beego_build

RUN go get github.com/beego/bee && \
    go get github.com/astaxie/beego

COPY . /go/src/github.com/adamwalach/openvpn-web-ui

WORKDIR /go/src/github.com/adamwalach/openvpn-web-ui
RUN bee version \
    && bee pack -exr='^vendor|^data.db|^build|^README.md|^docs'


FROM debian:jessie
WORKDIR /opt
EXPOSE 8080

RUN apt-get update && apt-get install -y easy-rsa
RUN chmod 755 /usr/share/easy-rsa/*
COPY build/assets/start.sh /opt/start.sh
COPY build/assets/generate_ca_and_server_certs.sh /opt/scripts/generate_ca_and_server_certs.sh
COPY build/assets/vars.template /opt/scripts/

COPY --from=beego_build /go/src/github.com/adamwalach/openvpn-web-ui/openvpn-web-ui.tar.gz /opt/openvpn-gui/
RUN cd /opt/openvpn-gui/ \
    && tar -xf openvpn-web-ui.tar.gz
COPY build/assets/app.conf /opt/openvpn-gui/conf/app.conf

CMD /opt/start.sh
