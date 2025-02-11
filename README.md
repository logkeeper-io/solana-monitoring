# Compatibility

## Supported Platforms

| Platform          | Supported Versions      | Notes                                                                                                                                                                            |
|-------------------|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Operating System** | Linux Ubuntu            | generate.sh script will not work on other Linux distributions. But monitor.sh script itself will work togher with telegraf. (but you have to create it manually from templates.) |

## Dependencies

| Dependency       | Supported Versions | Notes                                           |
|------------------|--------------------|-------------------------------------------------|
| **solana**       | 2.1.5, 2.1.6, 2.1.7, 2.1.8, 2.1.9, 2.0.22       | Lower versions not supported                    |
| **firedancer**   | 0.305.20111 | |
| **bc**           | all                |                                                 |
| **jq**           | all                |  |
| **dialog**       | 1.3+               |                 |
| **gettext-base** | 0.21               |                  |
| **sudo**         | all                |                |


## Known Incompatibilities

- **Older Solana cli Versions**: solana cli versions before 2.1.5 are not supported.

# Installation
## Install solana cli
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
