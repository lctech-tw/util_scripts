#!/bin/bash

# build protoc
function _build-plugin {
    mkdir -p ./dist/"node"
    proto_files=$(find src | grep proto)
    mkdir -p ./src/google/protobuf/
    #cp -r /usr/include/google/protobuf/ ./src/google/ 
    echo "🔥 ----- Node -----"
    for proto in $proto_files; do
        protoc-gen-grpc \
            --js_out=import_style=commonjs,binary:./dist/node/ \
            --grpc_out=grpc_js:./dist/node/ \
            --proto_path=src/ \
            --proto_path=/usr/include/ \
            -I=external/ \
            "${proto}"
        protoc-gen-grpc-ts \
            --ts_out=grpc_js:./dist/node/ \
            --proto_path=src/ \
            --proto_path=/usr/include/ \
            -I=external/ \
            "${proto}"
    done
}

# help
function _help() {
    cat >&2 <<"EOF"
Description:
  This is LCTECH's develop PROTO3 util .
FLAG:
    build
    help
EOF
    exit 0
}

# main
if [ "${1}" == "build" ]; then
    go_package="${2}"
    _build-plugin
elif [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
    _help
else
    _help
fi

echo "🦅 ----- Done -----"
exit 0
