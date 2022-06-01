// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Sc1{
    uint private num1 = 1;
    uint private num2 = 2;


    function sameNum1(uint num) external view returns(bool){
        if(num == num1){
            return true;
        }else{
            return false;
        }
    
    }
}