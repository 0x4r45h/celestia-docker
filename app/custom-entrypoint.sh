#!/bin/bash

set -e

_init_p2p() {
    cd $HOME
    rm -rf networks
    rm -f $HOME/.celestia-app/config/genesis.json
    git clone https://github.com/celestiaorg/networks.git
    celestia-appd init "$CELESTIA_NODE_NAME" --chain-id mamaki
    cp $HOME/networks/mamaki/genesis.json $HOME/.celestia-app/config
    if [ -z "${BOOTSTRAP_PEERS}" ]; then
       BOOTSTRAP_PEERS=$(curl -s https://rpc-mamaki.pops.one/net_info | jq -r '.result.peers[] | .url + ","' | tr -d '\n' | sed 's/.$//')
    fi
    echo $BOOTSTRAP_PEERS
    sed -i.bak -e "s/^bootstrap-peers *=.*/bootstrap-peers = \"$BOOTSTRAP_PEERS\"/" $HOME/.celestia-app/config/config.toml
    # Configure validator mode
    sed -i.bak -e "s/^mode *=.*/mode = \"validator\"/" $HOME/.celestia-app/config/config.toml

}
_config_pruning() {
  PRUNING="custom"
  PRUNING_KEEP_RECENT="100"
  PRUNING_INTERVAL="10"

  sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.celestia-app/config/app.toml
  sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
    \"$PRUNING_KEEP_RECENT\"/" $HOME/.celestia-app/config/app.toml
  sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
    \"$PRUNING_INTERVAL\"/" $HOME/.celestia-app/config/app.toml
}
_download_snapshot() {
  cd $HOME
  rm -rf ~/.celestia-app/data
  mkdir -p ~/.celestia-app/data
  SNAP_NAME=$(curl -s https://snaps.qubelabs.io/celestia/ |
    egrep -o ">mamaki.*tar" | tr -d ">")
  wget -O - https://snaps.qubelabs.io/celestia/${SNAP_NAME} | tar xf - \
    -C ~/.celestia-app/data/
}
_init_wallet() {
    celestia-appd config keyring-backend test
    while true; do
        read -p "Did you want to import a previously created wallet? " yn
        case $yn in
            [Yy]* ) celestia-appd keys add $VALIDATOR_WALLET_NAME --recover; break;;
            [Nn]* ) celestia-appd keys add $VALIDATOR_WALLET_NAME; break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    echo "celesvaloper address : "
    celestia-appd keys show $VALIDATOR_WALLET_NAME --bech val -a
}
_get_wallet_balance() {
    celestia-appd start > /dev/null 2>&1 &
    echo "waiting for connection ..." && sleep 2
    celestia-appd query bank balances $WALLET_ADDRESS
}
_validator_connect() {

    celestia-appd tx staking create-validator \
      --amount=1000000utia \
      --pubkey=$(celestia-appd tendermint show-validator) \
      --moniker=$MONIKER \
      --chain-id=mamaki \
      --commission-rate=0.1 \
      --commission-max-rate=0.2 \
      --commission-max-change-rate=0.01 \
      --min-self-delegation=1000000 \
      --from=$VALIDATOR_WALLET_NAME \
      --keyring-backend=test
}

_init() {
    _init_p2p
    _config_pruning
    _init_wallet
while true; do
    read -p "Did you made a backup from your mnemonic keys? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Please, store it in a safe place then type yes";;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Do you want to download the latest snapshot? " yn
    case $yn in
        [Yy]* ) _download_snapshot; break;;
        [Nn]* ) exit ;;
        * ) echo "Please answer yes or no.";;
    esac
done


}
if [ "$1" = 'debug' ]; then
  trap : TERM INT; sleep infinity & wait
elif [ "$1" = 'init' ]; then
_init
elif [ "$1" = 'wallet:balance' ]; then
_get_wallet_balance
elif [ "$1" = 'validator:connect' ]; then
_validator_connect
else
  /bin/celestia-appd $@
fi
