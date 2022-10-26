#!/bin/bash

# clean folder
function clean {
    rm -Rf dist/*
    rm -rf "$(ls src)" | xargs -n 1
}

function _test {
    echo "  TEST MODE  "
    echo "Create File......"
    TEST_TEMPLATE_PATH=./src/domain/subdomain
    mkdir -p "$TEST_TEMPLATE_PATH"
    cat >"$TEST_TEMPLATE_PATH"/ping.proto <<-EOM
syntax = "proto3";
package domain.subdomain.ping;
option go_package = "github.com/lctech-tw/projectname/dist/go/ping";
service PingServer {
    rpc Ping (PingMessage) returns (PingMessage);
}   
message PingMessage {
    string ping = 1;
    int64 reties = 2;
}
EOM
}

# build protoc
function build {
    clean
    PROGRAMMING_LANGUAGE=("go" "js" "docs" "node" )
    for ((i = 0; i < ${#PROGRAMMING_LANGUAGE[@]}; i++)); do
        mkdir -p ./dist/"${PROGRAMMING_LANGUAGE[i]}"
    done

    proto_files=$(find src -name "*.proto")
    proto_dirs=$(cd ./src && find . -type f -name "*.proto" | sort | uniq)

    echo "🔥 ----- golang -----"
    for proto_dir in $proto_dirs; do
        # proto_file_name=`basename $proto .proto`
        service_dist_name=$(basename "${proto_dir}")
        service_dist="./dist/go/${service_dist_name}"
        mkdir -p "${service_dist}"
        src_proto_files=$(find ./src/"${proto_dir}" -iname "*.proto")
        # descriptor_file="${service_dist}/${service_dist_name}_descriptor.pb"
        # data_proto_dir=$(echo ${proto_dir} | sed -e 's/admin/data/g')
        # external_proto_files=$(find ./external/${data_proto_dir} -iname "*.proto" 2> /dev/null)
        # proto_file_all=("${src_proto_files[@]}" "${external_proto_files[@]}")
        proto_file_all=("${src_proto_files[@]}")
        # echo "PROTO_FILE_ALL: ${proto_file_all[*]}"
        protoc -I=src/ -I=/opt/include \
            --go_out=plugins=grpc:./dist/go \
            --validate_out="lang=go:./dist/go" \
            --include_imports \
            --descriptor_set_out="${service_dist}"/api_descriptor.pb \
            "${proto_file_all[@]}"
    done

    # start move go files, to github import path
    # rsync -a ./dist/go/"${go_package}"/dist/go/ ./dist/go/
    (cd ./dist/go/"${go_package}"/dist/go && tar c .) | (cd ./dist/go && tar xf -)
    rm -rf ./dist/go/"${go_package}"/dist/go/

    echo "🔥 ----- grpc-web-javascript -----"
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include "${proto}" \
            --js_out=import_style=commonjs:./dist/js \
            --grpc-web_out=import_style=commonjs,mode=grpcwebtext:./dist/js/ \
            --ts_out=./dist/js
    done

    echo "🔥 ----- grpc-web-typescript -----"
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include "${proto}" \
            --grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:./dist/js/
    done

    # echo "🔥 ----- php -----"
    # for proto in $proto_files; do
    #     protoc -I=/opt/include -I=src/ \
    #         --php_out=./dist/php \
    #         --plugin=protoc-gen-grpc=/usr/local/bin/grpc_php_plugin \
    #         --grpc_out=./dist/php \
    #         "${proto}"
    # done

    # echo "🔥 ----- ruby -----"
    # for proto in $proto_files; do
    #     protoc -I=/opt/include -I=src/ \
    #         --ruby_out=./dist/ruby \
    #         --plugin=protoc-gen-grpc=/usr/local/bin/grpc_ruby_plugin \
    #         --grpc_out=./dist/ruby \
    #         "${proto}"
    # done

    # echo "🔥 ----- swift -----"
    # for proto in $proto_files; do
    #     protoc -I=/opt/include -I=src/ \
    #         --swift_opt=Visibility=Public \
    #         --swift_out=./dist/swift \
    #         --grpc-swift_opt=Visibility=Public \
    #         --grpc-swift_opt=Client=true \
    #         --grpc-swift_opt=Server=false \
    #         --grpc-swift_out=./dist/swift \
    #         "${proto}"
    # done

    # echo "🔥 ----- python -----"
    # for proto in $proto_files; do
    #     protoc -I=/opt/include -I=src/ \
    #         --python_out=./dist/python \
    #         "${proto}"
    # done

    # echo "🔥 ----- c# -----"
    # for proto in $proto_files; do
    #     protoc -I=/opt/include -I=src/ \
    #         --csharp_out=./dist/csharp \
    #         "${proto}"
    # done

    # document
    echo "🔥 ----- document -----"
    for proto in $proto_files; do
        proto_file_src="${proto/"src/"/}"
        proto_file_outfile_name="${proto_file_src/"/"/"."}"
        echo $proto_file_outfile_name
        protoc -I=src/ -I=/opt/include --doc_out=./dist/docs/ --doc_opt=markdown,"$proto_file_outfile_name".md "${proto_file_src}"
    done
}

# help
function _help() {
    cat >&2 <<"EOF"
Description:
  This is LCTECH's develop PROTO3 util .
FLAG:
    build
    test
    help
    clean
EOF
    exit 0
}

# main
if [ "${1}" == "build" ]; then
    go_package="${2}"
    build
elif [ "${1}" == "clean" ]; then
    clean
elif [ "${1}" == "test" ]; then
    _test
elif [[ "${1}" == '-h' || "${1}" == '--help' ]]; then
    _help
else
    _help
fi

echo "🦅 ----- Done -----"
exit 0
