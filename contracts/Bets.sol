// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Bets is Ownable {
    struct Bet {
        uint256 id;
        string title;
        uint256 amount;
        address creator;
        address bettor;
        BetStatus status;
    }

    enum BetStatus {
        PENDING_OPEN_VALIDATION,
        OPEN,
        IN_PROGRESS,
        PENDING_FULFILLMENT_VALIDATION,
        CLOSED,
        CANCELLED
    }

    mapping(uint256 => Bet) public bets;

    uint256 public betsCount;

    event BetCreated(uint256 indexed _betId, string _title, uint256 _amount);
    event BettorJoined(uint256 indexed _betId, string _title);
    event BetOpenApproved(uint256 indexed _betId, string _title);
    event BetOpenCanceled(uint256 indexed _betId, string _title);
    event BetFullfilled(uint256 indexed _betId, address _winner, address _looser);

    modifier onlyBettor(uint256 _betId) {
        require(msg.sender != bets[_betId].creator, "Bet creator can't use this function");
        _;
    }

     function getAllBetIds() external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](betsCount);
        for (uint256 i = 0; i < betsCount; i++) {
            ids[i] = bets[i + 1].id;
        }
        return ids;
    }

    function getBetById(uint256 betId) external view returns (uint256, string memory, uint256, address, address, BetStatus) {
        require(bets[betId].id != 0, "Bet does not exist");
        return (
            bets[betId].id,
            bets[betId].title,
            bets[betId].amount,
            bets[betId].creator,
            bets[betId].bettor,
            bets[betId].status
        );
    }

    function createBet(string memory _title) public payable {
        require(msg.value > 0, "Not enough ETH to enter.");
        betsCount++;
        bets[betsCount] = Bet(
            betsCount,
            _title,
            msg.value,
            msg.sender,
            address(0),
            BetStatus.PENDING_OPEN_VALIDATION
        );

        emit BetCreated(betsCount, _title, msg.value);
    }

    function approveBetOpen(uint256 _id) public onlyOwner {
        require(bets[_id].status == BetStatus.PENDING_OPEN_VALIDATION, "Bet is not pending for opening");

        bets[_id].status = BetStatus.OPEN;
        emit BetOpenApproved(_id, bets[_id].title);
    }

    function rejectBetOpen(uint256 _id) public onlyOwner {
        require(bets[_id].status == BetStatus.PENDING_OPEN_VALIDATION, "Bet is not pending for opening");

        bets[_id].status = BetStatus.CANCELLED;
        emit BetOpenCanceled(_id, bets[_id].title);
    }

    function closeBet(uint256 _id, address payable _winner) public onlyOwner {
        Bet storage bet = bets[_id];
        bet.status = BetStatus.CLOSED;
        if (_winner == bet.creator) {
            // Creator is the winner, transfer the bet amount to the creator
            payable(bet.creator).transfer(bet.amount);
            emit BetFullfilled(_id, bet.creator, bet.bettor);
        } else if (_winner == bet.bettor) {
            // Bettor is the winner, transfer the bet amount to the bettor
            payable(bet.bettor).transfer(bet.amount);
            emit BetFullfilled(_id, bet.bettor, bet.creator);
        } else {
            // Neither the creator nor the bettor, something went wrong
            revert("Invalid sender for closing the bet");
        }
    }

    function joinBet(uint256 _id) public payable onlyBettor(_id) {
        require(bets[_id].status == BetStatus.OPEN, "Bet is not open for joining");

        bets[_id].bettor = msg.sender;
        bets[_id].amount = msg.value + bets[_id].amount;
        bets[_id].status = BetStatus.IN_PROGRESS;
        emit BettorJoined(_id, bets[_id].title);
    }
}
