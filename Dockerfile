FROM docker.io/ubuntu:16.04
MAINTAINER Dobashi, Hiroki <hiroki.dobashi@gmail.com>

RUN echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends \
 && sed -i'~' -E "s@http://(..\.)?(archive|security)\.ubuntu\.com/ubuntu@http://ftp.jaist.ac.jp/pub/Linux/ubuntu@g" /etc/apt/sources.list

RUN apt-get update && apt-get install -y software-properties-common \
 && add-apt-repository ppa:git-core/ppa

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y curl git sudo net-tools build-essential ca-certificates unzip \
      perl libio-socket-ssl-perl \
 && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
 && rm -rf /var/lib/apt/lists/*

# ------
ENV APP_HOME=/home/app
RUN echo 'proxy = proxy:8080' > ~/.curlrc
RUN curl -L https://cpanmin.us | perl - App::cpanminus

WORKDIR ${APP_HOME}
COPY cpanfile ${APP_HOME}/cpanfile
RUN cpanm --installdeps .

COPY cleaner.pl ${APP_HOME}/cleaner.pl
RUN mkdir -p ${APP_HOME}/log

CMD ["perl", "cleaner.pl"]
