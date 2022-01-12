#!/bin/sh

cd ./reference-optimistic-geth
go mod download
go build -o refl2geth ./cmd/geth
mv refl2geth ..
cd ..

# Create L2 data dir
./refl2geth init --datadir data_l2 l2_genesis.json
