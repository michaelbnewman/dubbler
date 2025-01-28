# dubbler

Double your tokens today! (If you prefer a slower game, check out the [avacloud-vrf-demo](avacloud-vrf-demo/README.md))

## Setup

```bash
# Make a wallet (make sure to fund it)
$ cast wallet import dubbler-deploy --interactive
`dubbler-deploy` keystore was saved successfully. Address: 0xd0b12b87e5bbed53293a388054d9deb967578bb5

$ cast wallet list
dubbler-deploy (Local)

$ forge init dubbler
$ cd dubbler

$ forge install ava-labs/subnet-vrf
$ forge install smartcontractkit/chainlink

# Adds line to end of "[profile.default]" section in foundry.toml
$ echo remappings = ["@chainlink/=lib/chainlink/", "@vrf/=lib/subnet-vrf/src"] >> foundry.toml

$ rm src/Counter.sol 
$ rm test/Counter.t.sol
$ rm script/Counter.s.sol 

$ cp ../Dubbler.sol src/Dubbler.sol

# Get the vrfProxyAddress from:
# https://app.avacloud.io/subnets/5f31bd7d-ef74-4f0d-a285-41b41a7ab0f3/interoperability/?tab=vrf
# vrfProxyAddress = 0xf8af2e5f1df3c4c3aa3cac700e681aeab03de27f

$ export FOUNDRY_ETH_RPC_URL="https://testnet-dubbler-e8b7b.avax-test.network/ext/bc/2eqXYWEMqrYMvPRnRUR814UZS7XKLJiehaK1SRwR1i4VuNXt2A/rpc?token=134b9b95c5c66567721055f8f0c5fa9f88caa3e909fba15f4534d89e3682e9bc"

$ forge create --account dubbler-deploy --broadcast src/Dubbler.sol:AvaCloudVRFConsumer --constructor-args 0xf8af2e5f1df3c4c3aa3cac700e681aeab03de27f
[⠊] Compiling...
Deployer: 0xD0b12b87E5BbeD53293A388054d9deb967578bb5
Deployed to: ???
Transaction hash: ???

# Add the contract address to the Consumer Allowlist in the AvaCloud Portal VRF module

# Fund the prize pool
$ cast send --account dubbler-deploy --value 5ether 0xC55708C5067883bE5029a567e16C880ebC15D21c
transactionHash      0x8bb83585c85277e28445854b39fede5adaaeae8c76beca83015c31f67fcab7d2
```

## Run Game Manually

```bash
# Test the contract.
$ cast send --account dubbler-deploy ??? "guessRandomNumber(uint256)" 5
transactionHash      ???

# Get the REQUEST_ID (last item in "topics" shows its 2)
$ cast receipt 0x03b6e99555d531f25567d5e2fbfded01f08ec5d4d441929420c08dc29c2860f9 | grep "logs " | grep -ioE "[{][^}]+0xC55708C5067883bE5029a567e16C880ebC15D21c[^}]+[}]"
??? output pending ???

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
$ chmod u+x dubbler-cli

$ ./dubbler-cli
usage: dubbler-cli [-h] [-d] [-l] [user] [guess] [wager]

positional arguments:
  user              Username of player.
  guess             'even' or 'odd' number
  wager             Tokens put up as a wager

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
$ ./vrf-game dubbler-deploy even 1
You guessed an even number with a wager of 1.000000 DBLR
The random number was 5 (odd)
Sorry, you lost.
Your balance is 3.946669 DBLR
The remaining prize pool is 4.750000 DBLR

# Round 2: Lost again.
$ ./vrf-game dubbler-deploy even 1
You guessed an even number with a wager of 1.000000 DBLR
The random number was 9 (odd)
Sorry, you lost.
Your balance is 2.940376 DBLR
The remaining prize pool is 4.750000 DBLR

# Round 3: Winner!
% ./vrf-game dubbler-deploy even 1
You guessed an even number with a wager of 1.000000 DBLR
The random number was 4 (even)
Congratulations! You won!
Claiming rewards...
https://subnets-test.avax.network/dubbler/tx/0x9abc352fd1e6ae070a0227462e573c7cc2d75429b2a17cdfce86a95b0c9eec3d?tab=internal_txs
Your balance is 4.923204 DBLR
The remaining prize pool is 2.750000 DBLR
```
