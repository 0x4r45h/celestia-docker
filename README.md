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
Initialize bridge node
```shell
docker compose run --rm bridge celestia bridge init && docker compose run --rm bridge celestia bridge start 
```
#### Using newly generated account
if you want to stick with generated account, write down mnemonic codes somewhere safe, then run bridge node in background, otherwise if you want to use validator wallet, skip to next part
```shell
docker compose up -d bridge
```
#### Using same wallet as validator for bridge node
copy keys from validators volume to host, then copy it to the bridges volume   
```shell
docker run --rm \
-v celestia-docker_celestia-app:/src \
-v celestia-docker_celestia-bridge-node:/dst \
busybox sh -c "cp -a /src/keyring-test /dst/keys/"
```
**IMPORTANT** in `.env` file change `BRIDGE_KEY_RING_ACC_NAME` value same as `VALIDATOR_WALLET_NAME`

run bridge node in background 
```shell
docker compose up -d bridge
```

