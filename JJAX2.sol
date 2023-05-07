// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.3/utils/Counters.sol";

contract JJAX2 is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public MINT_PRICE = 0 ether; //Cost of minting
    uint256 public MAX_SUPPLY = 100; //total amount of NFTs allowed

    constructor() ERC721("JJAX2", "JAX") {
        _tokenIdCounter.increment(); //First NFT minted will have token ID 1 
    }

    function safeMint(address to, string memory uri) public payable {
        require(totalSupply() < MAX_SUPPLY,"No More Mintable Tokens.");//Total supply of tokens Cant make more then MAX_SUPPLY
        require(msg.value >= MINT_PRICE,"Not enough ether sent.");//Cost ether to mint a token
        uint256 tokenId = _tokenIdCounter.current(); //Gets token ID 
        _tokenIdCounter.increment(); //Incrementes System token ID
        _safeMint(to, tokenId); //Mints the new ID
        _setTokenURI(tokenId, uri); //Associates the Token with a URI (link to metadata on IPFS)
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) { //Remove a Token
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
