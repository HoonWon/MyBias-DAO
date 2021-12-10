pragma solidity ^0.8.2;

import "./interface/IMyBiasBaseGovernanceToken.sol";
import "./library/CloneFactory.sol";
import "./library/Ownable.sol";

contract MyBiasGovernanceTokenFactory is Ownable, CloneFactory {
    address public libraryAddress;
    address public latestCreatedGovernanceToken;
    address[] public created;

    event MyBiasGovernanceTokenCreated(address newThingAddress);

    event MyBiasGovernanceTokenInitialized(address nftContract, string target);

    constructor(address ownerAddress, address targetAddress) {
        _transferOwnership(ownerAddress);
        libraryAddress = targetAddress;
    }

    function createGovernanceToken() external onlyOwner returns (address) {
        address clone = createClone(libraryAddress);
        created.push(clone);
        latestCreatedGovernanceToken = clone;

        emit MyBiasGovernanceTokenCreated(clone);

        return clone;
    }

    function initGovernanceToken(
        address ownerAddress,
        address nftContract,
        string memory target
    ) external onlyOwner returns (address) {
        IMyBiasBaseGovernanceToken(latestCreatedGovernanceToken).init(
            ownerAddress,
            nftContract,
            target
        );

        emit MyBiasGovernanceTokenInitialized(nftContract, target);
    }

    function getCreated() external view returns (address[] memory) {
        return created;
    }
}
