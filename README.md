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
Deployed to: 0x11bcA6e6F96Dbc47EdC05A7a2B903b4195e57993
Transaction hash: 0xdaa03a175c93d138b8fba3e574a6976386fcc903862b4f84ed005bdcfdd98a05

# Add the contract address to the Consumer Allowlist in the AvaCloud Portal VRF module

# Fund the prize pool
$ cast send --account dubbler-deploy --value 5ether 0x11bcA6e6F96Dbc47EdC05A7a2B903b4195e57993
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
dubbler-deploy (4.983204 DBLR)

# Round 1: Lost.
$ ./dubbler-cli dubbler-deploy even 1
You guessed an even number
The random number was odd: 46584947867933822618834575764056702768349783735124609682002457720751313505717
Sorry, you lost.
Your balance is 49.941386 DBLR
The remaining prize pool is 5.000000 DBLR

# Round 2: Lost again.
$ ./dubbler-cli dubbler-deploy even 1
You guessed an even number
The random number was odd: 37838072612441908451319062785858980383081778870667557584347964653499282490463
Sorry, you lost.
Your balance is 49.935590 DBLR
The remaining prize pool is 5.000000 DBLR

# Round 3: Winner!
% ./dubbler-cli dubbler-deploy even 1
You guessed an even number
The random number was even: 26119791287843050551658032016889719567863772909423512873216519675860897832202
Congratulations! You won!
Claiming rewards...
https://subnets-test.avax.network/dubbler/tx/0x889f93912087a210ea0d2dbdbf0c384f3b98f3c5e96917f02ad3c9b5a444d113?tab=internal_txs
Your balance is 49.978917 DBLR
The remaining prize pool is 4.950000 DBLR
```
