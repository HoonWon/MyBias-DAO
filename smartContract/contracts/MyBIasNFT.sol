pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract ERC721BurnableAndPausable is ERC721Pausable, ERC721Burnable {
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}

abstract contract ERC721URIStorage is
    ERC721BurnableAndPausable,
    ERC721Enumerable
{
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable, ERC721BurnableAndPausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract MyBiasNFT is ERC721URIStorage, Ownable {
    address private _signerAddress;
    uint256 public currentTokenIndex = 0;
    uint256 public _price = 0.05 ether;
    uint256 public maxNum = 3;
    uint256 public maxBuyNum = 30;
    bool public isSaleKilled = false;
    bool public isPublicSaleEnable = false;
    bool public isPreSaleEnable = false;

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

    constructor(address signerAddress) ERC721("MyBiasNFT", "MBN") {
        _signerAddress = signerAddress;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _killSale() internal {
        isSaleKilled = true;
        isPreSaleEnable = false;
        isPublicSaleEnable = false;

        emit SaleKilled();
    }

    function _mintMyBiasNFT(address account) internal {
        uint256 tokenId = currentTokenIndex + 1;
        _safeMint(account, tokenId);
        currentTokenIndex = tokenId;

        if (currentTokenIndex >= maxNum) {
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
        require(isPublicSaleEnable, "publicSale is not enabled");
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
        require(!isPreSaleEnable, "enablePreSale: preSale is already enabled");

        isPreSaleEnable = true;

        emit PreSaleEnabled();
    }

    function disablePreSale() external onlyOwner {
        require(!isSaleKilled, "disablePreSale: sale is killed");
        require(isPreSaleEnable, "disablePreSale: preSale is already disabled");

        isPreSaleEnable = false;

        emit PreSaleDisabled();
    }

    function enablePublicSale() external onlyOwner {
        require(!isSaleKilled, "enablePublicSale: sale is killed");
        require(
            !isPublicSaleEnable,
            "enablePublicSale: publicSale is already enabled"
        );

        isPublicSaleEnable = true;

        emit PublicSaleEnabled();
    }

    function disablePublicSale() external onlyOwner {
        require(!isSaleKilled, "disablePublicSale: sale is killed");
        require(
            isPublicSaleEnable,
            "disablePublicSale: publicSale is already disabled"
        );

        isPublicSaleEnable = false;

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
}
