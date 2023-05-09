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
    
    // Listing type defined as an enumerator, FixedPrice and Auction.
    // Representing the two types of listings availavble when the 'createListing' function is called. 
    enum ListingType {FixedPrice, Auction}
    
    // Struct specifiying the general form of created listings. 
    struct Listing {
        uint256 tokenId;
        uint256 price;
        address seller;
    }
    
    // Struct specifiying the general form of created auctions. 
    // hasStarted and timeLeft are necessary to provide information about the time left in an auction, 
    // when the viewAuctions() function is called. 
    struct Auction {
        uint256 tokenId;
        uint256 startTime;
        uint256 duration;
        uint256 highestBid;
        address highestBidder;
        address seller;
        bool hasStarted;
        uint256 timeLeft;
    }


    // Mappings to each respective listing and purchasing / bidding processes. 
    mapping(uint256 => Listing) public fixedPriceListings;
    mapping(uint256 => Auction) public auctions;
    
    
    constructor() ERC721("JJAX Music", "JJAX") {
        _tokenIdCounter.increment(); // sets the initial token ID 
    }
    
    

    // Function for creating a fixed price listing. 
    // The calling of the fucntion requires the user to justify ownership over thier NFT. 
    // Whether the token is already in either a fixed lisiting or auction is also checked, to avoid overwriting. 
    function createFixedPriceListing(uint256 tokenId, uint256 price) public {
            require(ownerOf(tokenId) == msg.sender, "Only the owner can list a token.");
            require(fixedPriceListings[tokenId].seller == address(0), "Token already listed.");
            require(auctions[tokenId].seller == address(0), "Token is already in an auction.");

            fixedPriceListings[tokenId] = Listing({
                tokenId: tokenId,
                price: price,
                seller: msg.sender
            });
        }
        
    
    // Function for creating a auction style listing of an NFT. 
    // 'minPrice' serves as an initial bid, that has to be outbid in order actually start the auction. 
    // Creating an auction and defining 'minPrice' does NOT begin the auction timer. 
    // Whether the token is already in either a fixed lisiting or auction is also checked, to avoid overwriting. 
    function createAuction(uint256 tokenId, uint256 minPrice, uint256 auctionDuration) public {
            require(ownerOf(tokenId) == msg.sender, "Only the owner can list a token.");
            require(fixedPriceListings[tokenId].seller == address(0), "Token already listed.");
            require(auctions[tokenId].seller == address(0), "Token is already in an auction.");

            auctions[tokenId] = Auction({
                tokenId: tokenId,
                startTime: 0, 
                duration: auctionDuration, 
                highestBid: minPrice, 
                highestBidder: address(0),
                seller: msg.sender
            });
        }


    // Function for buying ownership for a fixed lisiting specifically. 
    // Withdraw function is unnecessary as the contract transfers funds immediately after a trading transaction. 
    function buyFixedPriceListing(uint256 tokenId) public payable {
        Listing storage listing = fixedPriceListings[tokenId];
        require(listing.seller != address(0), "Listing does not exist.");
        require(msg.value >= listing.price, "Not enough ether sent.");

        _transfer(listing.seller, msg.sender, tokenId);

        delete fixedPriceListings[tokenId]; // Once the listing is sold, it is taken off the market. 
    }


    // Function for placing a bid in an auction based listing. (Taking the place of highestBid). 
    // Once this function is used for the first time in an auction listing, the pre-defined timer starts. 
    function bidOnAuction(uint256 tokenId) public payable {
        Auction storage auction = auctions[tokenId];
        require(auction.seller != address(0), "Auction does not exist.");
        require(block.timestamp < auction.startTime + auction.duration, "Auction has ended.");
        require(msg.value > auction.highestBid, "Bid must be higher than the current highest bid.");

        if (auction.startTime != 0) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        } else {
            auction.startTime = block.timestamp;
            auction.hasStarted = true; // The auction has now started
        }

        // Update the time left
        auction.timeLeft = auction.duration - (block.timestamp - auction.startTime);

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
    }



    // Function specifying the logic of an auction once the timer is up. 
    // If no one bids and the highest bidder is the still the initial lister, then they will retain ownership. 
    function endAuction(uint256 tokenId) public {
        Auction storage auction = auctions[tokenId];
        require(auction.seller != address(0), "Auction does not exist.");
        require(block.timestamp >= auction.startTime + auction.duration, "Auction has not ended.");

            if (auction.highestBidder != address(0)) {
                _transfer(auction.seller, auction.highestBidder, tokenId);
                payable(auction.seller).transfer(auction.highestBid);
            }

            // Remove the auction from the market. 
            delete auctions[tokenId];
        }
    
    
    
    // A fucntion for visualising current lisitings so users are able to see and buy fixed listings. 
    // A for loop is used to the function will not return an array with any empty values, as some NFTS may not have an associated listing. 
    function viewFixedPriceListings() public view returns (Listing[] memory) {
        uint256 totalListings = _tokenIdCounter.current();
        uint256 count = 0;
        
        for (uint256 i = 0; i < totalListings; i++) {
            if (fixedPriceListings[i].seller != address(0)) {
                count++;
            }
        }

        Listing[] memory result = new Listing[](count);
        uint256 index = 0;
        
        // for loop is used to count the current number of active listings.
        // It does this by seeing for check token ID, whether it has a corresponding listing. 
        for (uint256 i = 0; i < totalListings; i++) {
            if (fixedPriceListings[i].seller != address(0)) {
                result[index] = fixedPriceListings[i];
                index++;
            }
        }

        return result;
    }
    
    
    // A function for visualising current auctions so users are able to see and buy fixed listings. 
    // A for loop is used to the function will not return an array with any empty values, as some NFTS may not have an associated listing.
    // This fucntion also provides information about whether certain auctions have started yet and how long is left for each auction. 
    function viewAuctions() public view returns (Auction[] memory) {
        uint256 totalAuctions = _tokenIdCounter.current();
        uint256 count = 0;
        
        // for loop is used to count the current number of active auctions.
        // It does this by seeing for check token ID, whether it has a corresponding auction.
        for (uint256 i = 0; i < totalAuctions; i++) {
            if (auctions[i].seller != address(0)) {
                count++;
            }
        }

        Auction[] memory result = new Auction[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < totalAuctions; i++) {
            if (auctions[i].seller != address(0)) {
                Auction memory auction = auctions[i];

                // If the auction has started, update the time left
                if (auction.hasStarted) {
               
                    auction.timeLeft = auction.duration - (block.timestamp - auction.startTime);
                }

                result[index] = auction;
                index++; // incrementing index by 1. 
            }
        }

        return result;
    }








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
