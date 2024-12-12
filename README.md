# Install solana cli (MacOs)
```agsl
sh -c "$(curl -sSfL https://release.anza.xyz/v2.1.5/install)"
```

```agsl
solana --version
```

## For other platform please follow official solana cli documentation.
*https://docs.anza.xyz/cli/install/*


# Script prerequisites
```agsl
apt install jq bc sudo dialog gettext-base gpg
```
## Install telegraf
```
https://docs.influxdata.com/telegraf/v1/install/
```

## Generate monitor script and telegraf config
```agsl
cd scripts
chmod +x generate.sh
./generate.sh
```
