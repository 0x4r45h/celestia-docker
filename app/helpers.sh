#!/bin/bash

set -e

_get_wallet_balance() {
  celestia-appd query bank balances $WALLET_ADDRESS
}
_validator_connect() {
  # Configure validator mode
  sed -i.bak -e "s/^mode *=.*/mode = \"validator\"/" $HOME/.celestia-app/config/config.toml

  celestia-appd tx staking create-validator \
    --amount=1000000utia \
    --pubkey="$(celestia-appd tendermint show-validator)" \
    --moniker=$MONIKER \
    --chain-id=mocha \
    --evm-address=$EVM_ADDRESS \
    --orchestrator-address=$ORCHESTRATOR_ADDRESS \
    --commission-rate=0.1 \
    --commission-max-rate=0.2 \
    --commission-max-change-rate=0.01 \
    --min-self-delegation=1000000 \
    --from=$VALIDATOR_WALLET_NAME \
    --keyring-backend=test
}

if [ "$1" = 'wallet:balance' ]; then
  _get_wallet_balance
elif [ "$1" = 'validator:connect' ]; then
  _validator_connect
elif [ "$1" = 'validator:sync-info' ]; then
  curl -s localhost:26657/status | jq .result | jq .sync_info
else
  /bin/celestia-appd "$@"
fi
