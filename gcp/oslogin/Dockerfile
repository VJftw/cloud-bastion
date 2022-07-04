FROM debian:buster

RUN apt-get update && \
    apt-get install -y \
    openssh-server \
    google-compute-engine-oslogin

CMD [ "/sbin/init" ]
