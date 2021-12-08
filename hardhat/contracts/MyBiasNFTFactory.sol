pragma solidity ^0.8.2;

import "./interface/IMyBiasBaseNFT.sol";
import "./library/CloneFactory.sol";
import "./library/Ownable.sol";
import "./interface/IERC20.sol";
import "./interface/IMyBiasBaseGovernanceToken.sol";

contract MyBiasNFTFactory is Ownable, CloneFactory {
    address public libraryAddress;
    address public latestCreatedNFT;

    event MyBiasNFTCreated(address newThingAddress);

    event MyBiasNFTInitialized(
        address ownerAddress,
        string target,
        address governanceToken,
        address payable fundContract,
        address signerAddress,
        uint256 price,
        uint256 maxNum,
        uint256 maxBuyNum
    );

    constructor(address ownerAddress, address targetAddress) {
        _transferOwnership(ownerAddress);
        libraryAddress = targetAddress;
    }

    function createNFT() external onlyOwner returns (address) {
        address clone = createClone(libraryAddress);
        latestCreatedNFT = clone;

        emit MyBiasNFTCreated(clone);

        return clone;
    }

    function initNFT(
        address ownerAddress,
        string memory target,
        IMyBiasBaseGovernanceToken governanceToken,
        address payable fundContract,
        address signerAddress,
        uint256 price,
        uint256 maxNum,
        uint256 maxBuyNum
    ) external onlyOwner {
        IMyBiasBaseNFT(latestCreatedNFT).init(
            ownerAddress,
            target,
            governanceToken,
            fundContract,
            signerAddress,
            price,
            maxNum,
            maxBuyNum
        );

        emit MyBiasNFTInitialized(
            ownerAddress,
            target,
            address(governanceToken),
            fundContract,
            signerAddress,
            price,
            maxNum,
            maxBuyNum
        );
    }
}
