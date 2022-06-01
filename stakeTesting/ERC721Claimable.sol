// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.3;

import "./SignatureChecker.sol";

contract ERC721Claimable {
    mapping(address => mapping(uint256 => bool)) public usedNonces;

    function getClaimTokenSignature(
        uint256 _tokenId,
        uint256 _nonce
    )
    external pure returns (bytes32)
    {
        return 
            keccak256(
                abi.encodePacked(
                    keccak256("ClaimToken(uint256 tokenId, uint256 nonce)"),
                    _tokenId,
                    _nonce
                )
            );
       
    }

    function _verifyClaimTokenSignature(
        address _signer,
        bytes memory _sig,
        uint256 _tokenId,
        uint256 _nonce
    )
    internal view returns (bool)
    {
        bytes32 messageHash = ECDSA.toEthSignedMessageHash(this.getClaimTokenSignature(_tokenId, _nonce));
        return SignatureChecker.isValidSignatureNow(_signer, messageHash, _sig);
    }

}
