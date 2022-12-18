# Celestia Dockerized

### Requirements
- Docker and Docker Compose (Tested on Linux only)

## Validator
to run a validator clone this repo on server and cd into it

copy environment file sample to .env and set your configs, if you don't have a wallet already just skip the wallet address for now.
```shell
cp .env.sample .env
```
### Build Images
```shell
docker compose pull & docker compose build
```
### Initialize configs
```shell
docker compose run --rm validator init
```

### Request test token
set your wallet address from previous into .env file , then head to discord and get your test tokens.

### Run the validator instance

```shell
docker compose up -d validator
```
wait for your validator to catch up with the rest of network before you proceeding. you can check validator's current info by running this:
```shell
docker compose exec validator /opt/helpers.sh validator:sync-info
```
### Create Validator

```shell
docker compose exec validator /opt/helpers.sh validator:connect
```

### Delegate to a Validator
```shell
docker compose exec validator /opt/helpers.sh validator:delegate <celestiavaloper address> <amount>utia
```

## Bridge Node
To run a bridge node alongside your validator, first run the bridge in foreground to initialize required files,a new wallet is generated automatically:
```shell
docker compose up bridge
```
#### Using newly generated account
if you want to stick with generated account, write down mnemonic codes somewhere safe, then cancel the process using `ctrl+c` and run it once again, but this time in background:
```shell
docker compose up -d bridge
```
#### Using same wallet as validator for bridge node
open a new terminal, copy keys from validators volume to host, then copy it to the bridges volume   
```shell
docker cp celestia-docker-validator-1:/root/.celestia-app/keyring-test ./keys-backup
```
```shell
docker cp ./keys-backup/. celestia-docker-bridge-1:/root/.celestia-bridge/keys/keyring-test
```
in `.env` file change `BRIDGE_KEY_RING_ACC_NAME` value same as `VALIDATOR_WALLET_NAME`. kill the foreground bridge process using `ctrl+c` then run a new instance in background
```shell
docker compose up -d bridge
```

