// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import {IVRFProxy} from "@vrf/interfaces/IVRFProxy.sol";

contract Dubbler is VRFConsumerBaseV2 {
    struct RandomNumberGuess {
        address requestor;
        uint256 guess;
        bool isResolved;
    }

    IVRFProxy private proxy;
    mapping(uint256 vrfRequestId => RandomNumberGuess guess) public guesses;
    // if requesting more than one random number, value of mapping should be array
    mapping(uint256 vrfRequestId => uint256 randomNum) public returnedNumber;
    mapping(address guesser => uint256 amountToClaim) public rewards;

    uint256 public constant REWARD_AMOUNT = 0.05 ether;

    event Payout(address indexed guesser, uint256 reward);
    event Fund(address indexed funder, uint256 total);
    event RandomNumberGuessed(
        address indexed guesser,
        uint256 guess,
        uint256 indexed vrfRequestID
    );
    event RewardsClaimed(address owner, uint256 reward);

    error InvalidDataLength();
    error InvalidRequestID();
    error RequestAlreadyResolved();
    error NoRewardsToClaim();

    constructor(address vrfProxyAddress) VRFConsumerBaseV2(vrfProxyAddress) {
        proxy = IVRFProxy(vrfProxyAddress);
    }

    receive() external payable {
        emit Fund(msg.sender, msg.value);
    }

    function proxyAddress() public view returns (address) {
        return address(proxy);
    }

    function claimRewards() external {
        uint256 reward = rewards[msg.sender];
        if (reward <= 0) revert NoRewardsToClaim();

        rewards[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: reward}("");
        require(success, "Transfer failed");

        emit RewardsClaimed(msg.sender, reward);
    }

    function guessRandomNumber(
        uint256 guess
    ) public returns (uint256 _requestId) {
        // blockDelay and callbackGasLimit are recommended values
        uint16 blockDelay = 1;
        uint32 callbackGasLimit = 200_000;
        uint32 numberOfRandomValues = 1;

        // get the current nonce and increment
        uint256 requestId = proxy.requestNonce() + 1;
        guesses[requestId] = RandomNumberGuess(msg.sender, guess, false);
        proxy.requestRandomWords(
            blockDelay,
            callbackGasLimit,
            numberOfRandomValues
        );
        emit RandomNumberGuessed(msg.sender, guess, requestId);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        if (_randomWords.length != 1) revert InvalidDataLength();
        RandomNumberGuess storage guess = guesses[_requestId];
        if (guess.requestor == address(0)) revert InvalidRequestID();
        if (guess.isResolved) revert RequestAlreadyResolved();
        guess.isResolved = true;

        uint256 result = _randomWords[0];
        returnedNumber[_requestId] = result;
        // guess = 0 (even), guess = 1 (odd)
        if (result % 2 == guess.guess) {
            rewards[guess.requestor] += REWARD_AMOUNT;
        }
    }
}
