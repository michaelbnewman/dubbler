# avacloud-vrf-demo

This follows the [avacloud-vrf-quickstart-guide](https://support.avacloud.io/avacloud-vrf-quickstart-guide) demo and adds a Python command line script to play the game.

## Setup and Manual Running of Game

```bash
# Make a wallet (make sure to fund it)
$ cast wallet import dubbler-deploy --interactive
`dubbler-deploy` keystore was saved successfully. Address: 0xd0b12b87e5bbed53293a388054d9deb967578bb5

$ cast wallet list
dubbler-deploy (Local)

$ forge init avacloud-vrf
$ cd avacloud-vrf

$ forge install ava-labs/subnet-vrf
$ forge install smartcontractkit/chainlink

# Adds line to end of "[profile.default]" section in foundry.toml
$ echo remappings = ["@chainlink/=lib/chainlink/", "@vrf/=lib/subnet-vrf/src"] >> foundry.toml

$ rm src/Counter.sol 
$ rm test/Counter.t.sol
$ rm script/Counter.s.sol 

# Get the vrfProxyAddress from:
# https://app.avacloud.io/subnets/5f31bd7d-ef74-4f0d-a285-41b41a7ab0f3/interoperability/?tab=vrf
# vrfProxyAddress = 0xf8af2e5f1df3c4c3aa3cac700e681aeab03de27f

$ export FOUNDRY_ETH_RPC_URL="https://testnet-dubbler-e8b7b.avax-test.network/ext/bc/2eqXYWEMqrYMvPRnRUR814UZS7XKLJiehaK1SRwR1i4VuNXt2A/rpc?token=134b9b95c5c66567721055f8f0c5fa9f88caa3e909fba15f4534d89e3682e9bc"

# Note that the demo is missing the "--broadcast" option:
$ forge create --account dubbler-deploy src/AvaCloudVRFConsumer.sol:AvaCloudVRFConsumer --constructor-args 0xf8af2e5f1df3c4c3aa3cac700e681aeab03de27f
Warning: To broadcast this transaction, add --broadcast to the previous command. See forge create --help for more.

$ forge create --account dubbler-deploy --broadcast src/AvaCloudVRFConsumer.sol:AvaCloudVRFConsumer --constructor-args 0xf8af2e5f1df3c4c3aa3cac700e681aeab03de27f
[⠊] Compiling...
No files changed, compilation skipped
Enter keystore password:
Deployer: 0xD0b12b87E5BbeD53293A388054d9deb967578bb5
Deployed to: 0xC55708C5067883bE5029a567e16C880ebC15D21c
Transaction hash: 0xf2cbbb6109615a47e7b1f02067450af36c0c6af1896ff627da410f7a68b35fda

# Add the contract address to the Consumer Allowlist in the AvaCloud Portal VRF module

# Test the contract.
$ cast send --account dubbler-deploy 0xC55708C5067883bE5029a567e16C880ebC15D21c "guessRandomNumber(uint256)" 5
transactionHash      0x03b6e99555d531f25567d5e2fbfded01f08ec5d4d441929420c08dc29c2860f9

# Get the REQUEST_ID (last item in "topics" shows its 2)
$ cast receipt 0x03b6e99555d531f25567d5e2fbfded01f08ec5d4d441929420c08dc29c2860f9 | grep "logs " | grep -ioE "[{][^}]+0xC55708C5067883bE5029a567e16C880ebC15D21c[^}]+[}]"
{"address":"0xc55708c5067883be5029a567e16c880ebc15d21c","topics":["0x1d9111435f4b854f073bc412802d9927efaba88c5d4f981bb66464a1ea11f045","0x000000000000000000000000d0b12b87e5bbed53293a388054d9deb967578bb5","0x0000000000000000000000000000000000000000000000000000000000000002"],"data":"0x0000000000000000000000000000000000000000000000000000000000000005","blockHash":"0xa3d69944823b0846ff02135931fa020cafc6108ab6e87abf3017568a55c87afe","blockNumber":"0x18","transactionHash":"0x03b6e99555d531f25567d5e2fbfded01f08ec5d4d441929420c08dc29c2860f9","transactionIndex":"0x0","logIndex":"0x3","removed":false}

# Check the guess (this confirmed I guessed 5)
$ % cast call 0xC55708C5067883bE5029a567e16C880ebC15D21c "guesses(uint256)(address,uint256,bool)" 2
0xD0b12b87E5BbeD53293A388054d9deb967578bb5
5
true

# Get the returned random number (in this case, REQUEST_ID 2 returns a random number of 2). I lost this round of the game.
$ cast call 0xC55708C5067883bE5029a567e16C880ebC15D21c "returnedNumber(uint256)(uint256)" 2
2

# If you ask for a REQUEST_ID that doesn't exist yet, its value is zero
$ cast call 0xC55708C5067883bE5029a567e16C880ebC15D21c "returnedNumber(uint256)(uint256)" 3
0
```

## Run Game via Python Script

To speed up testing, the game can be run via python3 and foundry's cast:

```bash
$ chmod u+x vrf-game

$ ./vrf-game 
usage: vrf-game [-h] [-d] [-l] [user] [guess]

positional arguments:
  user              Username of player.
  guess             Number guessed (1 to 10, inclusive)

options:
  -h, --help        show this help message and exit
  -d, --debug       Activate debug mode
  -l, --list-users  List users and balances

$ ./vrf-game -d
Python 3.13.1 (main, Dec  3 2024, 17:59:52) [Clang 16.0.0 (clang-1600.0.26.4)] @ /opt/homebrew/opt/python@3.13/bin/python3.13
cast Version: 0.3.1-dev

$ ./vrf-game -l
Available Users (Balance):
dubbler-deploy (4.983204 DBLR)

# Round 1: Lost.
$ ./vrf-game dubbler-deploy 5
You guessed 5
The random number was 4
Sorry, you lost.
Your balance is 4.946669 DBLR
The remaining prize pool is 4.750000 DBLR

# Round 2: Lost again.
$ ./vrf-game dubbler-deploy 5
You guessed 5
The random number was 4
Sorry, you lost.
Your balance is 4.940376 DBLR
The remaining prize pool is 4.750000 DBLR

# Round 3: Winner!
% ./vrf-game dubbler-deploy 5
You guessed 5
The random number was 5
Congratulations! You won!
Claiming rewards...
https://subnets-test.avax.network/dubbler/tx/0x9abc352fd1e6ae070a0227462e573c7cc2d75429b2a17cdfce86a95b0c9eec3d?tab=internal_txs
Your balance is 4.983204 DBLR
The remaining prize pool is 4.700000 DBLR
```
