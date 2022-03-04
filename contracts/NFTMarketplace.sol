// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    struct Item {
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }
    mapping(uint256 => Item) private idToItem;

    constructor() ERC721("MarketItem", "ITM") {
        owner = payable(msg.sender);
    }

    function createToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        addItem(newTokenId, price);
        return newTokenId;
    }

    function addItem(uint256 tokenId, uint256 price) public payable {
        require(price > 0, "Price must be greater than 0");

        idToItem[tokenId] = Item(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
        _transfer(msg.sender, address(this), tokenId);
    }

    function sellItem(uint256 tokenId) public payable {
        uint256 price = idToItem[tokenId].price;
        address seller = idToItem[tokenId].seller;

        require(msg.value == price, "Please submit the asking price");

        idToItem[tokenId].owner = payable(msg.sender);
        idToItem[tokenId].sold = true;
        idToItem[tokenId].seller = payable(address(0));
        _itemsSold.increment();
        _transfer(address(this), msg.sender, tokenId);
        payable(seller).transfer(msg.value);
    }
}
