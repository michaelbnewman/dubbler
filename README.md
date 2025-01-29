# dubbler

<img src="logo.png" alt="dubbler logo" width="200" height="200">

Double your tokens today!
<br>(If you prefer a slower game, check out the [avacloud-vrf-demo](avacloud-vrf-demo/README.md))

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
$ echo 'remappings = ["@chainlink/=lib/chainlink/", "@vrf/=lib/subnet-vrf/src"]' >> foundry.toml

$ rm src/Counter.sol 
$ rm test/Counter.t.sol
$ rm script/Counter.s.sol 

$ cp ../Dubbler.sol src/Dubbler.sol

# Get the vrfProxyAddress from:
# https://app.avacloud.io/subnets/5f31bd7d-ef74-4f0d-a285-41b41a7ab0f3/interoperability/?tab=vrf
# vrfProxyAddress = 0xf8af2e5f1df3c4c3aa3cac700e681aeab03de27f

$ export FOUNDRY_ETH_RPC_URL="https://testnet-dubbler-e8b7b.avax-test.network/ext/bc/2eqXYWEMqrYMvPRnRUR814UZS7XKLJiehaK1SRwR1i4VuNXt2A/rpc?token=134b9b95c5c66567721055f8f0c5fa9f88caa3e909fba15f4534d89e3682e9bc"

$ forge create --account dubbler-deploy --broadcast src/Dubbler.sol:Dubbler --constructor-args 0xf8af2e5f1df3c4c3aa3cac700e681aeab03de27f
[⠊] Compiling...
Deployer: 0xD0b12b87E5BbeD53293A388054d9deb967578bb5
Deployed to: 0x039fcae98597a2c7FcDe2e6C144ee4da56199e1b
Transaction hash: 0xb43f378624acfb73070f611b14c777456b0152d50d0c57b0e20c60500236ab62

# Add the contract address to the Consumer Allowlist in the AvaCloud Portal VRF module

# Fund the prize pool
$ cast send --account dubbler-deploy --value 5ether 0x039fcae98597a2c7FcDe2e6C144ee4da56199e1b
transactionHash      0xd3cf016fe4d7888c46f71f7e89e47d7132e8578cb2a6b1d68f989290e62b4e86
```

## Run Game via Python Script

The game is run via a Python script (Requires Foundry's [cast](https://book.getfoundry.sh/reference/cast/cast)):

```bash
$ chmod u+x dubbler-cli

$ ./dubbler-cli
usage: dubbler-cli [-h] [-d] [-l] [user] [guess] [wager]

positional arguments:
  user              Username of player.
  guess             'even' or 'odd'
  wager             Amount of tokens to wager (double or nothing!)

options:
  -h, --help        show this help message and exit
  -d, --debug       Activate debug mode
  -l, --list-users  List users and balances

$ ./dubbler-cli -d
Python 3.13.1 (main, Dec  3 2024, 17:59:52) [Clang 16.0.0 (clang-1600.0.26.4)] @ /opt/homebrew/opt/python@3.13/bin/python3.13
cast Version: 0.3.1-dev

$ ./dubbler-cli -l
Available Users (Balance):
dubbler-deploy (34.873536 DBLR)

# Round 1: Lost.
$ ./dubbler-cli dubbler-deploy even 0.5
You guessed an even number, with a wager of 0.5 DBLR
The random number was odd: 86041476454922884097956512269555491006819873557406678784329003497700516367687
Sorry, you lost.
Your balance is 34.367144 DBLR
The remaining prize pool is 5.500000 DBLR

# Round 2: Lost again.
$ ./dubbler-cli dubbler-deploy even 1
You guessed an even number, with a wager of 1 DBLR
The random number was odd: 27862624210175735810232007312226201291874808441134173150735858489760872861281
Sorry, you lost.
Your balance is 33.360752 DBLR
The remaining prize pool is 6.500000 DBLR

# Round 3: Winner!
% ./dubbler-cli dubbler-deploy even 1
You guessed an even number, with a wager of 1 DBLR
The random number was even: 49817747975513771598378313733968872853120641722507622463699641776943511470830
Congratulations! You won!
Claiming rewards...
https://subnets-test.avax.network/dubbler/tx/0x19edb696710c30e18f16d9ca6c7513a2fc41fd2c34057e305cf20ac648645127?tab=internal_txs
Your balance is 34.353480 DBLR
The remaining prize pool is 5.500000 DBLR
```
