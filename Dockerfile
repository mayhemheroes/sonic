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
RUN AFL_INSTRUMENT=1 make

## Build out corpus
WORKDIR /
RUN git clone https://github.com/dvyukov/go-fuzz-corpus.git
RUN mkdir /corpus
RUN cp /sonic/samples/*.wav /corpus
RUN cp go-fuzz-corpus/elf/* /corpus

ENTRYPOINT ["afl-fuzz", "-i", "/corpus", "-o", "/out"]
CMD ["/sonic/sonic", "-c", "-p", "2", "-r", "2", "-s", "1.3", "-v", "2", "@@", "/dev/null"]
