#!/bin/sh
#
# Just recording how the grpc client/server files were generated.  Not sure where it should live yet.
# Probably in the Rakefile...
#
protoc -I protos --ruby_out=lib --grpc_out=lib --plugin=protoc-gen-grpc=`which grpc_ruby_plugin` robot.proto
