// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "forge-std/Console.sol";

error ErrorHandleExists(string handle);
error ErrorNotProfileOwner(address account, uint256 tokenId);
error ErrorOneProfilePerAccount(address account);
error ErrorMetadataCannotBeEmpty();
error ErrorHandleCannotBeEmpty();

// Stores all the profiles created - only one is allowed per account
contract EmbraceProfile is ERC721URIStorage, ERC721Holder {
    using Counters for Counters.Counter;

    Counters.Counter private profileId;

    string private baseUri;

    event ProfileCreated(uint256 indexed id, string handle, string metadata, address owner);

    mapping(bytes32 => uint256) public handleToId;
    mapping(address => uint256) public addressToId;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        _setBaseURI("ipfs://");
    }

    function createProfile(string calldata _handle, string calldata _metadataUri) public returns (uint256) {
        return _createProfile(_handle, _metadataUri, msg.sender);
    }

    // TODO: implement signature verification
    function createProfileWithSig(string calldata _handle, string calldata _metadataUri, bytes calldata _signature)
        public
        returns (uint256)
    {
        //return _createProfile(_handle, _metadataUri, _owner);
    }

    function _createProfile(string calldata _handle, string calldata _metadataUri, address _owner)
        internal
        returns (uint256)
    {
        if (bytes(_handle).length == 0) revert ErrorMetadataCannotBeEmpty();
        if (bytes(_metadataUri).length == 0) revert ErrorMetadataCannotBeEmpty();

        bytes32 handleHash = keccak256(abi.encodePacked(_handle));
        if (handleToId[handleHash] != 0) revert ErrorHandleExists(_handle);
        if (addressToId[_owner] != 0) revert ErrorOneProfilePerAccount(_owner);

        profileId.increment();
        uint256 newProfileId = profileId.current();

        handleToId[handleHash] = newProfileId;
        addressToId[_owner] = newProfileId;

        _mint(_owner, newProfileId);
        _setTokenURI(newProfileId, _metadataUri);

        emit ProfileCreated(newProfileId, _handle, _metadataUri, _owner);

        return newProfileId;
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function setTokenUri(uint256 tokenId, string calldata _metadataUri) public {
        if (msg.sender != ownerOf(tokenId)) revert ErrorNotProfileOwner(msg.sender, tokenId);

        _setTokenURI(tokenId, _metadataUri);
    }

    function totalSupply() public view returns (uint256) {
        return profileId.current();
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function _setBaseURI(string memory _uri) internal {
        baseUri = _uri;
    }

    function _baseURI() internal view virtual override(ERC721) returns (string memory) {
        return baseUri;
    }
}
