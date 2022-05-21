# Build Stage
FROM aflplusplus/aflplusplus as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git make

## Add source code to the build stage.
WORKDIR /
RUN git clone https://github.com/capuanob/sonic.git
WORKDIR /sonic
RUN git checkout mayhem

## Build
RUN BUILD_FUZZ=1 make

## Generate test corpus
RUN mkdir /tests && echo seed > /tests/seed

ENTRYPOINT ["afl-fuzz", "-i", "/tests", "-o", "/out"]
CMD ["/sonic/sonic", "@@", "/dev/null"]
