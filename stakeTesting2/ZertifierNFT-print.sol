pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Pausable.sol";
import "./Ownable.sol";
import "./AccessControlEnumerable.sol";
import "./Context.sol";

contract ZertifierNFT is
Context,
Ownable,
AccessControlEnumerable,
ERC721,
ERC721Enumerable,
ERC721Pausable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    string private _baseTokenURI;
    string private _baseContractURI;

    mapping(uint256 => mapping(string => string)) private _externalIds;
    mapping(uint256 => mapping(string => string)) private _metadata;
    mapping(uint256 => mapping(string => address)) private _identities;

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


    function mint(address to, uint256 tokenId) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        _mint(to, tokenId);
    }


    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

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

    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControlEnumerable, ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mintWithExternalId(address to, uint256 tokenId, string memory externalIdName, string memory externalIdValue) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        _mint(to, tokenId);

        setExternalId(tokenId, externalIdName, externalIdValue);
    }

    function setIdentity(uint256 tokenId, string memory identityType, address identityAddress) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");
        require(tokenId > 0 && bytes(_externalIds[tokenId][identityType]).length == 0 && bytes(identityType).length > 0, "Metadata is already set up");
        _identities[tokenId][identityType] = identityAddress;

        emit SetIdentity(tokenId, identityType, identityAddress);
    }

    function getIdentity(uint256 tokenId, string memory identityType) public view returns (address){
        return _identities[tokenId][identityType];
    }

    event SetIdentity(uint256 indexed tokenId, string indexed identityType, address indexed identityAddress);

    function setMetadata(uint256 tokenId, string memory metadataName, string memory metadataValue) public virtual {
        require(tokenId > 0 && bytes(_externalIds[tokenId][metadataName]).length == 0 && bytes(metadataName).length > 0, "Metadata is already set up");
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");

        _metadata[tokenId][metadataName] = metadataValue;

        emit SetMetadata(tokenId, metadataName, metadataValue);
    }

    function getMetadata(uint256 tokenId, string memory metadataName) public view returns (string memory){
        return _metadata[tokenId][metadataName];
    }

    event SetMetadata(uint256 indexed tokenId, string indexed sensorName, string indexed metadataValue);

    function setExternalId(uint256 tokenId, string memory externalIdName, string memory externalIdValue) public virtual {
        require(tokenId > 0 && bytes(_externalIds[tokenId][externalIdName]).length == 0 && bytes(externalIdName).length > 0, "Sensor is already set up");
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");

        _externalIds[tokenId][externalIdName] = externalIdValue;

        emit SetExternalId(tokenId, externalIdName, externalIdValue);
    }

    function getExternalId(uint256 tokenId, string memory externalIdName) public view returns (string memory){
        return _externalIds[tokenId][externalIdName];
    }

    event SetExternalId(uint256 indexed tokenId, string indexed sensorName, string indexed externalIdValue);

    function setNFC(uint256 tokenId, string memory externalIdValue) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "ERC721PresetAdmin: must have admin role");

        setExternalId(tokenId, "NFC", externalIdValue);
    }

    function getNFC(uint256 tokenId) public view returns (string memory){
        return _externalIds[tokenId]["NFC"];
    }

    function getBrandAddress(uint256 tokenId) public view returns (address){
        return getIdentity(tokenId, "BRAND");
    }

    function contractURI() public view returns (string memory) {
        return _baseContractURI;
    }

}
