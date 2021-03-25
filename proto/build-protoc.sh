#!/bin/bash

# clean folder
function clean() {
    rm -Rf dist/*
    rm -rf "$(ls src)" | xargs -n 1
}

# build protoc
function build() {
    clean
    mkdir -p ./dist/go ./dist/js ./dist/php ./dist/ruby ./dist/swift

    proto_files=$(find src | grep proto)

    # generate go
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include \
            --go_out=plugins=grpc:./dist/go \
            --validate_out="lang=go:./dist/go" \
            "${proto}"
    done

    # start move go files, to github import path
    mv ./dist/go/"${go_package}"/dist/go/* ./dist/go
    rm -rf ./dist/go/github.com
    # end

    # generate js
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include "${proto}" \
            --js_out=import_style=commonjs:./dist/js \
            --grpc-web_out=import_style=commonjs,mode=grpcwebtext:./dist/js \
            --ts_out=./dist/js
    done

    # generate php
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include \
            --php_out=./dist/php \
            --plugin=protoc-gen-grpc=/usr/local/bin/grpc_php_plugin \
            --grpc_out=./dist/php \
            "${proto}"
    done

    # generate ruby
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include "${proto}" \
            --ruby_out=./dist/ruby \
            --plugin=protoc-gen-grpc=/usr/local/bin/grpc_ruby_plugin \
            --grpc_out=./dist/ruby
    done

    # generate swift
    for proto in $proto_files; do
        protoc -I=/opt/include -I=src/ \
            --swift_opt=Visibility=Public \
            --swift_out=./dist/swift \
            --grpc-swift_opt=Visibility=Public \
            --grpc-swift_opt=Client=true \
            --grpc-swift_opt=Server=false \
            --grpc-swift_out=./dist/swift \
            "${proto}"
    done

    #document
    proto_file_src=""
    for proto in $proto_files; do
        proto_file_src+=" ""${proto}"
    done
    protoc -I=src/ -I=/opt/include --doc_out=./docs/ --doc_opt=markdown.tmpl,doc.md "${proto_file_src}"
}

if [ "${1}" == "build" ]; then
    go_package="${2}"
    build
elif [ "${1}" == "clean" ]; then
    clean
fi

echo "done"
exit 0
