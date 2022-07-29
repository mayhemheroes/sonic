# Build Stage
FROM aflplusplus/aflplusplus as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git make

## Add source code to the build stage.
WORKDIR /
ADD . /sonic
WORKDIR /sonic

## Build
RUN BUILD_FUZZ=1 make

## Generate test corpus
RUN mkdir /tests && echo seed > /tests/seed

## Package Stage
FROM aflplusplus/aflplusplus 
COPY --from=builder /sonic/sonic /sonic

RUN mkdir -p /tests && echo seed > /tests/seed
ENTRYPOINT ["afl-fuzz", "-i", "/tests", "-o", "/out"]
CMD ["/sonic", "@@", "/dev/null"]
