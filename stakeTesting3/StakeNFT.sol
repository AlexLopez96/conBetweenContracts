// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StakeNFT is ERC20
{
    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public deposited_tokens;
    mapping(address => bool) public has_deposited;
    ERC721 public my_token;

    uint public REWARD_PER_BLOCK = 100 ether;

    constructor() ERC20("My Staking Token", "MYST"){
        my_token = ERC721(0xedFe19341f9AfBDD59024cd132332d3BBc114abd);
    }

    function stake(uint256 tokenId) external
    {
        require (msg.sender == my_token.ownerOf(tokenId), 'Sender must be owner');
        require (!has_deposited[msg.sender], 'Sender already deposited');
        if(checkpoints[msg.sender] == 0){
            checkpoints[msg.sender] = block.number;
        }
        collect(msg.sender);
        my_token.transferFrom(msg.sender, address(this), tokenId);
        deposited_tokens[msg.sender] = tokenId;
        has_deposited[msg.sender] = true;
   }

    function withdraw() external
    {
        require(has_deposited[msg.sender], 'No tokens to withdarw');
        collect(msg.sender);
        my_token.transferFrom(address(this), msg.sender, deposited_tokens[msg.sender]);
        has_deposited[msg.sender] = false;
    }

    function collect(address beneficiary) public
    {
        uint256 reward = calculateReward(beneficiary);
        checkpoints[beneficiary] = block.number;      
        _mint(msg.sender, reward);
    }

    function calculateReward(address beneficiary) public view returns(uint256)
    {
        if(!has_deposited[msg.sender])
        {
            return 0;
        }
        uint256 checkpoint = checkpoints[beneficiary];
        return REWARD_PER_BLOCK * (block.number-checkpoint);
    }
}