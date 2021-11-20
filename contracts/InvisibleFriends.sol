// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract InvisibleFriends is ERC721Enumerable, Ownable{

  using Strings for uint256;
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  
  string public baseURI;
  uint256  cost = 0.005 ether;
  uint256  maxSupply = 10000;
  uint256  maxMintAmount = 10;
  uint  numberOfFreeMints = 500;
  bool  paused = false;
  string public baseExtension = ".json";

  uint256 mintedeExclusive;
  uint256 exclusiveAmountminted;

  mapping(address => bool)  whitelisted;

  struct V1 {
    uint256 balanceOf;
  }

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
     
    setBaseURI(_initBaseURI);
  }

  // mint token
  function mint(address _to, uint _amount) public payable {
    require(!paused,'contract is paused!');
    require(totalSupply() + _amount <= maxSupply,'all tokens have been minted!');
    require(_amount<=maxMintAmount,'cant mint more than max Mint Amount!');
    require(_amount>0,'must mint at least 1!');

    if(whitelisted[msg.sender] != true) {
      if(totalSupply() >= numberOfFreeMints)
        require(msg.value >= (cost*_amount),'not enough ether sent!');
    }
    for(uint i=0;i<_amount;i++){
      _tokenIds.increment();
      uint256 newItemId = _tokenIds.current();
      _safeMint(_to, newItemId);
    }
  }



  //set number of nft tokens free of fee
  function setNumberOffreeMints(uint _numberOfFreeMints) external onlyOwner(){
    numberOfFreeMints = _numberOfFreeMints;
  }

  //return fee for the sender
  function getTotalFee() external view returns(uint256){
    if(totalSupply() >= numberOfFreeMints && whitelisted[msg.sender] != true)
    {
      return cost;
    }else{
      return 0;
    }
  }

  //return number of tokens free of fee (starting from the first mint)
  function getNumberOffreeMints() external view returns(uint256){
    return numberOfFreeMints;
  }

  //returns if all nft have been minted
  function allHaveBeenMinted() external view returns(bool){
    return totalSupply()>=maxSupply;
  }

  //max supply of tokens (number of mints)
  function getMaxSupply() external view returns(uint256){
    return maxSupply;
  }

  // internal, base uri
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  //all the nfts of an address
  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  //uri of ERC721 
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token!"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //set cost of minitig
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

  //set max mint amount per user per mint (1 for fair chance to get)
  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  //set ERC721 uri
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  //pause contract (no minting)
  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

 function isWhiteListed(address _user) external view returns(bool){
   return whitelisted[_user];
 }
 
 //whitelist user for minting for free
 function whitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = true;
  }
 
 //remove user from whitelist
  function removeWhitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = false;
  }

  //wirthdraw funds from the contract 
  function withdraw() public payable onlyOwner {
    require(payable(msg.sender).send(address(this).balance));
  }

  //receive function
  receive() payable external {} 


}