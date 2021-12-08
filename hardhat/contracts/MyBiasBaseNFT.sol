// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IMyBiasBaseGovernanceToken.sol";

import "hardhat/console.sol";

contract MyBiasBaseNFT is
    ERC721,
    ERC721Enumerable,
    Pausable,
    Ownable,
    ERC721Burnable
{
    IERC20 public MaticWETH;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    IMyBiasBaseGovernanceToken public governanceToken;
    address payable public fundContract;

    address private _signerAddress;
    uint256 public _price;
    uint256 public maxNum;
    uint256 public maxBuyNum;
    string public target;
    bool public isSaleKilled;
    bool public isPublicSaleEnabled;
    bool public isPreSaleEnabled;
    bool public isInitialized;

    event SaleKilled();
    event Mint(address to, uint256 indexed tokenId);
    event SetSignerAddress(address signerAddress);
    event PreSale(uint256 amount, uint256 totalPrice);
    event PublicSale(uint256 amount, uint256 totalPrice);
    event PreSaleEnabled();
    event PreSaleDisabled();
    event PublicSaleEnabled();
    event PubSaleDisabled();
    event SetPrice(uint256 oldPrice, uint256 price);

    constructor() ERC721("MyBiasNFT", "MBN") {}

    function init(
        address ownerAddress,
        string memory _target,
        IMyBiasBaseGovernanceToken _governanceToken,
        address payable _fundContract,
        address signerAddress,
        uint256 price,
        uint256 _maxNum,
        uint256 _maxBuyNum
    ) external {
        require(!isInitialized, "already initialized");

        // Polygon Mainnet
        MaticWETH = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);

        governanceToken = _governanceToken;
        fundContract = _fundContract;

        _price = price;
        target = _target;
        _signerAddress = signerAddress;
        maxNum = _maxNum;
        maxBuyNum = _maxBuyNum;

        isSaleKilled = false;
        isPublicSaleEnabled = false;
        isPreSaleEnabled = false;

        MaticWETH.approve(
            address(_fundContract),
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        _transferOwnership(ownerAddress);

        isInitialized = true;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            governanceToken.mint(to, 1);
        } else if (to == address(0)) {
            governanceToken.burnFromNftContract(from);
        } else {
            governanceToken.burnAndMint(from, to);
        }
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _killSale() internal {
        isSaleKilled = true;
        isPreSaleEnabled = false;
        isPublicSaleEnabled = false;

        emit SaleKilled();
    }

    function _mintMyBiasNFT(address account) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(account, tokenId);

        if (tokenId >= maxNum) {
            _killSale();
        }

        emit Mint(account, tokenId);
    }

    function mint(address account) external onlyOwner {
        require(!isSaleKilled, "mint: sale is killed");
        require(
            account != address(0),
            "mint: account should not be zero address"
        );
        require(maxNum > totalSupply(), "mint: exceed max");

        _mintMyBiasNFT(account);
    }

    function setSignerAddress(address signerAddress) external onlyOwner {
        require(signerAddress != address(0));

        _signerAddress = signerAddress;

        emit SetSignerAddress(signerAddress);
    }

    function hashAddress(address account) internal pure returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n20", account)
        );

        return hash;
    }

    function verify(bytes memory sig) internal view returns (bool) {
        bytes32 hash = hashAddress(msg.sender);
        return ECDSA.recover(hash, sig) == _signerAddress;
    }

    function preSale(bytes memory sig, uint256 amount) external payable {
        require(!isSaleKilled, "preSale: sale is killed");
        require(amount <= maxBuyNum, "preSale: you can't buy too many at once");
        require(isPreSaleEnabled, "preSale is not enabled");
        require(msg.value >= _price * amount, "preSale: insufficient balance");
        require(msg.value == _price * amount, "preSale: overpaid");
        require(amount != 0, "preSale: amount should not be zero");
        require(verify(sig), "preSale: invalid signature");
        require(maxNum > totalSupply(), "preSale: sold out");
        require(maxNum >= totalSupply() + amount, "preSale: exceed max");

        for (uint256 i = 0; i < amount; ++i) {
            _mintMyBiasNFT(msg.sender);
        }

        emit PreSale(amount, msg.value);
    }

    function publicSale(uint256 amount) external payable {
        require(!isSaleKilled, "publicSale: sale is killed");
        require(
            amount <= maxBuyNum,
            "publicSale: you can't buy too many at once"
        );
        require(isPublicSaleEnabled, "publicSale is not enabled");
        require(
            msg.value >= _price * amount,
            "publicSale: insufficient balance"
        );
        require(msg.value == _price * amount, "publicSale: overpaid");
        require(amount != 0, "publicSale: amount should not be zero");
        require(maxNum > totalSupply(), "publicSale: sold out");
        require(maxNum >= totalSupply() + amount, "publicSale: exceed max");

        for (uint256 i = 0; i < amount; ++i) {
            _mintMyBiasNFT(msg.sender);
        }

        emit PublicSale(amount, msg.value);
    }

    function enablePreSale() external onlyOwner {
        require(!isSaleKilled, "enablePreSale: sale is killed");
        require(!isPreSaleEnabled, "enablePreSale: preSale is already enabled");

        isPreSaleEnabled = true;

        emit PreSaleEnabled();
    }

    function disablePreSale() external onlyOwner {
        require(!isSaleKilled, "disablePreSale: sale is killed");
        require(
            isPreSaleEnabled,
            "disablePreSale: preSale is already disabled"
        );

        isPreSaleEnabled = false;

        emit PreSaleDisabled();
    }

    function enablePublicSale() external onlyOwner {
        require(!isSaleKilled, "enablePublicSale: sale is killed");
        require(
            !isPublicSaleEnabled,
            "enablePublicSale: publicSale is already enabled"
        );

        isPublicSaleEnabled = true;

        emit PublicSaleEnabled();
    }

    function disablePublicSale() external onlyOwner {
        require(!isSaleKilled, "disablePublicSale: sale is killed");
        require(
            isPublicSaleEnabled,
            "disablePublicSale: publicSale is already disabled"
        );

        isPublicSaleEnabled = false;

        emit PubSaleDisabled();
    }

    function killSale() external onlyOwner {
        require(!isSaleKilled, "killSale: sale is already killed");

        _killSale();
    }

    function setPrice(uint256 price) external onlyOwner {
        require(_price != price, "new price should not be equal to old price");

        uint256 oldPrice = _price;
        _price = price;

        emit SetPrice(oldPrice, price);
    }

    function sendMaticToFund() external onlyOwner {
        uint256 maticBalance = address(this).balance;

        (bool sent, ) = fundContract.call{value: maticBalance}("");

        require(sent, "Failed to send Ether");
    }
}
