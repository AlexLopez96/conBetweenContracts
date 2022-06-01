// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Receiver.sol";

contract NftStaker {
    // IERC1155 public parentNFT;
    IERC721 public parentNFT;

    struct Stake {
        uint256 tokenId;
        uint256 timestamp;
    }

    // map staker address to stake details
    mapping(address => Stake) public stakes;
    
     // map staker to total staking time 
    mapping(address => uint256) public stakingTime;  

    constructor() {
        // parentNFT = IERC1155(0x2ef16073D0172Df7216496E69Fb3AdB9a2BC219F); // Change it to your NFT contract addr
        parentNFT = IERC721(0x69eaCa914DFF7bB1e4C32AC9b7dA58Fee748D793); // Change it to your NFT contract addr
    }

    function stake(uint256 _tokenId) public {
        stakes[msg.sender] = Stake(_tokenId, block.timestamp); 
        // parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "0x00");
        parentNFT.safeTransferFrom(msg.sender, address(this), _tokenId, "0x00");

    } 

     function unstake() public {
        // parentNFT.safeTransferFrom(address(this), msg.sender, stakes[msg.sender].tokenId, stakes[msg.sender].amount, "0x00");
        parentNFT.safeTransferFrom(address(this), msg.sender, stakes[msg.sender].tokenId, "0x00");

        stakingTime[msg.sender] += (block.timestamp - stakes[msg.sender].timestamp);
        delete stakes[msg.sender];
    }  


    //Check if smartContract understends NFT
    // function onERC1155Received(
    //     address operator,
    //     address from,
    //     uint256 id,
    //     uint256 value,
    //     bytes calldata data
    // ) external returns (bytes4) {
    //     return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    // }
}