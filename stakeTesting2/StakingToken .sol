// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/token/ERC20/ERC20.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/math/SafeMath.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.4.0/contracts/ownership/Ownable.sol";


import "./ZertifierNFT.sol";
import "./SafeMath.sol";


contract StakingToken is ERC721, Ownable {
   using SafeMath for uint256;
   /**
    * @notice The constructor for the Staking Token.
    * @param _owner The address to receive all tokens on construction.
    * @param _supply The amount of tokens to mint on construction.
    */
   constructor(address _owner, uint256 _supply)
       public 
   {
        _mint(_owner, _supply);
    // _mint(0x884F07b0F5D42ea33e563e6E1fdD99Ad9Adb706c, 1);
   }

    /**
     * @notice We usually require to know who are all the stakeholders.
     */
    address[] internal stakeholders;


    /**
    * @notice A method to check if an address is a stakeholder.
    * @param _address The address to verify.
    * @return bool, uint256 Whether the address is a stakeholder,
    * and if so its position in the stakeholders array.
    */
   function isStakeholder(address _address)
       public
       view
       returns(bool, uint256)
   {
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           if (_address == stakeholders[s]) return (true, s);
       }
       return (false, 0);
   }


    /**
    * @notice A method to add a stakeholder.
    * @param _stakeholder The stakeholder to add.
    */
   function addStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, ) = isStakeholder(_stakeholder);
       if(!_isStakeholder) stakeholders.push(_stakeholder);
   }
   

   /**
    * @notice A method to remove a stakeholder.
    * @param _stakeholder The stakeholder to remove.
    */
   function removeStakeholder(address _stakeholder)
       public
   {
       (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
       if(_isStakeholder){
           stakeholders[s] = stakeholders[stakeholders.length - 1];
           stakeholders.pop();
       }
   }

    /**
    * @notice The stakes for each stakeholder.
    */
   mapping(address => uint256) internal stakes;


    /**
    * @notice A method to retrieve the stake for a stakeholder.
    * @param _stakeholder The stakeholder to retrieve the stake for.
    * @return uint256 The amount of wei staked.
    */
   function stakeOf(address _stakeholder)
       public
       view
       returns(uint256)
   {
       return stakes[_stakeholder];
   }

    /**
    * @notice A method to the aggregated stakes from all stakeholders.
    * @return uint256 The aggregated stakes from all stakeholders.
    */
   function totalStakes()
       public
       view
       returns(uint256)
   {
       uint256 _totalStakes = 0;
       for (uint256 s = 0; s < stakeholders.length; s += 1){
           _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
       }
       return _totalStakes;
   }


    /**
    * @notice A method for a stakeholder to create a stake.
    * @param _stake The size of the stake to be created.
    */
   function createStake(uint256 _stake)
       public
   {
    //    _burn(msg.sender, _stake);
       if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
       stakes[msg.sender] = stakes[msg.sender].add(_stake);
   }


   /**
    * @notice A method for a stakeholder to remove a stake.
    * @param _stake The size of the stake to be removed.
    */
   function removeStake(uint256 _stake)
       public
   {
       stakes[msg.sender] = stakes[msg.sender].sub(_stake);
       if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
       _mint(msg.sender, _stake);
   }

}