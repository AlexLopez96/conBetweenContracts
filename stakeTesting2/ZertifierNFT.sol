// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Pausable.sol";
import "./ERC721Burnable.sol";
import "./ERC721Claimable.sol";
import "./Ownable.sol";
import "./AccessControlEnumerable.sol";
import "./Context.sol";
import "./Strings.sol";


/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract ZertifierNFT is
Context,
Ownable,
AccessControlEnumerable,
ERC721,
ERC721Enumerable,
ERC721Burnable,
ERC721Pausable,
ERC721Claimable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    string private _baseTokenURI;
    string private _baseContractURI;
    uint256 private _biggestTokenIdNum;

    mapping(string => string) private _customParam;
    mapping(uint256 => mapping(string => string)) private _externalIds;
    mapping(string => mapping(string => uint256)) private _externalIdTokenId;
    mapping(uint256 => mapping(string => string)) private _metadata;
    mapping(uint256 => mapping(string => address)) private _identities;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor(
        string memory name,
        string memory symbol,
        string memory baseTokenURI,
        string memory baseContractURI
    ) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
        _baseContractURI = baseContractURI;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 tokenId) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, tokenId);

        if(_biggestTokenIdNum < tokenId) {
            _biggestTokenIdNum = tokenId;
        }
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControlEnumerable, ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function claimToken(uint256 tokenId, uint256 nonce, bytes memory sig) 
    public virtual {
        address from = ownerOf(tokenId);

        require (!usedNonces[from][nonce], "ERC721Claimable: This nonce has already been used");
        require (_verifyClaimTokenSignature(from, sig, tokenId, nonce), "ERC721Claimable: ClaimToken signature is not valid");

        usedNonces[from][nonce] = true;
        _transfer(from, _msgSender(), tokenId);
    }

    function getBiggestTokenIdNum() public view returns (uint256) {
        return _biggestTokenIdNum;
    }

    function mintWithExternalId(address to, uint256 tokenId, string memory externalIdName, string memory externalIdValue) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, tokenId);

        setExternalId(tokenId, externalIdName, externalIdValue);
    }

    function setMetadata(uint256 tokenId, string memory metadataName, string memory metadataValue) public virtual {
        string memory metadataNameUpperCase = Strings.upper(metadataName);

        require(tokenId > 0, "Token ID is empty");
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");

        _metadata[tokenId][metadataNameUpperCase] = metadataValue;

        emit SetMetadata(tokenId, metadataNameUpperCase, metadataValue);
    }

    function getMetadata(uint256 tokenId, string memory metadataName) public view returns (string memory) {
        return _metadata[tokenId][Strings.upper(metadataName)];
    }

    function setCustomParam(string memory customParamName, string memory customParamValue) public virtual {
        string memory customParamNameUpperCase = Strings.upper(customParamName);

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");

        _customParam[customParamNameUpperCase] = customParamValue;

        emit SetCustomParam(customParamNameUpperCase, customParamValue);
    }

    function getCustomParam(string memory customParamName) public view returns (string memory) {
        return _customParam[Strings.upper(customParamName)];
    }

    function setExternalId(uint256 tokenId, string memory externalIdName, string memory externalIdValue) public virtual {
        string memory externalIdNameUpperCase = Strings.upper(externalIdName);
        string memory externalIdValueUpperCase = Strings.upper(externalIdValue);

        require(tokenId > 0, "Token ID is empty");
        require(bytes(_externalIds[tokenId][externalIdNameUpperCase]).length == 0 && bytes(externalIdNameUpperCase).length > 0, "External ID is already set up");
        require(_externalIdTokenId[externalIdNameUpperCase][externalIdValueUpperCase] == 0, "Value is not unique");
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");

        _externalIds[tokenId][externalIdNameUpperCase] = externalIdValue;
        _externalIdTokenId[externalIdNameUpperCase][externalIdValueUpperCase] = tokenId;

        emit SetExternalId(tokenId, externalIdNameUpperCase, externalIdValue);
    }

    function getExternalId(uint256 tokenId, string memory externalIdName) public view returns (string memory){
        return _externalIds[tokenId][Strings.upper(externalIdName)];
    }

    function getTokenIdFromExternalId(string memory externalIdName, string memory externalIdValue) public view returns (uint256) {
        return _externalIdTokenId[Strings.upper(externalIdName)][Strings.upper(externalIdValue)];
    }

    function getTokenIdFromNFC(string memory externalIdValue) public view returns (uint256) {
        return  getTokenIdFromExternalId("NFC", externalIdValue);
    }

    function setNFC(uint256 tokenId, string memory externalIdValue) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");

        setExternalId(tokenId, "NFC", externalIdValue);
    }

    function getNFC(uint256 tokenId) public view returns (string memory){
        return _externalIds[tokenId]["NFC"];
    }

    function contractURI() public view returns (string memory) {
        return _baseContractURI;
    }

    function getBaseTokenURI() public view returns (string memory) {
        return _baseTokenURI;
    }

    // Events
    event SetCustomParam(string indexed customParamName, string indexed customParamValue);
    event SetMetadata(uint256 indexed tokenId, string indexed sensorName, string indexed metadataValue);
    event SetExternalId(uint256 indexed tokenId, string indexed sensorName, string indexed externalIdValue);
}
