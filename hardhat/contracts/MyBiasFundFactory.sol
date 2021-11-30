pragma solidity ^0.8.0;

import "./interface/IERC20.sol";
import "./interface/IMyBiasBaseFund.sol";
import "./library/CloneFactory.sol";
import "./library/Ownable.sol";

contract MyBiasFundFactory is Ownable, CloneFactory {
    address public libraryAddress;

    event MyBiasFundCreated(
        address newThingAddress,
        string name,
        IERC20 weth,
        address payable withdrwalAddress
    );

    constructor(address ownerAddress, address targetAddress) {
        _transferOwnership(ownerAddress);
        libraryAddress = targetAddress;
    }

    function createFund(
        address ownerAddress,
        string memory name,
        IERC20 weth,
        address payable withdrawalAddress
    ) external onlyOwner returns (address) {
        require(bytes(name).length != 0, "name should not be empty");
        require(address(weth) != address(0), "weth should not be zeroAddress");
        require(
            withdrawalAddress != address(0),
            "withdrawalAddress should not be zeroAddress"
        );

        address clone = createClone(libraryAddress);
        IMyBiasBaseFund(payable(clone)).init(
            ownerAddress,
            name,
            weth,
            withdrawalAddress
        );

        emit MyBiasFundCreated(clone, name, weth, withdrawalAddress);

        return clone;
    }
}
