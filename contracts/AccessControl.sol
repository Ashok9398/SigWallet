// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AccessControl{
    using SafeMath for uint;
    address admin;

    event Deposit(address indexed sender, uint256 value);
    event Submission(uint256 indexed transactionId);
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event QuorumUpdate(uint256 quorum);
    event AdminTransfer(address indexed newAdmin);

    address[] public owners;
    mapping(address=>bool) public isOwner;
    uint public quorum;

    modifier onlyOwner(){
        require(msg.sender ==admin);
        _;
    }
    modifier notNull(address indexed _address){
        require(_address != address(0));
        _;
    }
    modifier ownerExists(address indexed _address){
        require(isOwner[_address] == true );
        _;
    }
    modifier OwnerNotExists(address indexed _address){
        require(isOwner[_address] ==false);
        _;
    }

    constructor(address[] memory  _owners){
        admin = msg.sender;
        require(_owners.length >3);
        for(uint i= 0; i<_owners.length;i++){
            isOwner[_owners[i]] =true;
        }
        owners = _owners;
        uint num = SafeMath.mul(owners.length,60);
        quorum = SafeMath.div(num,100);
    }

    function addOwner(address owner)public onlyOwner notNull(owner) OwnerNotExists(owner){
        isOwner[owner] =true;
        owners.push(owner);
        emit OwnerAddition(owner);
        updateQuorum(owners);
    }
    function removeOwner(address owner) public onlyOwner notNull(owner) ownerExists(owner){
        isOwner[owner] = false;
        for(uint i= 0;i<owners.length-1;i++){
            if(owners[i] == owner){
                owners[i] = owners[owners.length-1];
                break;
            }
            owners.pop();

        }
        emit OwnerRemoval(owner);
        updateQuorum(owners);
    }
    function AdminTransferFun(address newAdmin) public onlyOwner notNull(newAdmin) {
        admin = newAdmin;
        emit AdminTransfer(newAdmin);
    }
    function transferOwner(address _from ,address _to)public notNull(_from) notNull(_to) ownerExists(_from) OwnerNotExists(_to){
        for(uint i= 0;i<owners.length;i++){
            if(owners[i] == _from){
                owners[i] = _to;
                break;
            }
        }
        isOwner[_from] = false;
        isOwner[_to ] =true;
        emit OwnerRemoval(_from);
        emit OwnerAddition(_to);
    }
    function updateQuorum(address[] memory _owners)internal{
        uint num = SafeMath.mul(_owners.length,60);
        quorum = SafeMath.div(num,100);
        emit QuorumUpdate(quorum);
    }

}