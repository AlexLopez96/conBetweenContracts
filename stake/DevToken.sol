// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Stakeable.sol";
/**
* @notice DevToken is a development token that we use to learn how to code solidity 
* and what BEP-20 interface requires
*/
contract DevToken is Stakeable{
 /**
    * Add functionality like burn to the _stake afunction
    *
     */
    function stake(uint256 _amount) public {
      // Make sure staker actually is good for it
      require(_amount < _balances[msg.sender], "DevToken: Cannot stake more than you own");

        _stake(_amount);
                // Burn the amount of tokens on the sender
        _burn(msg.sender, _amount);
    }

}