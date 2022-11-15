# Celestia Dockerized

### Requirements
- Docker and Docker Compose (Tested on Linux only)

### Quick setup
to run a validator clone this repo on server and cd into it

copy environment file sample to .env and set your configs, if you don't have a wallet already just skip the wallet address for now.
```shell
cp .env.sample .env
```
### Initialize configs
```shell
docker compose run --rm validator init
```

### Request test token
set your wallet address from previous into .env file , then head to discord and get your test tokens.

### Run the validator instance

```shell
docker compose up -d 
```
wait for your validator to catch up with the rest of network before you proceeding. you can check validator's current info by running this:
```shell
docker compose exec validator /opt/helpers.sh validator:sync-info
```
### Create Validator

```shell
docker compose exec validator /opt/helpers.sh validator:connect
```


