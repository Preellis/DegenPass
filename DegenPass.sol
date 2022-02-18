//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol";

contract DegenPass is ERC1155, Ownable, ReentrancyGuard {
    
  string public name = "Degen Pass";
  string public symbol = "DEP";

  uint private maxPasses = 222;
  uint private passCount = 0;

  uint private passID = 1;

  bool public isSecondPass = false;

  //TODO: Change for production
  bytes32 public merkleRoot = 0xb9cf0439b7e2bfe4a7122d79dbe158e96fcbf5365a3a0f4f503f46b3c525621c;

  mapping(address => uint) public whiteListMints;

  //TODO: Change for production
  string private passUri = "ipfs://QmRSPi5uDEP5wgSpYHqsLEeGuYsBwQVFd1fTqU482QVphb/metadata.json";

  constructor() ERC1155("") {}

  /**
   Allows mintlisted members to mint 1 pass during the first pass and allows 
   them to mint 1 more during the second pass.
   */
  function mintListMint(bytes32[] calldata _merkleProof) external nonReentrant{
    //TODO: check if necessary to check tx.origin and nonReentrant
    require(msg.sender == tx.origin, "Contracts are not allowed to mint");
    require(passCount < maxPasses, "Passes sold out.");
    require((whiteListMints[msg.sender] < 1) || (isSecondPass && (whiteListMints[msg.sender] < 2)), "Already reached mint limit.");
    require(MerkleProof.verify(_merkleProof, merkleRoot,keccak256(abi.encodePacked(msg.sender))), "Proof invalid.");

    whiteListMints[msg.sender]++;
    passCount++;

    _mint(msg.sender, passID, 1, "");
  }

  function setSecondPass() external onlyOwner{
    isSecondPass = !isSecondPass;
  }

  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner{
    merkleRoot = _merkleRoot;
  }

  /**
  Allows contract owner to mint while still under mint limit.
   */
  function ownerMint(address _to, uint _amount) external onlyOwner {
    require(passCount < maxPasses, "Passes sold out.");
    _mint(_to, passID, _amount, "");
  }

  function setURI(string memory _uri) external onlyOwner {
    passUri = _uri;
    emit URI(_uri, passID);
  }

  function uri(uint) public override view returns (string memory) {
    return passUri;
  }
}
