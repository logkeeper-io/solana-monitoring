# Compatibility

## Supported Platforms

| Platform          | Supported Versions      | Notes                           |
|-------------------|-------------------------|---------------------------------|
| **Operating System** | Linux Ubuntu            | Ensure required dependencies are installed for each OS |

## Dependencies

| Dependency       | Supported Versions | Notes                                           |
|------------------|--------------------|-------------------------------------------------|
| **solana**       | 2.1.5              | Lower versions not supported                    |
| **bc**           | all                |                                                 |
| **jq**           | all                | Test with v4.x, should work with newer versions |
| **dialog**       | 1.3+               | Test with latest stable release                 |
| **gettext-base** | 0.21               | Use with PostgreSQL 12 or later                 |
| **sudo**         | all                | Use with PostgreSQL 12 or later                 |


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
