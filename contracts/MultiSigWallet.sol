// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./AccessControl.sol";

contract MultiSigWallet is AccessControl{
   using SafeMath for uint;

    struct Transaction{
        bool executed;
        address destination;
        uint value;
        bytes data;
    }
    uint public transactionCount;
    mapping(uint=>Transaction) public transactions;
    Transaction[] public _validTransactions;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    bool public  isReached;
    bool public success;
    bytes datas;
    fallback() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }
     receive() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }
    modifier isOwnerMod(address owner) {
        require(
            isOwner[owner] == true,
            "You are not authorized for this action."
        );
        _;
    }

    modifier isConfirmed(uint transactionId,address _owner){
        require(confirmations[transactionId][_owner] == false);
        _;
    }
     modifier isExecuted(uint256 transactionId) {
        require(
            transactions[transactionId].executed == false);
        _;
    }

    constructor(address[] memory _owners) AccessControl(_owners){}

    function submitTransaction(address destination , uint value , bytes memory data)public isOwnerMod(msg.sender) returns(uint transactionId){
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value : value,
            data : data,
            executed : false
        });
        transactionCount++;
        emit Submission(transactionId);
        confirmTransaction(transactionId);
    }
    function confirmTransaction(uint transactionId)public isOwnerMod(msg.sender) isConfirmed(transactionId , msg.sender) notNull(transactions[transactionId].destination){
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender,transactionId);
        executeTransaction(transactionId);
    }
    function executeTransaction(uint transactionId) public isOwnerMod(msg.sender) isExecuted(transactionId){
        uint count = 0;
        

        for(uint i=0 ; i<owners.length;i++){
            if(confirmations[transactionId][owners[i]]){
                count++;
            }
            if(count>=quorum){
                isReached = true;
            }
        }
        if (isReached) {
            // extrapolate struct to a variable
            Transaction storage txn = transactions[transactionId];
            // update variable executed state
            txn.executed = true;

            // transfer the value to the destination address, and get boolean of success/fail
            (success,datas) = transactions[transactionId].destination.call{value: transactions[transactionId].value}(transactions[transactionId].data);

            if (success) {
                _validTransactions.push(txn);
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }

    }
    function revokeTransaction(uint transactionId)public isOwnerMod(msg.sender) isConfirmed(transactionId,msg.sender) isExecuted(transactionId) notNull(transactions[transactionId].destination){
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getValidTransactions()external view returns (Transaction[] memory)  {
        return _validTransactions;
    }

    function getQuorum() external view returns (uint256) {
        return quorum;
    }


}
