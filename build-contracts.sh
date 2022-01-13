#!/bin/sh

echo "cd ./optimistic-specs/packages/contracts"
cd ./optimistic-specs/packages/contracts

echo "yarn"
yarn

echo "yarn build"
yarn build

echo "cat artifacts/contracts/L2/L1Block.sol/L1Block.json | jq -r .deployedBytecode > ../../../bytecode_l2_l1block.txt"
cat artifacts/contracts/L2/L1Block.sol/L1Block.json | jq -r .deployedBytecode > ../../../bytecode_l2_l1block.txt

echo "cat artifacts/contracts/L1/DepositFeed.sol/DepositFeed.json | jq -r .deployedBytecode > ../../../bytecode_l1_depositfeed.txt"
cat artifacts/contracts/L1/DepositFeed.sol/DepositFeed.json | jq -r .deployedBytecode > ../../../bytecode_l1_depositfeed.txt

