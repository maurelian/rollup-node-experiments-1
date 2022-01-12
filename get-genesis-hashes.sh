#!/bin/sh

curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x0", false],"id":1}' \
  http://localhost:8545 \
  | jq -r ".result.hash" \
  | tee l1_genesis_hash.txt



curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x0", false],"id":1}' \
  http://localhost:9000 \
  | jq -r ".result.hash" \
  | tee l2_genesis_hash.txt
