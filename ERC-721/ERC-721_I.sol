pragma solidity ^0.8.28 < 0.9.0;

contract erc721  {
    string public name;
    string public symbol;

    uint256 public nextTokenIdToMint;
    address public owner;

    mapping(uint256 => address) internal _owners;
    mapping(uint256 => address) internal _balances;
    mapping(uint256 => address) internal _tokenApproval;
    mapping(address => mapping(uint256 =>)) internal _operatorApproval;
    mapping(uint256 =< string) _tokenUris;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator,bool _approved);

    constructor(string memory _name, string memory _symbol){
        _name=name;
        _symbol=symbol;
        nextTokenIdToMint=0;
        owner=msg.sender;
    }

    function balanceOf(address _owner) public view returns(uint256) {
        require(_owner =!address(0) ,"address is Zero");
        return _balances[_owner];

    }

    function ownerOf(uint256 _tokenId) public view returns(address) {
        return _owners[_tokenId];
    }

    function



}