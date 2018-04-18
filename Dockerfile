FROM golang:1.10.1-alpine3.7 as builder

ENV CGO_ENABLED=0
WORKDIR /go/src/github.com/kron4eg/reviewdrone

RUN apk add --no-cache upx git curl
RUN go get -v -u gopkg.in/alecthomas/gometalinter.v2 && \
    mv /go/bin/gometalinter.v2 /go/bin/gometalinter
RUN gometalinter --install
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

ADD . /go/src/github.com/kron4eg/reviewdrone

RUN dep ensure -v -vendor-only
RUN go install -v ./vendor/github.com/haya14busa/reviewdog/cmd/reviewdog
RUN go install -v
RUN upx /go/bin/*

FROM golang:1.10.1-alpine3.7
COPY --from=builder /go/bin/* /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/reviewdrone"]
