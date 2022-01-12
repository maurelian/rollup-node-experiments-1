#!/bin/sh

cd ./optimistic-specs
go mod download
go build -o rollupnode ./opnode/cmd
mv rollupnode ..
cd ..
