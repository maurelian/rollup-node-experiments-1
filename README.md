# rollup node experiments

Test scripts etc. for experimental rollup testing.

*untested, work in progress*

## Config preparation

Change `rollup.yaml` for custom premine / testnet ID / L1 clique signers.

### Optional: recompile system contracts bytecode.

Compile and fetch deployed bytecode, to embed in local testnet genesis states.
```shell
cd ../optimistic-specs/packages/contracts
yarn build
cat artifacts/contracts/L2/L1Block.sol/L1Block.json | jq -r .deployedBytecode > ../../../rollup-node-experiments/bytecode_l2_l1block.txt
cat artifacts/contracts/L1/DepositFeed.sol/DepositFeed.json | jq -r .deployedBytecode > ../../../rollup-node-experiments/bytecode_l1_depositfeed.txt
```

### generate configs

Build the L1 and L2 chain genesis configurations:
```shell
python -m venv venv
source venv/bin/activate

# generate a `l1_genesis.json` and `l2_genesis.json` for local L1 and L2 geth instances
python gen_confs.py
```

## Node setup

### L1 setup

```shell
# install upstream geth:
go install github.com/ethereum/go-ethereum/cmd/geth@v1.10.15

# Create L1 data dir
geth init --datadir data_l1 l1_genesis.json

# Run L1 geth
geth --datadir data_l1 \
    --networkid 900 \
    --http --http.api "net,eth,consensus" \
    --http.port 8545 \
    --http.addr 127.0.0.1 \
    --http.corsdomain "*" \
    --ws --ws.api "net,eth,consensus" \
    --ws.port=8546 \
    --ws.addr 0.0.0.0 \
    --maxpeers=0 \
    --vmodule=rpc=5

# Get the genesis block hash (while running the above command)
curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x0", false],"id":1}' http://localhost:8545 | jq -r ".result.hash" | tee l1_genesis_hash.txt

# shut down geth again

# Import the clique signer secret key into geth
echo -n "foobar" > signer_password.txt
geth --datadir data_l1 account import --password=signer_password.txt signer_0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0

# Then, restart with block production enabled:
geth --datadir data_l1 \
    --networkid 900 \
    --http --http.api "net,eth,consensus" \
    --http.port 8545 \
    --http.addr 127.0.0.1 \
    --http.corsdomain "*" \
    --ws --ws.api "net,eth,consensus" \
    --ws.port=8546 \
    --ws.addr 0.0.0.0 \
    --maxpeers=0 \
    --vmodule=rpc=5 \
    --allow-insecure-unlock --unlock 0x30eC912c5b1D14aa6d1cb9AA7A6682415C4F7Eb0 \
    --password=signer_password.txt --mine
```

### L2 exec-engine setup

With  `optimism-prototype` branch:

```shell
# Prepare L2 binary (or `go run` directly from source instead)
git clone --branch optimism-prototype https://github.com/ethereum-optimism/reference-optimistic-geth
cd reference-optimistic-geth
go mod download
go build -o refl2geth ./cmd/geth
mv refl2geth ../rollup-node-experiments/
cd ../rollup-node-experiments/

# Create L2 data dir
./refl2geth init --datadir data_l2 l2_genesis.json

# Run L2 geth
# Important: expose engine RPC namespace and activate the merge functionality.
./refl2geth --datadir data_l2 \
    --networkid 901 --catalyst \
    --http --http.api "net,eth,consensus,engine" \
    --http.port 9000 \
    --http.addr 127.0.0.1 \
    --http.corsdomain "*" \
    --ws --ws.api "net,eth,consensus,engine" \
    --ws.port=9001 \
    --ws.addr 0.0.0.0 \
    --port=30304 \
    --nat=none \
    --maxpeers=0 \
    --vmodule=rpc=5
# TODO: remove maxpeers=0 and --nat=none if testing with more local nodes


curl -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x0", false],"id":1}' http://localhost:9000 | jq -r ".result.hash" | tee l2_genesis_hash.txt
```

### Rollup-node setup

```shell
# Prepare rollup-node binary (or `go run` directly from source instead)
git clone --branch l2-tracking https://github.com/ethereum-optimism/optimistic-specs
cd optimistic-specs
go mod download
go build -o rollupnode ./opnode/cmd
mv rollupnode ../rollup-node-experiments/
cd ../rollup-node-experiments/

rollupnode run \
 --l1=http://localhost:8545 \
 --l2=http://localhost:9000 \
 --log.level=debug \
 --genesis.l1-hash=$(cat l1_genesis_hash.txt) \
 --genesis.l1-num=0 \
 --genesis.l2-hash=$(cat l2_genesis_hash.txt)
```

## License

MIT, see [`LICENSE`](./LICENSE) file.

