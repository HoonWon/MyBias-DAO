pragma solidity ^0.8.2;

import "./interface/IERC20.sol";
import "./interface/IMyBiasBaseFund.sol";
import "./interface/IMyBiasBaseGovernanceToken.sol";
import "./library/CloneFactory.sol";
import "./library/Ownable.sol";

contract MyBiasFundFactory is Ownable, CloneFactory {
    address public libraryAddress;
    address public latestCreatedFund;
    address[] public created;

    event MyBiasFundCreated(address newThingAddress);

    event MyBiasFundInitialized(
        address _token,
        address ownerAddress,
        string _target,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThreshold,
        address initialStrategy
    );

    constructor(address ownerAddress, address targetAddress) {
        _transferOwnership(ownerAddress);
        libraryAddress = targetAddress;
    }

    function createFund() external onlyOwner returns (address) {
        address clone = createClone(libraryAddress);
        created.push(clone);
        latestCreatedFund = clone;

        emit MyBiasFundCreated(clone);

        return clone;
    }

    function initFund(
        IMyBiasBaseGovernanceToken _token,
        address ownerAddress,
        string memory _target,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThreshold,
        address payable initialStrategy
    ) external onlyOwner returns (address) {
        IMyBiasBaseFund(payable(latestCreatedFund)).init(
            _token,
            ownerAddress,
            _target,
            _votingDelay,
            _votingPeriod,
            _proposalThreshold,
            initialStrategy
        );

        emit MyBiasFundInitialized(
            address(_token),
            ownerAddress,
            _target,
            _votingDelay,
            _votingPeriod,
            _proposalThreshold,
            initialStrategy
        );
    }

    function getCreated() external view returns (address[] memory) {
        return created;
    }
}
