FROM alpine:3
WORKDIR /go/src/app
RUN apk add --no-cache ca-certificates libc6-compat && update-ca-certificates
LABEL maintainer="LCTECH" image.authors="LCTECH"
COPY ./cmd/server/server ./cmd/server/server
CMD ["/go/src/app/cmd/server/server"]
