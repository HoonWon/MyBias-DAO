pragma solidity ^0.8.2;

import "./IERC20.sol";
import "./IMyBiasBaseGovernanceToken.sol";

interface IMyBiasBaseFund {
    function _WETH() external view returns (address);

    function _withdrawalAddress() external view returns (address);

    function depositMatic() external;

    function depositWETH(uint256 amount) external;

    function getMaticBalance() external view returns (uint256);

    function getWETHBalance() external view returns (uint256);

    function init(
        IMyBiasBaseGovernanceToken _token,
        address ownerAddress,
        string memory _target,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalThreshold,
        address payable strategy
    ) external;

    function isInitialized() external view returns (bool);

    function name() external view returns (string memory);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    function withdrawAllMatic() external;

    function withdrawAllWETH() external;

    function withdrawMatic(uint256 amount) external;

    function withdrawWETH(uint256 amount) external;
}
