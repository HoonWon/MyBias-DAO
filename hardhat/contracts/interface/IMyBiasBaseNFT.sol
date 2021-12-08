pragma solidity ^0.8.2;

import "./IERC20.sol";
import "./IMyBiasBaseGovernanceToken.sol";

interface IMyBiasBaseNFT {
    function approve(address to, uint256 tokenId) external;

    function balanceOf(address owner) external view returns (uint256);

    function burn(uint256 tokenId) external;

    function currentTokenIndex() external view returns (uint256);

    function disablePreSale() external;

    function disablePublicSale() external;

    function enablePreSale() external;

    function enablePublicSale() external;

    function getApproved(uint256 tokenId) external view returns (address);

    function init(
        address ownerAddress,
        string memory _target,
        IMyBiasBaseGovernanceToken _governanceToken,
        address payable _fundContract,
        address signerAddress,
        uint256 price,
        uint256 _maxNum,
        uint256 _maxBuyNum
    ) external;

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    function isInitialized() external view returns (bool);

    function isPreSaleEnabled() external view returns (bool);

    function isPublicSaleEnabled() external view returns (bool);

    function isSaleKilled() external view returns (bool);

    function killSale() external;

    function maxBuyNum() external view returns (uint256);

    function maxNum() external view returns (uint256);

    function mint(address account) external;

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function ownerOf(uint256 tokenId) external view returns (address);

    function pause() external;

    function paused() external view returns (bool);

    function preSale(bytes memory sig, uint256 amount) external;

    function publicSale(uint256 amount) external;

    function renounceOwnership() external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) external;

    function setApprovalForAll(address operator, bool approved) external;

    function setPrice(uint256 price) external;

    function setSignerAddress(address signerAddress) external;

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function symbol() external view returns (string memory);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferOwnership(address newOwner) external;

    function unpause() external;
}
