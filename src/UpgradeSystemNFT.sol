// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract UpgradeSystemNFT is ERC721, Ownable {
    using Strings for uint8;

    // ERRORS
    error UpgradeSystemNFT__ONLY_OWNER_CAN_UPGRADE();
    error UpgradeSystemNFT__INSUFFICIENT_FUNDS_FOR_UPGRADE();
    error UpgradeSystemNFT__MAX_SUPPLY_EXCEEDED();

    // STATE VARIABLES
    uint16 private constant MAX_SUPPLY = 9999;
    uint16 private _tokenIdCounter = 0;
    mapping(uint16 tokenId => uint8 level) private _tokenLevels;
    mapping(uint8 upgradeLevel => uint256 upgradeCost) private _upgradeCosts;

    // EVENTS
    event TokenUpgraded(uint16 indexed tokenId, uint8 oldLevel, uint8 newLevel);

    // CONSTRUCTOR
    constructor(address initialOwner) ERC721("UpgradeSystemNFT", "USNFT") Ownable(initialOwner) {}

    // PUBLIC FUNCTIONS
    function mint(address to) public onlyOwner {
        uint16 tokenId = _tokenIdCounter;
        if (tokenId >= MAX_SUPPLY) {
            revert UpgradeSystemNFT__MAX_SUPPLY_EXCEEDED();
        }

        _safeMint(to, tokenId);
        _tokenLevels[tokenId] = 0;
        _tokenIdCounter++;
    }

    function upgrade(uint16 tokenId) public payable {
        if (ownerOf(tokenId) != msg.sender) {
            revert UpgradeSystemNFT__ONLY_OWNER_CAN_UPGRADE();
        }

        uint8 currentLevel = _tokenLevels[tokenId];
        uint8 nextLevel = currentLevel + 1;

        uint256 upgradeCost = _upgradeCosts[nextLevel];
        if (msg.value < upgradeCost) {
            revert UpgradeSystemNFT__INSUFFICIENT_FUNDS_FOR_UPGRADE();
        }

        _tokenLevels[tokenId] = nextLevel;

        emit TokenUpgraded(tokenId, currentLevel, nextLevel);
    }

    // Setter Functions
    function setUpgradeCost(uint8 level, uint256 cost) public onlyOwner {
        _upgradeCosts[level] = cost;
    }

    // INTERNAL FUNCTIONS
    function _baseURI() internal pure override returns (string memory) {
        return "https://api.upgradesystemnft.com/"; // TODO: Update this
    }

    // VIEW/PURE FUNCTIONS
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        uint8 level = _tokenLevels[uint16(tokenId)];
        string memory baseURI = _baseURI();

        return string(abi.encodePacked(baseURI, "metadata_", level.toString(), ".json"));
    }

    // Getter Functions
    function getLevel(uint16 tokenId) public view returns (uint8) {
        return _tokenLevels[tokenId];
    }

    function getUpgradeCost(uint8 level) public view returns (uint256) {
        return _upgradeCosts[level];
    }

    // Pure Functions
    function getMaxSupply() public pure returns (uint16) {
        return MAX_SUPPLY;
    }
}
