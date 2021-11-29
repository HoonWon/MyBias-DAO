pragma solidity ^0.8.0;

import "./IMyBiasBaseNFT.sol";
import "./CloneFactory.sol";
import "./Ownable.sol";

contract MyBiasNFTFactory is Ownable, CloneFactory {
    address public libraryAddress;

    event MyBiasNFTCreated(
        address newThingAddress,
        string name,
        string symbol,
        address signerAddress
    );

    constructor(address ownerAddress, address targetAddress) {
        _transferOwnership(ownerAddress);
        libraryAddress = targetAddress;
    }

    function createNFT(
        address ownerAddress,
        string memory name,
        string memory symbol,
        address signerAddress
    ) external onlyOwner returns (address) {
        require(bytes(name).length != 0, "name should not be empty");
        require(bytes(symbol).length != 0, "symbol should not be empty");
        require(
            signerAddress != address(0),
            "signerAddress should not be zeroAddress"
        );

        address clone = createClone(libraryAddress);
        IMyBiasBaseNFT(clone).init(ownerAddress, name, symbol, signerAddress);

        emit MyBiasNFTCreated(clone, name, symbol, signerAddress);

        return clone;
    }
}
