FROM alpine:3
LABEL maintainer LCTECH
WORKDIR /go/src/app
RUN apk add --no-cache ca-certificates && \
    update-ca-certificates
COPY ./cmd/server/server ./cmd/server/server
CMD ["/go/src/app/cmd/server/server"]
