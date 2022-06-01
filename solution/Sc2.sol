// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import 'Sc1.sol';
contract Sc2{
    function isSameNum(address contractAddress, uint num) public view returns(bool){
        Sc1 i = Sc1(contractAddress);
        return i.sameNum1(num);
    }
}
