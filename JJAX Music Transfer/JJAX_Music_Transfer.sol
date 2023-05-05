// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.3/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.3/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.3/security/Pausable.sol";
import "@openzeppelin/contracts@4.8.3/access/Ownable.sol";
import "@openzeppelin/contracts@4.8.3/utils/Counters.sol";

contract JJAXMusic is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;


    Counters.Counter private _tokenIdCounter;

    uint256 public MINT_PRICE = 0.05 ether;
    uint256 public MAX_SUPPLY = 10000;

    //mapping(address => mapping(uint256 => Listing)) public listings;
    
    constructor() ERC721("JJAX Music", "JJAX") {
        _tokenIdCounter.increment(); // sets the initial token ID 
    }

    //struct Listing { //where we store info about NFTs to sell
      //  uint256 price;
        //address seller;

    //}
    //function addListing(uint256 price,address contractAddruint256 tokenID) public { //unfinished
        //require user owns the NFT

      //  require(ownerOf(tokenID) == msg.sender,"This token is registered to another address");
        //listings[msg.sender][tokenID] = listing(price,msg.sender);


    //}
    
    function withdraw() public onlyOwner() { //get the money from the contract
        require(address(this).balance>0, "Balance is zero");
        payable(owner()).transfer(address(this).balance);
    }

    //TO DO FUNCTIONS 

    // function Listing (token_ID, Price) 
    // Puts the token up for sale, when a third party sends the Price, ownership is transfered

    // function view_listings (view function)
    // returns a list of all tokens for sale

    //function Auction 
    // Like sell except the token is auctioned 


    function _baseURI() internal pure override returns (string memory) {
        return "XXXXX"; // will eventually be the IPFS URI 
    }

    function pause() public onlyOwner {  //Allows you to pause the contract (part of the standard)
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to) public payable{ // Mint or create a NFT :)
        require(totalSupply() < MAX_SUPPLY,"No More Mintable Tokens.");//Total supply of tokens Cant make more then MAX_SUPPLY
        require(msg.value >= MINT_PRICE,"Not enough ether sent.");//Cost ether to mint a token
        uint256 tokenId = _tokenIdCounter.current(); //Gives the token an ID
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
