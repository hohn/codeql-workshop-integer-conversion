FROM debian

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison curl unzip

RUN useradd -ms /bin/bash codeql
USER codeql
WORKDIR /home/codeql

RUN git clone --no-checkout https://github.com/torvalds/linux.git
RUN cd linux && git checkout v5.12 && make tinyconfig

RUN curl -L https://github.com/github/codeql-cli-binaries/releases/download/v2.12.6/codeql-linux64.zip -o codeql.zip && unzip codeql.zip
ENTRYPOINT ["/home/codeql/codeql/codeql"]