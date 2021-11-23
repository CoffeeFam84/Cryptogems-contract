// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './yieldtoken.sol';

contract NFTCRYPTOGEMS is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.0777 ether;
  uint256 public maxSupply = 777;
  uint256 public maxMintAmount = 5;
  uint256 public headStart = block.timestamp + 3 days;
  bool public paused = false;
  bool public revealed = false;
  string public notRevealedUri;
  YieldToken public yieldToken;
  bool public middlePay = false;
  bool public finalPay = false;
  address airdropAddress = 0xD4577dA97872816534068B3aa8c9fFEd2ED7860C;
    
  constructor(
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721("CRYPTOGEMS", "CGS") {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
    uint8 i;
    for (i = 1; i <= 20; i++)
      _safeMint(airdropAddress, i);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

	function setYieldToken(address _yield) external onlyOwner {
		yieldToken = YieldToken(_yield);
	}  

	function getReward() external {
		yieldToken.updateReward(msg.sender, address(0), 0);
		yieldToken.getReward(msg.sender);
	}

	function transferFrom(address from, address to, uint256 tokenId) public override {
		yieldToken.updateReward(from, to, tokenId);
		ERC721.transferFrom(from, to, tokenId);
	}
  // public
  function mint(uint256 _mintAmount) public payable { 
    uint256 supply = totalSupply();   
    require(!paused, "Contract is paused!");
    require(_mintAmount > 0, "must mintAmount > 0");
    require(_mintAmount <= maxMintAmount, "maxmintamount limit exceed");
    require(supply + _mintAmount <= maxSupply, "supply amount exceed");
    require(msg.sender != owner(), "Owner can not mint!");    
    require(msg.value >= cost * _mintAmount, "Not enough funds!");

    yieldToken.updateReward(msg.sender, address(0), 0);
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
    }
    if((supply + _mintAmount) * 2 >= maxSupply && middlePay == false) {
      middlePay = true;
      (bool success, ) = payable(0x2F20D2cafaa1692e401791Be811700fb56f0930B).call{value: 1.08 ether}("");
      require(success, "Could not send middlepay value");
    }
  }

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
  
  function randomNum(uint256 _mod, uint256 _seed, uint256 _salt) public view returns(uint256) {
      uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
      return num;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal() public onlyOwner() {
      revealed = true;
  }
  
  function setCost(uint256 _newCost) public onlyOwner() {
    cost = _newCost;
  }

  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
  
  function withdraw() public payable onlyOwner {
    uint256 supply = totalSupply();
    require(supply == maxSupply || block.timestamp >= headStart, "Can not withdraw yet.");
    require(middlePay == true, "Can not withdraw yet.");  
    require(address(this).balance > 1 ether);  
    uint256 poolBalance = address(this).balance * 20 / 100;  
    uint256 bankBalance = address(this).balance * 30 / 100;   
    if(finalPay == false) {
      finalPay = true;
      (bool d, ) = payable(0x2F20D2cafaa1692e401791Be811700fb56f0930B).call{value: 1 ether}("");
      require(d);      
    }
    bool success;
    //collaborator
    
    //charity
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}(""); 
    require(success);
    //daosystem
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}("");
    require(success);
    //artist
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}("");
    require(success);
    //dev
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}("");
    require(success);
    //cofounder
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}("");
    require(success);
    //founder
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}("");
    require(success);
    //influencer1
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}("");
    require(success);
    //influencer2
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 9 / 100}("");
    require(success);
    //influencer3
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 9 / 100}("");
    require(success);
    //draftwinner1
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 8 / 100}("");
    require(success);
    //draftwinner2
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 9 / 100}("");
    require(success);
    //draftwinner3
    (success, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: poolBalance * 9 / 100}("");
    require(success);
    
    //bank
    (bool bank, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: bankBalance}("");
    require(bank);

    //founder
    uint256 founderBalance = address(this).balance;  
    (bool founder1, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: founderBalance * 45 / 100}("");
    require(founder1);
    (bool founder2, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: founderBalance * 225 / 1000}("");
    require(founder2);
    (bool founder3, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: founderBalance * 20 / 100}("");
    require(founder3);
    (bool founder4, ) = payable(0xA58ee9834F6D52cF936e538908449E60D9e4A6Bf).call{value: founderBalance * 125 / 1000}("");
    require(founder4);
  }
}
