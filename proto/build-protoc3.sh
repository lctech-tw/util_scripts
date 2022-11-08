#!/bin/bash

# clean folder
function clean {
    rm -Rf dist/*
    rm -rf "$(ls src)" | xargs -n 1
}

# build protoc
function build {
    clean
    mkdir -p ./dist/external ./dist/go ./temp_proto/go ./dist/js ./dist/php ./dist/ruby ./dist/swift ./dist/docs ./dist/node ./dist/python ./dist/csharp
    
    ls -lha

    proto_files=$(find src | grep proto)
    proto_dirs=$((cd ./src && find . -type f -name "*.proto") | xargs -I{} dirname {} | sort | uniq)
    echo "🔥 ----- golang -----"
    for proto_dir in $proto_dirs; do
      service_dist="./dist/go/${proto_dir}_proto"
      mkdir -p ${service_dist}
      src_proto_files=$(find ./src/${proto_dir} -iname "*.proto")
      proto_file_all=("${src_proto_files[@]}")
      protoc -I=src/ -I=/opt/include \
        -I=external/ \
        --go_out=plugins=grpc:./dist/go \
        --validate_out="lang=go:./dist/go" \
        --include_imports \
        --descriptor_set_out=${service_dist}/api_descriptor.pb \
        ${proto_file_all[@]}
    done

    # start move go files, to github import path
    (cd ./dist/go/"${go_package}"/dist/go && tar c .) | (cd ./dist/go && tar xf -)
    echo "Remove ./dist/go/${go_package}"
    rm -rf ./dist/go/"${go_package}"

    echo "🔥 ----- javascript -----"
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include "${proto}" \
            -I=external/ \
            --js_out=import_style=commonjs:./dist/js \
            --grpc-web_out=import_style=commonjs,mode=grpcwebtext:./dist/js/ \
            --ts_out=./dist/js
    done

    echo "🔥 ----- typescript -----"
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include "${proto}" \
            -I=external/ \
            --grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:./dist/js/
    done

    echo "🔥 ----- php -----"
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include \
            -I=external/ \
            --php_out=./dist/php \
            --plugin=protoc-gen-grpc=/usr/local/bin/grpc_php_plugin \
            --grpc_out=./dist/php \
            "${proto}"
    done

    echo "🔥 ----- ruby -----"
    for proto in $proto_files; do
        protoc -I=src/ -I=/opt/include "${proto}" \
            -I=external/ \
            --ruby_out=./dist/ruby \
            --plugin=protoc-gen-grpc=/usr/local/bin/grpc_ruby_plugin \
            --grpc_out=./dist/ruby
    done

    echo "🔥 ----- swift -----"
    for proto in $proto_files; do
        protoc -I=/opt/include -I=src/ \
            -I=external/ \
            --swift_opt=Visibility=Public \
            --swift_out=./dist/swift \
            --grpc-swift_opt=Visibility=Public \
            --grpc-swift_opt=Client=true \
            --grpc-swift_opt=Server=false \
            --grpc-swift_out=./dist/swift \
            "${proto}"
    done

    echo "🔥 ----- python -----"
    for proto in $proto_files; do
        protoc -I=/opt/include -I=src/ \
            -I=external/ \
            --python_out=./dist/python \
            "${proto}"
    done

    echo "🔥 ----- c# -----"
    for proto in $proto_files; do
        protoc -I=/opt/include -I=src/ \
            -I=external/ \
            --csharp_out=./dist/csharp \
            "${proto}"
    done

    # document
    echo "🔥 ----- document -----"
    for proto in $proto_files; do
        proto_file_src="${proto/"src/"/}"
        protoc -I=src/ -I=/opt/include -I=external/ --doc_out=./dist/docs/  --doc_opt=markdown,$proto.md "${proto_file_src}"
    done
}

if [ "${1}" == "build" ]; then
    go_package="${2}"
    build
elif [ "${1}" == "clean" ]; then
    clean
fi

proto_files=$(find src -name "*.proto")

echo "💩 ----- [external] -----"

echo "----- javascript [external] -----"
for proto in $proto_files; do
    protoc -I=src/ -I=/opt/include "${proto}" \
        -I=external/ \
        --js_out=import_style=commonjs:./dist/js \
        --grpc-web_out=import_style=commonjs,mode=grpcwebtext:./dist/js/ \
        --ts_out=./dist/js
done

echo "----- typescript [external] -----"
for proto in $proto_files; do
    protoc -I=src/ -I=/opt/include "${proto}" \
        -I=external/ \
        --grpc-web_out=import_style=commonjs+dts,mode=grpcwebtext:./dist/js/
done

echo "🦅 ----- Done -----"
exit 0
